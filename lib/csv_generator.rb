class CsvGenerator
  def initialize
    # Add needed parameters (e.g.: parser, options) in later steps
    @error_count = 0
  end

  def process_segment(segment, index, current_row, speaker_identities, parser)
    # TODO: document how consecutive errors are handled and how it's used

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
      if item&.dig("alternatives", 0, "confidence")
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
        puts "Error #{i + 1}: Failed to process segment #{index - 2 + i}"
      end
      abort "Aborting due to multiple consecutive errors."
    end

    {
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

    {
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

  def build_row(segment)
    # Early return for error/empty segments
    if segment[:has_error] || segment[:items].nil? || segment[:items].empty?
      return {
        id: segment[:id],
        speaker: segment[:speaker],
        transcript: segment[:transcript],
        confidence_min: nil,
        confidence_max: nil,
        confidence_mean: nil,
        confidence_median: nil,
        note: "error"
      }
    end

    # Example logic for computing confidence metrics, etc.
    confidence_values = segment[:items].map { |i| i[:confidence].to_f }
    note_value = determine_note(segment)
    {
      id: segment[:id],
      speaker: segment[:speaker],
      transcript: segment[:transcript],
      confidence_min: confidence_values.min,
      confidence_max: confidence_values.max,
      confidence_mean: (confidence_values.sum / confidence_values.size).round(3),
      confidence_median: median(confidence_values),
      note: note_value
    }
  end

  private

  def determine_note(segment)
    # Example: "multiple speakers", "unknown", "error"
    # Replace this placeholder with your actual logic
    return "error" if segment[:has_error]
    return "multiple speakers" if segment[:speaker_count] > 1
    "unknown"
  end

  def median(values)
    sorted = values.sort
    mid = sorted.size / 2
    sorted.size.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2.0
  end
end
