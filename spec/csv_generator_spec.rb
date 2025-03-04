require "csv_generator"
require "json"

RSpec.describe CsvGenerator do
  describe "#build_row" do
    let(:csv_generator) { described_class.new }

    it "returns expected row data for normal segment" do
      segment = {
        id: 1,
        speaker: "Speaker_1",
        transcript: "Hello world",
        items: [
          {confidence: "0.9"},
          {confidence: "0.8"},
          {confidence: "0.85"}
        ],
        speaker_count: 1
      }
      row = csv_generator.build_row(segment)

      expect(row[:id]).to eq(1)
      expect(row[:speaker]).to eq("Speaker_1")
      expect(row[:transcript]).to eq("Hello world")
      expect(row[:confidence_min]).to be_within(0.001).of(0.8)
      expect(row[:confidence_max]).to be_within(0.001).of(0.9)
      expect(row[:confidence_mean]).to be_within(0.001).of(0.85)
      expect(row[:confidence_median]).to be_within(0.001).of(0.85)
      expect(row[:note]).to eq("unknown")  # Adjust as needed
    end

    it 'marks the row with "error" in the note field if the segment has_error is true' do
      segment = {
        id: 999,
        speaker: "Speaker_Problem",
        transcript: "Error in segment",
        items: [],
        has_error: true,
        speaker_count: 1
      }
      row = csv_generator.build_row(segment)
      expect(row[:note]).to eq("error")
    end

    it "returns an error note and nil confidences if items array is empty" do
      segment = {
        id: 2,
        speaker: "Speaker_Empty",
        transcript: "No items here",
        items: [],
        speaker_count: 1
      }
      row = csv_generator.build_row(segment)

      expect(row[:note]).to eq("error")
      expect(row[:confidence_min]).to be_nil
      expect(row[:confidence_max]).to be_nil
      expect(row[:confidence_mean]).to be_nil
      expect(row[:confidence_median]).to be_nil
    end
  end
end
