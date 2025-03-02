class CsvGenerator
  def initialize
    # Add needed parameters (e.g.: parser, options) in later steps
  end

  def build_row(segment)
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
    sorted.size.odd? ? sorted[mid] : (sorted[mid-1] + sorted[mid]) / 2.0
  end
end
