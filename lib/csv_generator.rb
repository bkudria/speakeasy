class CsvGenerator
  def initialize
    # Add needed parameters (e.g.: parser, options) in later steps
    @error_count = 0
  end
  
  def group_items_by_speaker(items, silence_threshold: 1.0)
    return [] if items.empty?
    
    groups = []
    current_group = nil
    
    items.each do |item|
      # Skip items with no content
      next unless item[:content]
      
      # Start a new group if:
      # 1. This is the first item
      # 2. The speaker changed
      # 3. There's a significant silence gap
      start_new_group = current_group.nil? ||
                        (item[:speaker_label] && current_group[:speaker_label] && 
                         item[:speaker_label] != current_group[:speaker_label]) ||
                        (item[:start_time] && current_group[:end_time] && 
                         item[:start_time] - current_group[:end_time] > silence_threshold)
      
      # For punctuation, don't start a new group
      start_new_group = false if item[:type] == "punctuation"
      
      if start_new_group && item[:type] != "punctuation"
        # Create a new group
        current_group = {
          speaker_label: item[:speaker_label],
          items: [],
          start_time: item[:start_time],
          end_time: item[:end_time],
          transcript: ""
        }
        groups << current_group
      end
      
      # Add the item to the current group
      if current_group
        current_group[:items] << item
        
        # Update end_time if this item has one
        current_group[:end_time] = item[:end_time] if item[:end_time]
        
        # Update transcript
        if current_group[:transcript].empty?
          current_group[:transcript] = item[:content]
        else
          # Add space before word, but not before punctuation
          if item[:type] == "punctuation"
            current_group[:transcript] += item[:content]
          else
            current_group[:transcript] += " " + item[:content]
          end
        end
      end
    end
    
    groups
  end

  def process_segment(segment, index, current_row, speaker_identities, parser)
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

    # When a segment is invalid, note is set to "error". If we detect 3 consecutive
    # errors, we provide details on each prior error and terminate the program.
    # This ensures serious or recurring issues are caught early.
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

  def detect_natural_pauses(items, time_gap_threshold: 1.5)
    pauses = []
    
    items.each_with_index do |item, index|
      # Check for time gaps between words
      if index < items.size - 1 && item[:type] != "punctuation"
        next_item = items[index + 1]
        
        # Check for time gaps between current item and next item
        if item[:end_time] && next_item[:start_time] && 
           (next_item[:start_time] - item[:end_time] >= time_gap_threshold)
          pauses << { index: index, type: :time_gap }
        end
      end
      
      # Check for punctuation that indicates sentence endings or natural breaks
      if item[:type] == "punctuation"
        case item[:content]
        when ".", "!", "?"
          pauses << { index: index, type: :sentence_end }
        when ",", ";", ":"
          pauses << { index: index, type: :natural_break }
        end
      end
    end
    
    pauses
  end

  def calculate_confidence_metrics(items)
    # Extract valid confidence values
    confidence_values = items.map { |item| item[:confidence] }.compact.map(&:to_f)
    
    # Return nil for all metrics if there are no valid values
    if confidence_values.empty?
      return { min: nil, max: nil, mean: nil, median: nil }
    end
    
    # Calculate metrics
    {
      min: confidence_values.min,
      max: confidence_values.max,
      mean: confidence_values.sum / confidence_values.size,
      median: median(confidence_values)
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

    # Use calculate_confidence_metrics for confidence calculations
    confidence_metrics = calculate_confidence_metrics(segment[:items])
    note_value = determine_note(segment)
    
    {
      id: segment[:id],
      speaker: segment[:speaker],
      transcript: segment[:transcript],
      confidence_min: confidence_metrics[:min],
      confidence_max: confidence_metrics[:max],
      confidence_mean: confidence_metrics[:mean],
      confidence_median: confidence_metrics[:median],
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
