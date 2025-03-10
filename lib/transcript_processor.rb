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
    named_speaker_files = Dir.glob(File.join(@output_dir, "spk_*_*.m4a"))
    if named_speaker_files.any?
      puts "\nNamed speaker files detected. Skipping speaker audio extraction step."
      result[:speakers_extracted] = true
      wait_for_speaker_identification(skip: true)
      generate_csv_transcript
      result[:csv_generated] = true
      identify_segments_to_review
      result[:misalignments_detected] = @misalignments_detected || false
      puts "Processing complete!"
      return result
    end

    # Check for existing unnamed speaker files
    unnamed_speaker_files = Dir.glob(File.join(@output_dir, "spk_*.m4a")) - named_speaker_files
    if unnamed_speaker_files.any?
      puts "\nUnnamed speaker files detected."
      puts "Please identify each speaker by renaming the audio files:"
      puts "  Example: rename 'spk_0.m4a' to 'spk_0_Alex.m4a' if the speaker is Alex"
      puts "\nType `go` and press enter after renaming the files..."
      until @input.gets.strip.downcase == "go"
        sleep 1
      end
      # After renaming, restart the process to check for named speaker files
      named_speaker_files = Dir.glob(File.join(@output_dir, "spk_*_*.m4a"))
      if named_speaker_files.any?
        puts "\nNamed speaker files detected after renaming. Skipping speaker audio extraction step."
        result[:speakers_extracted] = true
        wait_for_speaker_identification(skip: true)
        generate_csv_transcript
        result[:csv_generated] = true
        identify_segments_to_review
        result[:misalignments_detected] = @misalignments_detected || false
        puts "Processing complete!"
        return result
      else
        puts "No named speaker files found after renaming. Exiting."
        exit 1
      end
    end

    # Step 1: Extract speaker audio
    extract_speaker_audio
    result[:speakers_extracted] = true

    # Wait for user to identify speakers
    wait_for_speaker_identification

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

  private

  def validate_inputs(transcript_path, audio_path)
    # Check if files exist
    unless File.exist?(transcript_path)
      abort "Error: Transcript file '#{transcript_path}' not found."
    end

    unless File.exist?(audio_path)
      abort "Error: Audio file '#{audio_path}' not found."
    end

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

  def identify_segments_to_review
    puts "\n=== Step 3: Identifying segments to review ==="
    begin
      detector = LowConfidenceDetector.new
      detector.identify_segments_to_review(@rows)
    rescue => e
      puts "Error identifying segments to review: #{e.message}"
      puts e.backtrace.join("\n") if ENV["DEBUG"]
      @error_count += 1
    end
  end

  def extract_speaker_audio
    puts "\n=== Step 1: Extracting speaker audio ==="
    SpeakerExtraction.new(@parser, @audio_path, @output_dir).extract
  end

  def wait_for_speaker_identification(skip: false)
    SpeakerIdentification.new(@parser, @audio_path, @output_dir).identify(skip: skip)
  end

  def generate_csv_transcript
    puts "\n=== Step 2: Generating CSV transcript ==="

    # Open the directory for the user to rename files
    open_output_directory

    # Find speaker identifications from renamed files
    speaker_identities = {}
    begin
      Dir.glob(File.join(@output_dir, "spk_*_*.m4a")).each do |file|
        if file =~ /spk_(\d+)_(.+)\.m4a/
          speaker_label = "spk_#{$1}"
          speaker_name = $2
          speaker_identities[speaker_label] = speaker_name
        end
      end
    rescue => e
      puts "Error processing speaker identity files: #{e.message}"
      puts e.backtrace.join("\n") if ENV["DEBUG"]
      @error_count += 1
    end

    # Process transcript into rows using the new item-based approach
    csv_writer = CsvWriter.new(@output_dir)
    csv_gen = CsvGenerator.new

    # Get parsed items from the parser
    parsed_items = @parser.parsed_items || []

    begin
      # Process the parsed items using the new method
      rows = csv_gen.process_parsed_items(parsed_items, speaker_identities, silence_threshold: 1.0)

      # Detect and correct misalignments
      begin
        misalignment_issues = MisalignmentDetector.new(rows).detect_issues
        # Store if misalignments were detected in the instance variable
        @misalignments_detected = !misalignment_issues.empty?
      rescue => e
        puts "Error detecting misalignments: #{e.message}"
        puts e.backtrace.join("\n") if ENV["DEBUG"]
        @error_count += 1
        misalignment_issues = []
        @misalignments_detected = false
      end

      begin
        MisalignmentCorrector.new(rows, misalignment_issues).correct!
      rescue => e
        puts "Error correcting misalignments: #{e.message}"
        puts e.backtrace.join("\n") if ENV["DEBUG"]
        @error_count += 1
      end

      # Write to CSV
      begin
        csv_writer.write_transcript(rows, @csv_base_name)
      rescue => e
        puts "Error writing CSV transcript: #{e.message}"
        puts e.backtrace.join("\n") if ENV["DEBUG"]
        @error_count += 1
      end

      @rows = rows
    rescue => e
      puts "Error processing transcript items: #{e.message}"
      puts e.backtrace.join("\n") if ENV["DEBUG"]
      @error_count += 1
      @rows = []
    end
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
end
