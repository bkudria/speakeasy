class MisalignmentDetector
  def initialize(rows, options = {})
    # Validate input types first
    raise ArgumentError, "Rows must be an array" unless rows.is_a?(Array)
    raise ArgumentError, "Options must be a hash" unless options.is_a?(Hash)
    
    @rows = rows
    @options = options
    @min_confidence_threshold = options[:min_confidence_threshold] || 0.6
    @confidence_drop_threshold = options[:confidence_drop_threshold] || 0.2
    @significant_pause_threshold = options[:significant_pause_threshold] || 1.5
    @min_sentence_overlap = options[:min_sentence_overlap] || 3
  end

  # Main entry point to run the misalignment detection
  def detect_issues
    # Early return for empty input
    return [] if @rows.empty?
    
    issues = []

    # Run all check methods and aggregate results
    check_methods = [
      :check_sentence_boundaries,
      :check_speaker_labels,
      :check_word_confidence,
      :check_pause_silences,
      :check_time_adjacency,
      :check_cross_speaker_transitions,
      :check_aggregated_confidence_drops
    ]

    check_methods.each do |method|
      begin
        method_issues = send(method)
        issues.concat(method_issues) if method_issues.is_a?(Array)
      rescue => e
        puts "Warning: Error in #{method}: #{e.message}"
        puts e.backtrace[0..2].join("\n") if ENV["DEBUG"]
      end
    end

    # Remove duplicates and sort by row_id
    issues.uniq { |issue| [issue[:row_id], issue[:issue_type]] }.sort_by { |issue| issue[:row_id] }
  end

  private

  def check_sentence_boundaries
    issues = []
    
    @rows.each_with_index do |row, index|
      next if index == @rows.size - 1  # Skip last row
      
      current_transcript = row[:transcript].to_s
      next_transcript = @rows[index + 1][:transcript].to_s
      
      # Check if current row ends with incomplete sentence
      # Look for sentences that end without proper punctuation
      if !current_transcript.empty? && 
         !current_transcript.match?(/[.!?…]["')]?$/) && 
         @rows[index + 1][:speaker] != row[:speaker]
        
        # Check if next sentence starts with lowercase (continuation)
        if !next_transcript.empty? && next_transcript.match?(/^\s*[a-z]/)
          issues << {
            row_id: row[:id],
            issue_type: :incomplete_sentence,
            description: "Sentence appears to continue in the next segment with different speaker"
          }
        end
        
        # Check if transcript ends with a conjunction or preposition
        if current_transcript.match?(/\b(and|but|or|because|if|as|that|for|with|to|in|on|at)\s*$/)
          issues << {
            row_id: row[:id],
            issue_type: :incomplete_sentence,
            description: "Transcript ends with conjunction or preposition"
          }
        end
      end
    end
    
    issues
  end

  def check_speaker_labels
    issues = []
    
    @rows.each_with_index do |row, index|
      next if index == @rows.size - 1  # Skip last row
      next_row = @rows[index + 1]
      
      # Check for suspiciously short segments with same speaker on both sides
      if index > 0 && 
         row[:speaker] != @rows[index - 1][:speaker] && 
         row[:speaker] != next_row[:speaker] &&
         @rows[index - 1][:speaker] == next_row[:speaker] &&
         (row[:end_time] - row[:start_time]) < 1.0 &&
         row[:confidence_mean] < @rows[index - 1][:confidence_mean] - 0.1
        
        issues << {
          row_id: row[:id],
          issue_type: :potential_speaker_mismatch,
          description: "Short segment with different speaker surrounded by same speaker segments"
        }
      end
      
      # Check for unusual confidence drops with same speaker
      if row[:speaker] == next_row[:speaker] &&
         row[:confidence_mean] > 0.8 &&
         next_row[:confidence_mean] < 0.7
        
        issues << {
          row_id: next_row[:id],
          issue_type: :potential_speaker_mismatch,
          description: "Significant confidence drop between segments with same speaker"
        }
      end
    end
    
    issues
  end

  def check_word_confidence
    issues = []
    
    @rows.each do |row|
      # Skip rows without confidence metrics
      next unless row[:confidence_min] && row[:confidence_max] && row[:confidence_mean]
      
      # Check for segments with very low minimum confidence but high maximum
      if row[:confidence_min] < @min_confidence_threshold && 
         (row[:confidence_max] - row[:confidence_min]) > 0.4
        
        add_issue(
          issues,
          row[:id],
          :suspicious_confidence_pattern,
          "Large variance in word confidence (min: #{row[:confidence_min].round(2)}, max: #{row[:confidence_max].round(2)})"
        )
      end
      
      # Check for segments where mean is far from median (skewed distribution)
      if row[:confidence_median] && 
         (row[:confidence_mean] - row[:confidence_median]).abs > 0.15
        
        add_issue(
          issues,
          row[:id],
          :suspicious_confidence_pattern,
          "Skewed confidence distribution (mean: #{row[:confidence_mean].round(2)}, median: #{row[:confidence_median].round(2)})"
        )
      end
    end
    
    issues
  end

  def check_pause_silences
    issues = []
    
    @rows.each_with_index do |row, index|
      next if index == 0  # Skip first row
      prev_row = @rows[index - 1]
      
      # Check for long pauses between segments with same speaker
      if row[:speaker] == prev_row[:speaker] && 
         row[:start_time] && prev_row[:end_time] &&
         (row[:start_time] - prev_row[:end_time]) > @significant_pause_threshold
        
        add_issue(issues, row[:id], :potential_missed_segmentation, 
          "Long pause (#{(row[:start_time] - prev_row[:end_time]).round(2)}s) between segments with same speaker")
      end
      
      # Check for very short segments that might be noise
      if (row[:end_time] - row[:start_time]) < 0.3 && 
         row[:confidence_mean] && row[:confidence_mean] < 0.7
        
        add_issue(issues, row[:id], :potential_noise_segment,
          "Very short segment (#{(row[:end_time] - row[:start_time]).round(2)}s) with low confidence")
      end
    end
    
    issues
  end

  def check_time_adjacency
    issues = []
    
    @rows.each_with_index do |row, index|
      next if index == 0  # Skip first row
      prev_row = @rows[index - 1]
      
      # Check for overlapping segments
      if row[:start_time] && prev_row[:end_time] &&
         row[:start_time] < prev_row[:end_time]
        
        overlap_duration = prev_row[:end_time] - row[:start_time]
        
        issues << {
          row_id: row[:id],
          issue_type: :segment_overlap,
          description: "Segment overlaps with previous by #{overlap_duration.round(2)}s"
        }
      end
      
      # Check for unusually large gaps (not already caught by pause detection)
      if row[:start_time] && prev_row[:end_time] && 
         row[:speaker] != prev_row[:speaker] &&
         (row[:start_time] - prev_row[:end_time]) > 2.0
        
        add_issue(issues, row[:id], :large_time_gap,
          "Large gap (#{(row[:start_time] - prev_row[:end_time]).round(2)}s) between different speakers")
      end
    end
    
    issues
  end

  def check_cross_speaker_transitions
    issues = []
    
    # Need at least 3 rows to check transitions
    return issues if @rows.size < 3
    
    (1...(@rows.size - 1)).each do |i|
      prev_row = @rows[i - 1]
      curr_row = @rows[i]
      next_row = @rows[i + 1]
      
      # Check for A → B → A pattern with suspicious timing or confidence
      if prev_row[:speaker] == next_row[:speaker] && 
         curr_row[:speaker] != prev_row[:speaker]
        
        # Very short middle segment
        if (curr_row[:end_time] - curr_row[:start_time]) < 1.0
          issues << {
            row_id: curr_row[:id],
            issue_type: :suspicious_speaker_transition,
            description: "Short segment interrupts same speaker (#{prev_row[:speaker]} → #{curr_row[:speaker]} → #{next_row[:speaker]})"
          }
        end
        
        # Low confidence middle segment
        if curr_row[:confidence_mean] && 
           prev_row[:confidence_mean] && 
           next_row[:confidence_mean] &&
           curr_row[:confidence_mean] < prev_row[:confidence_mean] - 0.15 &&
           curr_row[:confidence_mean] < next_row[:confidence_mean] - 0.15
          
          issues << {
            row_id: curr_row[:id],
            issue_type: :suspicious_speaker_transition,
            description: "Low confidence segment interrupts same speaker with higher confidence"
          }
        end
      end
      
      # Check for rapid back-and-forth between speakers
      if i >= 2 && i < @rows.size - 2
        if @rows[i - 2][:speaker] == curr_row[:speaker] &&
           @rows[i - 1][:speaker] == next_row[:speaker] &&
           @rows[i - 1][:speaker] != curr_row[:speaker]
          
          issues << {
            row_id: curr_row[:id],
            issue_type: :rapid_speaker_alternation,
            description: "Rapid alternation between speakers may indicate misattribution"
          }
        end
      end
    end
    
    issues
  end

  def check_aggregated_confidence_drops
    issues = []
    
    @rows.each_with_index do |row, index|
      next if index == 0  # Skip first row
      prev_row = @rows[index - 1]
      
      # Skip if missing confidence data
      next unless row[:confidence_mean] && prev_row[:confidence_mean]
      
      # Check for significant confidence drops with same speaker
      if row[:speaker] == prev_row[:speaker] && 
         (prev_row[:confidence_mean] - row[:confidence_mean]) > @confidence_drop_threshold
        
        add_issue(issues, row[:id], :significant_confidence_drop,
          "Confidence dropped by #{(prev_row[:confidence_mean] - row[:confidence_mean]).round(2)} from previous segment with same speaker")
      end
      
      # Check for anomalous confidence patterns in context
      if index >= 2 && index < @rows.size - 1
        context_rows = @rows[(index-2)..(index+1)].select { |r| r[:confidence_mean] }
        context_confidences = context_rows.map { |r| r[:confidence_mean] }
        
        if context_confidences.size >= 3
          avg_context = context_confidences.sum / context_confidences.size
          
          # Current row has much lower confidence than context average
          if (avg_context - row[:confidence_mean]) > 0.25
            issues << {
              row_id: row[:id],
              issue_type: :contextual_confidence_anomaly,
              description: "Segment confidence (#{row[:confidence_mean].round(2)}) significantly lower than surrounding context (#{avg_context.round(2)})"
            }
          end
        end
      end
    end
    
    issues
  end

  # Helper method to add an issue to the issues array
  def add_issue(issues, row_id, issue_type, description)
    issues << {
      row_id: row_id,
      issue_type: issue_type,
      description: description
    }
  end
end