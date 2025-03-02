class LowConfidenceDetector
  def initialize(threshold: 0.75)
    @threshold = threshold
  end

  def identify_segments_to_review(rows)
    review_segments = find_low_confidence_segments(rows)

    if review_segments.empty?
      puts "No low-confidence segments found that require review."
      return
    end

    puts "The following segments have low confidence scores (below #{@threshold}) and should be reviewed:"

    # Group consecutive IDs
    groups = group_consecutive_segments(review_segments)

    # Display groups
    display_segment_groups(groups)
  end

  def find_low_confidence_segments(rows)
    rows.select { |row| row[:confidence_mean] < @threshold }
  end

  private

  def group_consecutive_segments(segments)
    return [] if segments.empty?

    groups = []
    current_group = [segments.first[:id]]

    segments[1..-1].each do |segment|
      if segment[:id] == current_group.last + 1
        current_group << segment[:id]
      else
        groups << current_group
        current_group = [segment[:id]]
      end
    end
    groups << current_group unless current_group.empty?

    groups
  end

  def display_segment_groups(groups)
    groups.each do |group|
      if group.size == 1
        puts "  Segment ID: #{group.first}"
      else
        puts "  Segment IDs: #{group.first}-#{group.last}"
      end
    end
  end
end
