require "spec_helper"
require_relative "../lib/low_confidence_detector"

RSpec.describe LowConfidenceDetector do
  subject(:detector) { described_class.new(threshold: 0.75) }

  describe "#find_low_confidence_segments" do
    it "returns segments below the threshold" do
      rows = [
        {id: 1, confidence_mean: 0.80},
        {id: 2, confidence_mean: 0.60}
      ]
      result = detector.find_low_confidence_segments(rows)
      expect(result.map { |r| r[:id] }).to eq([2])
    end

    it "returns an empty array if none are below threshold" do
      rows = [
        {id: 1, confidence_mean: 0.80},
        {id: 2, confidence_mean: 0.78}
      ]
      result = detector.find_low_confidence_segments(rows)
      expect(result).to be_empty
    end

    it "handles an empty rows array gracefully" do
      result = detector.find_low_confidence_segments([])
      expect(result).to eq([])
    end
  end

  describe "#identify_segments_to_review" do
    let(:rows) do
      [
        {id: 1, confidence_mean: 0.80},
        {id: 2, confidence_mean: 0.60},
        {id: 3, confidence_mean: 0.50},
        {id: 5, confidence_mean: 0.40},
        {id: 7, confidence_mean: 0.70}
      ]
    end

    it "prints information about low confidence segments" do
      expect { detector.identify_segments_to_review(rows) }.to output(/The following segments have low confidence scores/).to_stdout
    end

    it "groups consecutive segment IDs" do
      expect { detector.identify_segments_to_review(rows) }.to output(/Segment IDs: 2-3/).to_stdout
      expect { detector.identify_segments_to_review(rows) }.to output(/Segment ID: 5/).to_stdout
      expect { detector.identify_segments_to_review(rows) }.to output(/Segment ID: 7/).to_stdout
    end

    it "handles no low confidence segments" do
      high_confidence_rows = [
        {id: 1, confidence_mean: 0.80},
        {id: 2, confidence_mean: 0.85}
      ]
      expect { detector.identify_segments_to_review(high_confidence_rows) }.to output(/No low-confidence segments found/).to_stdout
    end
  end
end
