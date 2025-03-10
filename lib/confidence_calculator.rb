class ConfidenceCalculator
  def self.calculate_metrics(items)
    # Extract valid confidence values
    confidence_values = items.map { |item| item[:confidence] }.compact.map(&:to_f)

    # Return nil for all metrics if there are no valid values
    if confidence_values.empty?
      return {min: nil, max: nil, mean: nil, median: nil}
    end

    # Calculate metrics
    {
      min: confidence_values.min,
      max: confidence_values.max,
      mean: confidence_values.sum / confidence_values.size,
      median: median(confidence_values)
    }
  end

  private

  def self.median(values)
    sorted = values.sort
    mid = sorted.size / 2
    sorted.size.odd? ? sorted[mid] : (sorted[mid - 1] + sorted[mid]) / 2.0
  end
end