class SpeakerExtraction
  def initialize(parser, audio_path, output_dir)
    @parser = parser
    @audio_path = audio_path
    @output_dir = output_dir
  end

  def extract
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
      cmd = "ffmpeg -hide_banner -loglevel error -y -f concat -safe 0 -i #{temp_file} -c copy #{output_file}"
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
end
