require 'json'
require 'fileutils'
require 'open3'
require 'descriptive_statistics'
require_relative 'transcript_parser'
require_relative 'speaker_extraction'
require_relative 'speaker_identification'
require_relative '../csv_writer'

class TranscriptProcessor
  def initialize(transcript_path, audio_path)
    validate_inputs(transcript_path, audio_path)

    @transcript_path = transcript_path
    @audio_path = audio_path
    @parser = TranscriptParser.new(transcript_path)
    @base_filename = File.basename(audio_path, ".*")
    @output_dir = Dir.pwd
  end

  def process
    puts "Starting Amazon Transcribe processing script"

    # Check for existing named speaker files
    named_speaker_files = Dir.glob("spk_*_*.m4a")
    if named_speaker_files.any?
      puts "\nNamed speaker files detected. Skipping speaker audio extraction step."
      wait_for_speaker_identification(skip: true)
      generate_csv_transcript
      identify_segments_to_review
      puts "Processing complete!"
      return
    end

    # Check for existing unnamed speaker files
    unnamed_speaker_files = Dir.glob("spk_*.m4a") - named_speaker_files
    if unnamed_speaker_files.any?
      puts "\nUnnamed speaker files detected."
      puts "Please identify each speaker by renaming the audio files:"
      puts "  Example: rename 'spk_0.m4a' to 'spk_0_Alex.m4a' if the speaker is Alex"
      puts "\nType `go` and press enter after renaming the files..."
      until STDIN.gets.strip.downcase == "go"
        sleep 1
      end
      # After renaming, restart the process to check for named speaker files
      named_speaker_files = Dir.glob("spk_*_*.m4a")
      if named_speaker_files.any?
        puts "\nNamed speaker files detected after renaming. Skipping speaker audio extraction step."
        wait_for_speaker_identification(skip: true)
        generate_csv_transcript
        identify_segments_to_review
        puts "Processing complete!"
        return
      else
        puts "No named speaker files found after renaming. Exiting."
        exit 1
      end
    end

    # Step 1: Extract speaker audio
    extract_speaker_audio

    # Wait for user to identify speakers
    wait_for_speaker_identification

    # Step 2: Generate CSV transcript
    generate_csv_transcript

    # Step 3: Identify segments to review
    identify_segments_to_review

    puts "Processing complete!"
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
    stdout, stderr, status = Open3.capture3("ffmpeg -version")
    unless status.success?
      abort "Error: ffmpeg is not installed or not in PATH. Please install ffmpeg to continue."
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

    # Find speaker identifications from renamed files
    speaker_identities = {}
    Dir.glob("spk_*.m4a").each do |file|
      if file =~ /spk_(\d+)_(.+)\.m4a/
        speaker_label = "spk_#{$1}"
        speaker_name = $2
        speaker_identities[speaker_label] = speaker_name
      end
    end

    # Process transcript into rows
    rows = []
    current_row = nil
    csv_writer = CsvWriter.new(@output_dir)

    segments = @parser.audio_segments
    
    segments.each_with_index do |segment, index|
      result = csv_writer.process_segment(segment, index, current_row, speaker_identities, @parser)
      
      if result[:start_new_row]
        # Add the current row to our list if it exists
        rows << current_row if current_row

        # Start a new row
        current_row = {
          id: rows.size + 1,
          speaker: result[:speaker_name],
          transcript: result[:transcript_text],
          confidence_min: result[:min_conf],
          confidence_max: result[:max_conf],
          confidence_mean: result[:mean_conf],
          confidence_median: result[:median_conf],
          note: result[:note],
          start_time: result[:start_time],
          end_time: result[:end_time]
        }
      else
        # Append to the current row
        current_row[:transcript] += " " + result[:transcript_text]
        current_row[:end_time] = result[:end_time]
        current_row[:confidence_min] = [current_row[:confidence_min], result[:min_conf]].min
        current_row[:confidence_max] = [current_row[:confidence_max], result[:max_conf]].max

        # Recalculate mean and median with all values
        # This is a simplified approach - in a real implementation we'd need to track all values
        all_values = [result[:mean_conf], current_row[:confidence_mean]]
        current_row[:confidence_mean] = all_values.sum / all_values.size
        current_row[:confidence_median] = all_values.sort[all_values.size / 2]

        # Update note if needed
        if result[:note] == "error" || current_row[:note] == "error"
          current_row[:note] = "error"
        elsif result[:speaker_name] != current_row[:speaker] && current_row[:speaker] != ""
          current_row[:note] = "multiple speakers"
        end
      end
    end

    # Add the last row if it exists
    rows << current_row if current_row

    # Write to CSV
    csv_writer.write_transcript(rows, @base_filename)
    
    @rows = rows
  end

  def identify_segments_to_review
    puts "\n=== Step 3: Identifying segments to review ==="

    low_confidence_threshold = 0.75
    review_segments = @rows.select { |row| row[:confidence_mean] < low_confidence_threshold }

    if review_segments.empty?
      puts "No low-confidence segments found that require review."
      return
    end

    puts "The following segments have low confidence scores (below #{low_confidence_threshold}) and should be reviewed:"

    # Group consecutive IDs
    groups = []
    current_group = [review_segments.first[:id]]

    review_segments[1..-1].each do |segment|
      if segment[:id] == current_group.last + 1
        current_group << segment[:id]
      else
        groups << current_group
        current_group = [segment[:id]]
      end
    end
    groups << current_group unless current_group.empty?

    # Display groups
    groups.each do |group|
      if group.size == 1
        puts "  Segment ID: #{group.first}"
      else
        puts "  Segment IDs: #{group.first}-#{group.last}"
      end
    end
  end
end
