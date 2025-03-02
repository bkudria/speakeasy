require 'csv'

class CsvWriter
  def initialize(output_dir)
    @output_dir = output_dir
    @error_count = 0
  end
  
  def write_transcript(rows, base_filename = "transcript")
    csv_filename = generate_unique_filename(base_filename)
    
    # Write to CSV
    puts "\nWriting transcript to #{csv_filename}..."
    
    CSV.open(csv_filename, "w") do |csv|
      # Write header row
      csv << ["ID", "Speaker", "Transcript", "Confidence Min", "Confidence Max", "Confidence Mean", "Confidence Median", "Note"]
      
      # Write data rows
      rows.each do |row|
        if row[:note] == "error"
          @error_count += 1
          if @error_count >= 3
            puts "Three consecutive errors encountered. Aborting."
            exit(1)
          end
        else
          @error_count = 0
        end
        
        csv << [
          row[:id].to_s,
          row[:speaker].to_s,
          row[:transcript].to_s,
          format_confidence(row[:confidence_min]),
          format_confidence(row[:confidence_max]),
          format_confidence(row[:confidence_mean]),
          format_confidence(row[:confidence_median]),
          row[:note].to_s
        ]
      end
    end
    
    puts "CSV transcript generation complete!"
    puts "Transcript saved as #{csv_filename}."
    
    return csv_filename
  end
  
  def process_segment(segment, index, current_row, speaker_identities, parser)
    begin
      # Print progress
      total_segments = parser.audio_segments.size
      progress = ((index + 1).to_f / total_segments * 100).round(1)
      print "\rProcessing segment #{index + 1}/#{total_segments} (#{progress}%)..."

      speaker_label = segment["speaker_label"]
      speaker_name = speaker_identities[speaker_label] || ""
      transcript_text = segment["transcript"]

      # Get confidence values for this segment
      confidence_values = []
      segment["items"].each do |item_id|
        item = parser.items.find { |i| i["id"].to_s == item_id.to_s }
        if item && item.dig("alternatives", 0, "confidence")
          confidence_values << item.dig("alternatives", 0, "confidence").to_f
        end
      end

      # Calculate confidence statistics
      if confidence_values.empty?
        min_conf = max_conf = mean_conf = median_conf = 0.0
        note = "error"
        @error_count += 1
      else
        min_conf = confidence_values.min
        max_conf = confidence_values.max
        mean_conf = confidence_values.sum / confidence_values.size
        median_conf = confidence_values.sort[confidence_values.size / 2]
        note = ""
        @error_count = 0
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

      # Check for consecutive errors
      if @error_count >= 3
        puts "\nEncountered 3 consecutive errors. Details:"
        3.times do |i|
          puts "Error #{i+1}: Failed to process segment #{index-2+i}"
        end
        abort "Aborting due to multiple consecutive errors."
      end

      return {
        start_new_row: start_new_row,
        speaker_name: speaker_name,
        transcript_text: transcript_text,
        min_conf: min_conf,
        max_conf: max_conf,
        mean_conf: mean_conf,
        median_conf: median_conf,
        note: note,
        start_time: segment["start_time"].to_f,
        end_time: segment["end_time"].to_f
      }

    rescue => e
      puts "\nError processing segment #{index}: #{e.message}"
      @error_count += 1
      if @error_count >= 3
        abort "Aborting due to multiple consecutive errors."
      end
      
      return {
        start_new_row: true,
        speaker_name: "",
        transcript_text: "",
        min_conf: 0.0,
        max_conf: 0.0,
        mean_conf: 0.0,
        median_conf: 0.0,
        note: "error",
        start_time: segment["start_time"].to_f,
        end_time: segment["end_time"].to_f
      }
    end
  end
  
  def reset_error_count
    @error_count = 0
  end
  
  private
  
  def generate_unique_filename(base_filename)
    filename = File.join(@output_dir, "#{base_filename}.csv")
    counter = 1
    
    while File.exist?(filename)
      filename = File.join(@output_dir, "#{base_filename}.#{counter}.csv")
      counter += 1
    end
    
    filename
  end
  
  def format_confidence(value)
    return "" if value.nil?
    value.round(2).to_s
  end
end
