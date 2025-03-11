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

class TranscriptProcessor
  def initialize(transcript_path, audio_path, input: $stdin, output_dir: Dir.pwd)
    validate_inputs(transcript_path, audio_path)

    @transcript_path = transcript_path
    @audio_path = audio_path
    @parser = TranscriptParser.new(transcript_path)
    @csv_base_name = File.basename(transcript_path, ".*")
    @output_dir = output_dir
    @input = input
    @error_count = 0
    @rows = []
    @misalignments_detected = false
  end

  # Get named speaker files from output directory
  # @return [Array] List of named speaker files
  def get_named_speaker_files
    Dir.glob(File.join(@output_dir, "spk_*_*.m4a"))
  end
  
  # Get unnamed speaker files from output directory
  # @param named_files [Array] List of named speaker files to exclude
  # @return [Array] List of unnamed speaker files
  def get_unnamed_speaker_files(named_files)
    Dir.glob(File.join(@output_dir, "spk_*.m4a")) - named_files
  end
  
  # Handle unnamed speaker files by prompting user to rename them
  # @param result [Hash] The result hash to update
  # @return [Boolean] Whether to continue processing or exit
  def handle_unnamed_speaker_files(result)
    puts "\nUnnamed speaker files detected."
    puts "Please identify each speaker by renaming the audio files:"
    puts "  Example: rename 'spk_0.m4a' to 'spk_0_Alex.m4a' if the speaker is Alex"
    puts "\nType `go` and press enter after renaming the files..."
    until @input.gets.strip.downcase == "go"
      sleep 1
    end
    
    # After renaming, check for named speaker files again
    named_speaker_files = get_named_speaker_files
    if named_speaker_files.any?
      process_named_speaker_files(result, "Named speaker files detected after renaming. Skipping speaker audio extraction step.")
      return false # Don't continue processing in the caller
    else
      puts "No named speaker files found after renaming. Exiting."
      exit 1
    end
  end

  def process
    puts "Starting Amazon Transcribe processing script"
    
    # Initialize result hash to track processing status
    result = {
      csv_generated: false,
      speakers_extracted: false,
      misalignments_detected: false
    }

    # Check for existing named speaker files
    # If we detect any files matching "spk_*_*.m4a", we assume the user has already
    # named the speakers, so we skip extraction. Otherwise, we look for unnamed
    # speaker files ("spk_#.m4a"), prompt the user to rename them, and then retry.
    named_speaker_files = get_named_speaker_files
    if named_speaker_files.any?
      return process_named_speaker_files(result, "Named speaker files detected. Skipping speaker audio extraction step.")
    end

    # Check for existing unnamed speaker files
    unnamed_speaker_files = get_unnamed_speaker_files(named_speaker_files)
    if unnamed_speaker_files.any?
      return if handle_unnamed_speaker_files(result) == false
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

  # Validate that a required file exists
  # @param file_path [String] Path to the file
  # @param file_type [String] Type of file for error message
  def validate_file_exists(file_path, file_type)
    unless File.exist?(file_path)
      abort "Error: #{file_type} file '#{file_path}' not found."
    end
  end

  def validate_inputs(transcript_path, audio_path)
    # Check if files exist
    validate_file_exists(transcript_path, "Transcript")
    validate_file_exists(audio_path, "Audio")

    # Validate JSON format
    begin
      JSON.parse(File.read(transcript_path))
    rescue JSON::ParserError => e
      abort "Error: Invalid JSON format in transcript file: #{e.message}"
    end

    # Check if ffmpeg is available
    _, _, status = Open3.capture3("ffmpeg -version")
    unless status.success?
      abort "Error: ffmpeg is not installed or not in PATH. Please install ffmpeg to continue."
    end
  end

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
    speaker_identities = {}
    handle_error("processing speaker identity files") do
      Dir.glob(File.join(@output_dir, "spk_*_*.m4a")).each do |file|
        if file =~ /spk_(\d+)_(.+)\.m4a/
          speaker_label = "spk_#{$1}"
          speaker_name = $2
          speaker_identities[speaker_label] = speaker_name
        end
      end
    end
    speaker_identities
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

  # Reusable error handling method
  # @param operation_description [String] Description of the operation being performed
  # @param default_value [Object] Optional default value to return on error
  # @yield The block of code to execute
  # @return [Object] Result of the block if successful, default_value if error
  def handle_error(operation_description, default_value = nil)
    begin
      yield
    rescue => e
      puts "Error #{operation_description}: #{e.message}"
      puts e.backtrace.join("\n") if ENV["DEBUG"]
      @error_count += 1
      default_value
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
    puts "\n#{message}"
    result[:speakers_extracted] = true
    wait_for_speaker_identification(skip: true)
    complete_processing(result)
  end
end