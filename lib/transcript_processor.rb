require "json"
require "fileutils"
require "open3"
require "descriptive_statistics"
require "rbconfig"
require_relative "transcript_parser"
require_relative "speaker_extraction"
require_relative "speaker_identification"
require_relative "csv_writer"
require_relative "csv_generator"
require_relative "low_confidence_detector"
require_relative "misalignment_detector"
require_relative "misalignment_corrector"
require_relative "file_validator"
require_relative "speaker_file_manager"

class TranscriptProcessor
  def initialize(transcript_path, audio_path, input: $stdin, output_dir: Dir.pwd, file_validator: FileValidator.new)
    # Use the FileValidator to validate inputs
    file_validator.validate(transcript_path, audio_path)

    @transcript_path = transcript_path
    @audio_path = audio_path
    @parser = TranscriptParser.new(transcript_path)
    @csv_base_name = File.basename(transcript_path, ".*")
    @output_dir = output_dir
    @input = input
    @error_count = 0
    @rows = []
    @misalignments_detected = false
    @speaker_file_manager = SpeakerFileManager.new(output_dir, input: input)
  end

  def process
    puts "Starting Amazon Transcribe processing script"

    # Initialize result hash to track processing status
    result = {
      csv_generated: false,
      speakers_extracted: false,
      misalignments_detected: false
    }

    # Use SpeakerFileManager to check for existing speaker files
    if @speaker_file_manager.check_speaker_files(result)
      return result
    end

    # Step 1: Extract speaker audio
    extract_speaker_audio
    result[:speakers_extracted] = true

    # Wait for user to identify speakers
    wait_for_speaker_identification

    # Complete the remaining processing steps
    complete_processing(result)
  end

  private

  # Print a formatted step header
  # @param step_number [Integer] The step number
  # @param description [String] The step description
  def print_step_header(step_number, description)
    puts "\n=== Step #{step_number}: #{description} ==="
  end

  def identify_segments_to_review
    print_step_header(3, "Identifying segments to review")
    handle_error("identifying segments to review") do
      detector = LowConfidenceDetector.new
      detector.identify_segments_to_review(@rows)
    end
  end

  def extract_speaker_audio
    print_step_header(1, "Extracting speaker audio")
    SpeakerExtraction.new(@parser, @audio_path, @output_dir).extract
  end

  def wait_for_speaker_identification(skip: false)
    SpeakerIdentification.new(@parser, @audio_path, @output_dir).identify(skip: skip)
  end

  # Find speaker identifications from renamed audio files
  # @return [Hash] Map of speaker labels to speaker names
  def find_speaker_identities
    handle_error("processing speaker identity files") do
      @speaker_file_manager.find_speaker_identities
    end
  end

  # Process transcript items and generate rows
  # @param speaker_identities [Hash] Map of speaker labels to speaker names
  # @return [Array] Processed transcript rows
  def process_transcript_items(speaker_identities)
    csv_gen = CsvGenerator.new
    # Get parsed items from the parser
    parsed_items = @parser.parsed_items || []

    # Process the parsed items using the new method
    handle_error("processing transcript items", []) do
      csv_gen.process_parsed_items(parsed_items, speaker_identities, silence_threshold: 1.0)
    end
  end

  # Handle misalignment detection and correction
  # @param rows [Array] Transcript rows
  # @return [Array] Updated transcript rows
  def handle_misalignments(rows)
    misalignment_issues = handle_error("detecting misalignments", []) do
      issues = MisalignmentDetector.new(rows).detect_issues
      # Store if misalignments were detected in the instance variable
      @misalignments_detected = !issues.empty?
      issues
    end

    handle_error("correcting misalignments") do
      MisalignmentCorrector.new(rows, misalignment_issues).correct!
    end

    rows
  end

  # Write transcript rows to CSV
  # @param rows [Array] Transcript rows
  def write_to_csv(rows)
    csv_writer = CsvWriter.new(@output_dir)
    handle_error("writing CSV transcript") do
      csv_writer.write_transcript(rows, @csv_base_name)
    end
  end

  def generate_csv_transcript
    print_step_header(2, "Generating CSV transcript")

    # Open the directory for the user to rename files
    open_output_directory

    # Find speaker identifications from renamed files
    speaker_identities = find_speaker_identities

    # Process transcript into rows
    rows = process_transcript_items(speaker_identities)

    # Detect and correct misalignments
    rows = handle_misalignments(rows)

    # Write to CSV
    write_to_csv(rows)

    @rows = rows
  end

  def open_directory_command
    host_os = RbConfig::CONFIG["host_os"]

    case host_os
    when /darwin|mac\s?os/i
      "open"
    when /mswin|mingw|cygwin/i
      "start"
    when /linux|solaris|bsd/i
      "xdg-open"
    end
  end

  def open_output_directory
    command = open_directory_command
    if command
      Kernel.system("#{command} #{@output_dir}")
    else
      puts "Unable to open directory automatically for this platform."
    end
  end

  # Reusable error handling method with recovery strategies
  # @param operation_description [String] Description of the operation being performed
  # @param default_value [Object] Optional default value to return on error
  # @param recovery_options [Hash] Options for error recovery strategies
  # @option recovery_options [Integer] :retry_count Number of times to retry the operation
  # @option recovery_options [Float] :retry_delay Delay in seconds between retry attempts
  # @option recovery_options [Proc] :fallback_proc Procedure to execute as fallback when all retries fail
  # @option recovery_options [Object] :log_to Logger object to log errors to
  # @option recovery_options [String] :notification Custom notification message for critical errors
  # @yield The block of code to execute
  # @return [Object] Result of the block if successful, fallback value if error
  def handle_error(operation_description, default_value = nil, recovery_options = {})
    # Extract recovery options with defaults
    retry_count = recovery_options[:retry_count] || 0
    retry_delay = recovery_options[:retry_delay] || 0.1
    fallback_proc = recovery_options[:fallback_proc]
    logger = recovery_options[:log_to]
    notification = recovery_options[:notification]

    attempt = 0

    begin
      # Try the operation
      attempt += 1
      yield
    rescue ValidationError, ProcessingError, SpeakerIdentificationError, FileOperationError, StandardError => e
      # Log the error
      error_message = "Error #{operation_description}: #{e.message}"
      puts error_message
      puts e.backtrace.join("\n") if ENV["DEBUG"]

      # Log to external logger if provided
      logger&.error(error_message)

      # Display notification if provided
      puts notification if notification

      # Increment error counter
      @error_count += 1

      # Apply specific recovery strategies based on error type
      if e.is_a?(ValidationError)
        # Validation errors typically can't be recovered by retry
        if fallback_proc
          return fallback_proc.call
        else
          return default_value
        end
      elsif e.is_a?(ProcessingError) && attempt <= retry_count
        # Processing errors might be transient, so retry
        sleep retry_delay
        retry
      elsif e.is_a?(FileOperationError)
        # File operation errors might need notification
        puts "Critical file operation error detected" unless notification

        if attempt <= retry_count
          sleep retry_delay
          retry
        end
      elsif attempt <= retry_count
        # General retry for other errors
        sleep retry_delay
        retry
      end

      # Use fallback proc if available
      fallback_proc ? fallback_proc.call : default_value
    end
  end

  # Complete the remaining processing steps common to all paths
  # @param result [Hash] The result hash to update
  # @return [Hash] Updated result hash
  def complete_processing(result)
    # Step 2: Generate CSV transcript
    generate_csv_transcript
    result[:csv_generated] = true

    # Step 3: Identify segments to review
    identify_segments_to_review

    # Update result with misalignments detection status
    result[:misalignments_detected] = @misalignments_detected || false

    puts "Processing complete!"
    result
  end

  # Process named speaker files with common logic
  # @param result [Hash] The result hash to update
  # @param message [String] Custom message to display about speaker files detection
  # @return [Hash] Updated result hash
  def process_named_speaker_files(result, message)
    @speaker_file_manager.process_named_speaker_files(result, message)
    wait_for_speaker_identification(skip: true)
    complete_processing(result)
  end
end
