require "csv_generator"
require "json"

RSpec.describe CsvGenerator do
  describe "#group_items_by_speaker" do
    let(:csv_generator) { described_class.new }
    
    it "groups consecutive items from the same speaker" do
      items = [
        { speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "Hello", confidence: 0.9, type: "pronunciation" },
        { speaker_label: "spk_0", start_time: 1.1, end_time: 1.5, content: "world", confidence: 0.85, type: "pronunciation" },
        { speaker_label: "spk_1", start_time: 2.0, end_time: 2.5, content: "How", confidence: 0.8, type: "pronunciation" },
        { speaker_label: "spk_1", start_time: 2.6, end_time: 3.0, content: "are", confidence: 0.9, type: "pronunciation" },
        { speaker_label: "spk_1", start_time: 3.1, end_time: 3.5, content: "you", confidence: 0.95, type: "pronunciation" }
      ]
      
      groups = csv_generator.group_items_by_speaker(items)
      
      expect(groups.size).to eq(2)
      expect(groups[0][:speaker_label]).to eq("spk_0")
      expect(groups[0][:items].size).to eq(2)
      expect(groups[0][:start_time]).to eq(0.0)
      expect(groups[0][:end_time]).to eq(1.5)
      expect(groups[0][:transcript]).to eq("Hello world")
      
      expect(groups[1][:speaker_label]).to eq("spk_1")
      expect(groups[1][:items].size).to eq(3)
      expect(groups[1][:start_time]).to eq(2.0)
      expect(groups[1][:end_time]).to eq(3.5)
      expect(groups[1][:transcript]).to eq("How are you")
    end
    
    it "creates new groups when there's a significant silence gap" do
      items = [
        { speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "Hello", confidence: 0.9, type: "pronunciation" },
        { speaker_label: "spk_0", start_time: 3.0, end_time: 3.5, content: "there", confidence: 0.85, type: "pronunciation" }
      ]
      
      groups = csv_generator.group_items_by_speaker(items, silence_threshold: 1.5)
      
      expect(groups.size).to eq(2)
      expect(groups[0][:transcript]).to eq("Hello")
      expect(groups[1][:transcript]).to eq("there")
    end
    
    it "handles empty input" do
      expect(csv_generator.group_items_by_speaker([])).to eq([])
    end
    
    it "handles punctuation items correctly" do
      items = [
        { speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "Hello", confidence: 0.9, type: "pronunciation" },
        { speaker_label: nil, start_time: nil, end_time: nil, content: ",", confidence: nil, type: "punctuation" },
        { speaker_label: "spk_0", start_time: 1.1, end_time: 1.5, content: "world", confidence: 0.85, type: "pronunciation" }
      ]
      
      groups = csv_generator.group_items_by_speaker(items)
      
      expect(groups.size).to eq(1)
      expect(groups[0][:transcript]).to eq("Hello, world")
    end
  end
  
  describe "#detect_natural_pauses" do
    let(:csv_generator) { described_class.new }
    
    it "identifies sentence endings and natural breaks" do
      items = [
        { speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "Hello", confidence: 0.9, type: "pronunciation" },
        { speaker_label: nil, start_time: nil, end_time: nil, content: ".", confidence: nil, type: "punctuation" },
        { speaker_label: "spk_0", start_time: 1.5, end_time: 2.0, content: "This", confidence: 0.85, type: "pronunciation" },
        { speaker_label: "spk_0", start_time: 2.1, end_time: 2.5, content: "is", confidence: 0.8, type: "pronunciation" },
        { speaker_label: "spk_0", start_time: 2.6, end_time: 3.0, content: "a", confidence: 0.9, type: "pronunciation" },
        { speaker_label: "spk_0", start_time: 3.1, end_time: 3.5, content: "test", confidence: 0.95, type: "pronunciation" },
        { speaker_label: nil, start_time: nil, end_time: nil, content: ".", confidence: nil, type: "punctuation" },
        { speaker_label: "spk_0", start_time: 4.0, end_time: 4.5, content: "How", confidence: 0.9, type: "pronunciation" },
        { speaker_label: "spk_0", start_time: 4.6, end_time: 5.0, content: "are", confidence: 0.85, type: "pronunciation" },
        { speaker_label: "spk_0", start_time: 5.1, end_time: 5.5, content: "you", confidence: 0.8, type: "pronunciation" },
        { speaker_label: nil, start_time: nil, end_time: nil, content: "?", confidence: nil, type: "punctuation" }
      ]
      
      pauses = csv_generator.detect_natural_pauses(items)
      
      expect(pauses.size).to eq(3)
      expect(pauses[0][:index]).to eq(1)
      expect(pauses[0][:type]).to eq(:sentence_end)
      expect(pauses[1][:index]).to eq(6)
      expect(pauses[1][:type]).to eq(:sentence_end)
      expect(pauses[2][:index]).to eq(10)
      expect(pauses[2][:type]).to eq(:sentence_end)
    end
    
    it "identifies natural breaks with commas" do
      items = [
        { speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "Hello", confidence: 0.9, type: "pronunciation" },
        { speaker_label: nil, start_time: nil, end_time: nil, content: ",", confidence: nil, type: "punctuation" },
        { speaker_label: "spk_0", start_time: 1.5, end_time: 2.0, content: "world", confidence: 0.85, type: "pronunciation" },
        { speaker_label: nil, start_time: nil, end_time: nil, content: ".", confidence: nil, type: "punctuation" }
      ]
      
      pauses = csv_generator.detect_natural_pauses(items)
      
      expect(pauses.size).to eq(2)
      expect(pauses[0][:index]).to eq(1)
      expect(pauses[0][:type]).to eq(:natural_break)
      expect(pauses[1][:index]).to eq(3)
      expect(pauses[1][:type]).to eq(:sentence_end)
    end
    
    it "respects configurable thresholds" do
      items = [
        { speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "Word", confidence: 0.9, type: "pronunciation" },
        { speaker_label: "spk_0", start_time: 2.5, end_time: 3.0, content: "after", confidence: 0.85, type: "pronunciation" },
        { speaker_label: "spk_0", start_time: 3.1, end_time: 3.5, content: "pause", confidence: 0.8, type: "pronunciation" }
      ]
      
      # Default threshold
      pauses = csv_generator.detect_natural_pauses(items)
      expect(pauses.size).to eq(1)
      expect(pauses[0][:index]).to eq(0)
      expect(pauses[0][:type]).to eq(:time_gap)
      
      # Custom threshold
      pauses = csv_generator.detect_natural_pauses(items, time_gap_threshold: 2.0)
      expect(pauses.size).to eq(0)
    end
  end

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
