#!/usr/bin/env ruby

require 'json'
require 'csv'
require 'fileutils'
require 'open3'
require 'descriptive_statistics'
require_relative 'transcript_parser'

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

    num_speakers = @parser.speaker_count
    puts "Detected #{num_speakers} speakers in the transcript."

    speaker_segments = {}

    # Group segments by speaker
    @parser.audio_segments.each do |segment|
      speaker = segment["speaker_label"]
      speaker_segments[speaker] ||= []
      speaker_segments[speaker] << {
        start_time: segment["start_time"].to_f,
        end_time: segment["end_time"].to_f
      }
    end

    # Process each speaker
    speaker_segments.each_with_index do |(speaker, segments), index|
      puts "\nProcessing #{speaker} (#{index + 1}/#{speaker_segments.size})..."

      output_file = "#{speaker}.m4a"

      # Create a temporary file with segment timestamps
      temp_file = "#{speaker}_segments.txt"
      File.open(temp_file, "w") do |f|
        segments.each do |segment|
          f.puts "file '#{@audio_path}'"
          f.puts "inpoint #{segment[:start_time]}"
          f.puts "outpoint #{segment[:end_time]}"
        end
      end

      # Use ffmpeg to extract and concatenate segments
      cmd = "ffmpeg -f concat -safe 0 -i #{temp_file} -c copy #{output_file}"
      puts "  Extracting audio segments..."

      stdout, stderr, status = Open3.capture3(cmd)

      if status.success?
        puts "  Successfully created #{output_file}"
        puts "  Total segments: #{segments.size}"
        total_duration = segments.sum { |s| s[:end_time] - s[:start_time] }
        puts "  Total duration: #{total_duration.round(2)} seconds"
      else
        puts "  Error creating audio file for #{speaker}: #{stderr}"
      end

      # Clean up temp file
      FileUtils.rm(temp_file)
    end

    puts "\nSpeaker audio extraction complete!"
  end

  def wait_for_speaker_identification(skip: false)
    return if skip
    
    puts "\n=== Speaker Identification ==="
    puts "Please identify each speaker by renaming the audio files:"
    puts "  Example: rename 'spk_0.m4a' to 'spk_0_John.m4a' if the speaker is John"
    puts "\nType `go` and press enter when you have finished identifying speakers..."
    until STDIN.gets.match("go")
      sleep 1
    end
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

    # Determine output CSV filename
    output_filename = "transcript.csv"
    index = 1

    while File.exist?(File.join(@output_dir, output_filename))
      output_filename = "transcript.#{index}.csv"
      index += 1
    end

    csv_filename = output_filename

    # Process transcript into rows
    rows = []
    current_row = nil
    error_count = 0

    segments = @parser.audio_segments
    total_segments = segments.size

    segments.each_with_index do |segment, index|
      begin
        # Print progress
        progress = ((index + 1).to_f / total_segments * 100).round(1)
        print "\rProcessing segment #{index + 1}/#{total_segments} (#{progress}%)..."

        speaker_label = segment["speaker_label"]
        speaker_name = speaker_identities[speaker_label] || ""
        transcript_text = segment["transcript"]

        # Get confidence values for this segment
        confidence_values = []
        segment["items"].each do |item_id|
          item = @parser.items.find { |i| i["id"].to_s == item_id.to_s }
          if item && item.dig("alternatives", 0, "confidence")
            confidence_values << item.dig("alternatives", 0, "confidence").to_f
          end
        end

        # Calculate confidence statistics
        if confidence_values.empty?
          min_conf = max_conf = mean_conf = median_conf = 0.0
          note = "error"
          error_count += 1
        else
          min_conf = confidence_values.min
          max_conf = confidence_values.max
          mean_conf = confidence_values.sum / confidence_values.size
          median_conf = confidence_values.sort[confidence_values.size / 2]
          note = ""
          error_count = 0
        end

        # Determine if we need a new row
        start_new_row = false

        if current_row.nil?
          start_new_row = true
        elsif current_row[:speaker] != speaker_name
          start_new_row = true
        elsif segment["start_time"].to_f - current_row[:end_time] > 1.0
          # More than 1 second of silence
          start_new_row = true
        end

        if start_new_row
          # Add the current row to our list if it exists
          rows << current_row if current_row

          # Start a new row
          current_row = {
            id: rows.size + 1,
            speaker: speaker_name,
            transcript: transcript_text,
            confidence_min: min_conf,
            confidence_max: max_conf,
            confidence_mean: mean_conf,
            confidence_median: median_conf,
            note: note,
            start_time: segment["start_time"].to_f,
            end_time: segment["end_time"].to_f
          }
        else
          # Append to the current row
          current_row[:transcript] += " " + transcript_text
          current_row[:end_time] = segment["end_time"].to_f
          current_row[:confidence_min] = [current_row[:confidence_min], min_conf].min
          current_row[:confidence_max] = [current_row[:confidence_max], max_conf].max

          # Recalculate mean and median with all values
          all_values = confidence_values + [current_row[:confidence_mean]] * (current_row[:id] - rows.size)
          current_row[:confidence_mean] = all_values.sum / all_values.size
          current_row[:confidence_median] = all_values.sort[all_values.size / 2]

          # Update note if needed
          if note == "error" || current_row[:note] == "error"
            current_row[:note] = "error"
          elsif speaker_name != current_row[:speaker] && current_row[:speaker] != ""
            current_row[:note] = "multiple speakers"
          end
        end

        # Check for consecutive errors
        if error_count >= 3
          puts "\nEncountered 3 consecutive errors. Details:"
          3.times do |i|
            puts "Error #{i+1}: Failed to process segment #{index-2+i}"
          end
          abort "Aborting due to multiple consecutive errors."
        end

      rescue => e
        puts "\nError processing segment #{index}: #{e.message}"
        error_count += 1
        if error_count >= 3
          abort "Aborting due to multiple consecutive errors."
        end
      end
    end

    # Add the last row if it exists
    rows << current_row if current_row

    # Write to CSV
    puts "\nWriting transcript to #{csv_filename}..."
    puts "Transcript saved as #{csv_filename}."
    CSV.open(csv_filename, "w") do |csv|
      # Write header
      csv << ["ID", "Speaker", "Transcript", "Confidence Min", "Confidence Max", "Confidence Mean", "Confidence Median", "Note"]

      # Write rows
      rows.each do |row|
        csv << [
          row[:id],
          row[:speaker],
          row[:transcript],
          row[:confidence_min].round(3),
          row[:confidence_max].round(3),
          row[:confidence_mean].round(3),
          row[:confidence_median].round(3),
          row[:note]
        ]
      end
    end

    puts "CSV transcript generation complete!"
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

# Main execution
if ARGV.size != 1
  puts "Usage: #{$0} <input_directory>"
  exit 1
end

directory_path = ARGV[0]

unless Dir.exist?(directory_path)
  abort "Error: Directory '#{directory_path}' not found or inaccessible."
end

# Set the working directory to the provided directory
Dir.chdir(directory_path)

# Find the largest audio file
audio_files = Dir.glob(["*.wav", "*.mp3", "*.m4a", "*.aac", "*.flac"].flat_map { |ext| [ext.downcase, ext.upcase] })
if audio_files.empty?
  abort "Error: No audio files found in directory '#{directory_path}'."
end

audio_path = audio_files.max_by { |f| File.size(f) }
puts "Using largest audio file: #{audio_path}"

# Find the transcript file
transcript_path = File.join(directory_path, "asrOutput.json")
unless File.exist?(transcript_path)
  abort "Error: Transcript file 'asrOutput.json' not found in directory '#{directory_path}'."
end

processor = TranscriptProcessor.new(transcript_path, audio_path)
processor.process
