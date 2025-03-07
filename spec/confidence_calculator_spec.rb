require "spec_helper"
require_relative "../lib/confidence_calculator"

RSpec.describe ConfidenceCalculator do
  describe ".calculate_metrics" do
    it "calculates confidence metrics from a group of items" do
      items = [
        {confidence: 0.9},
        {confidence: 0.8},
        {confidence: 0.85},
        {confidence: 0.95}
      ]

      metrics = ConfidenceCalculator.calculate_metrics(items)

      expect(metrics[:min]).to be_within(0.001).of(0.8)
      expect(metrics[:max]).to be_within(0.001).of(0.95)
      expect(metrics[:mean]).to be_within(0.001).of(0.875)
      expect(metrics[:median]).to be_within(0.001).of(0.875)
    end

    it "handles empty item groups" do
      metrics = ConfidenceCalculator.calculate_metrics([])

      expect(metrics[:min]).to be_nil
      expect(metrics[:max]).to be_nil
      expect(metrics[:mean]).to be_nil
      expect(metrics[:median]).to be_nil
    end

    it "handles items with missing confidence values" do
      items = [
        {confidence: 0.9},
        {confidence: nil},
        {confidence: 0.85},
        {}
      ]

      metrics = ConfidenceCalculator.calculate_metrics(items)

      expect(metrics[:min]).to be_within(0.001).of(0.85)
      expect(metrics[:max]).to be_within(0.001).of(0.9)
      expect(metrics[:mean]).to be_within(0.001).of(0.875)
      expect(metrics[:median]).to be_within(0.001).of(0.875)
    end
  end
end
