require "csv_generator"
require "json"

RSpec.describe CsvGenerator do
  describe "#group_items_by_speaker" do
    let(:csv_generator) { described_class.new }

    it "groups consecutive items from the same speaker" do
      items = [
        {speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "Hello", confidence: 0.9, type: "pronunciation"},
        {speaker_label: "spk_0", start_time: 1.1, end_time: 1.5, content: "world", confidence: 0.85, type: "pronunciation"},
        {speaker_label: "spk_1", start_time: 2.0, end_time: 2.5, content: "How", confidence: 0.8, type: "pronunciation"},
        {speaker_label: "spk_1", start_time: 2.6, end_time: 3.0, content: "are", confidence: 0.9, type: "pronunciation"},
        {speaker_label: "spk_1", start_time: 3.1, end_time: 3.5, content: "you", confidence: 0.95, type: "pronunciation"}
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
        {speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "Hello", confidence: 0.9, type: "pronunciation"},
        {speaker_label: "spk_0", start_time: 3.0, end_time: 3.5, content: "there", confidence: 0.85, type: "pronunciation"}
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
        {speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "Hello", confidence: 0.9, type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: ",", confidence: nil, type: "punctuation"},
        {speaker_label: "spk_0", start_time: 1.1, end_time: 1.5, content: "world", confidence: 0.85, type: "pronunciation"}
      ]

      groups = csv_generator.group_items_by_speaker(items)

      expect(groups.size).to eq(1)
      expect(groups[0][:transcript]).to eq("Hello, world")
    end

    it "handles unusual punctuation patterns correctly" do
      items = [
        {speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "Wow", confidence: 0.9, type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: "!!", confidence: nil, type: "punctuation"},
        {speaker_label: "spk_0", start_time: 1.1, end_time: 1.5, content: "That", confidence: 0.85, type: "pronunciation"},
        {speaker_label: "spk_0", start_time: 1.6, end_time: 2.0, content: "is", confidence: 0.88, type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: "—", confidence: nil, type: "punctuation"},
        {speaker_label: "spk_0", start_time: 2.1, end_time: 2.5, content: "as", confidence: 0.87, type: "pronunciation"},
        {speaker_label: "spk_0", start_time: 2.6, end_time: 3.0, content: "they", confidence: 0.86, type: "pronunciation"},
        {speaker_label: "spk_0", start_time: 3.1, end_time: 3.5, content: "say", confidence: 0.89, type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: "...", confidence: nil, type: "punctuation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: '"', confidence: nil, type: "punctuation"},
        {speaker_label: "spk_0", start_time: 3.6, end_time: 4.0, content: "amazing", confidence: 0.84, type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: '"', confidence: nil, type: "punctuation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: "?!", confidence: nil, type: "punctuation"}
      ]

      groups = csv_generator.group_items_by_speaker(items)

      expect(groups.size).to eq(1)
      expect(groups[0][:transcript]).to eq("Wow!! That is— as they say...\" amazing\"?!")
    end
  end

  describe "#detect_natural_pauses" do
    let(:csv_generator) { described_class.new }

    it "identifies sentence endings and natural breaks" do
      items = [
        {speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "Hello", confidence: 0.9, type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: ".", confidence: nil, type: "punctuation"},
        {speaker_label: "spk_0", start_time: 1.5, end_time: 2.0, content: "This", confidence: 0.85, type: "pronunciation"},
        {speaker_label: "spk_0", start_time: 2.1, end_time: 2.5, content: "is", confidence: 0.8, type: "pronunciation"},
        {speaker_label: "spk_0", start_time: 2.6, end_time: 3.0, content: "a", confidence: 0.9, type: "pronunciation"},
        {speaker_label: "spk_0", start_time: 3.1, end_time: 3.5, content: "test", confidence: 0.95, type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: ".", confidence: nil, type: "punctuation"},
        {speaker_label: "spk_0", start_time: 4.0, end_time: 4.5, content: "How", confidence: 0.9, type: "pronunciation"},
        {speaker_label: "spk_0", start_time: 4.6, end_time: 5.0, content: "are", confidence: 0.85, type: "pronunciation"},
        {speaker_label: "spk_0", start_time: 5.1, end_time: 5.5, content: "you", confidence: 0.8, type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: "?", confidence: nil, type: "punctuation"}
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
        {speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "Hello", confidence: 0.9, type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: ",", confidence: nil, type: "punctuation"},
        {speaker_label: "spk_0", start_time: 1.5, end_time: 2.0, content: "world", confidence: 0.85, type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: ".", confidence: nil, type: "punctuation"}
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
        {speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "Word", confidence: 0.9, type: "pronunciation"},
        {speaker_label: "spk_0", start_time: 2.5, end_time: 3.0, content: "after", confidence: 0.85, type: "pronunciation"},
        {speaker_label: "spk_0", start_time: 3.1, end_time: 3.5, content: "pause", confidence: 0.8, type: "pronunciation"}
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

    it "classifies unusual punctuation patterns correctly in natural pause detection" do
      items = [
        {speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "Word1", type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: "!!", confidence: nil, type: "punctuation"},        # Multiple exclamation (sentence end)
        {speaker_label: "spk_0", start_time: 1.1, end_time: 1.5, content: "Word2", type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: "??", confidence: nil, type: "punctuation"},        # Multiple question (sentence end)
        {speaker_label: "spk_0", start_time: 1.6, end_time: 2.0, content: "Word3", type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: "?!", confidence: nil, type: "punctuation"},        # Combined punct (sentence end)
        {speaker_label: "spk_0", start_time: 2.1, end_time: 2.5, content: "Word4", type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: "—", confidence: nil, type: "punctuation"},         # Em dash (natural break)
        {speaker_label: "spk_0", start_time: 2.6, end_time: 3.0, content: "Word5", type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: "...", confidence: nil, type: "punctuation"},       # Ellipses (sentence end)
        {speaker_label: "spk_0", start_time: 3.1, end_time: 3.5, content: "Word6", type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: '"', confidence: nil, type: "punctuation"},         # Quote (no pause)
        {speaker_label: "spk_0", start_time: 3.6, end_time: 4.0, content: "Word7", type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: '"', confidence: nil, type: "punctuation"}          # Quote (no pause)
      ]

      pauses = csv_generator.detect_natural_pauses(items)

      # Find indices of each punctuation type
      multiple_exclaim_idx = 1   # "!!"
      multiple_question_idx = 3  # "??"
      combined_punct_idx = 5     # "?!"
      em_dash_idx = 7            # "—"
      ellipses_idx = 9           # "..."
      quote_open_idx = 11        # """
      quote_close_idx = 13       # """

      # Check sentence endings
      expect(pauses.any? { |p| p[:index] == multiple_exclaim_idx && p[:type] == :sentence_end }).to be true
      expect(pauses.any? { |p| p[:index] == multiple_question_idx && p[:type] == :sentence_end }).to be true
      expect(pauses.any? { |p| p[:index] == combined_punct_idx && p[:type] == :sentence_end }).to be true
      expect(pauses.any? { |p| p[:index] == ellipses_idx && p[:type] == :sentence_end }).to be true

      # Check natural breaks
      expect(pauses.any? { |p| p[:index] == em_dash_idx && p[:type] == :natural_break }).to be true

      # Check no pauses for quotation marks
      expect(pauses.any? { |p| p[:index] == quote_open_idx }).to be false
      expect(pauses.any? { |p| p[:index] == quote_close_idx }).to be false
    end
  end

  describe "#calculate_confidence_metrics" do
    let(:csv_generator) { described_class.new }

    it "calculates confidence metrics from a group of items" do
      items = [
        {confidence: 0.9},
        {confidence: 0.8},
        {confidence: 0.85},
        {confidence: 0.95}
      ]

      metrics = csv_generator.calculate_confidence_metrics(items)

      expect(metrics[:min]).to be_within(0.001).of(0.8)
      expect(metrics[:max]).to be_within(0.001).of(0.95)
      expect(metrics[:mean]).to be_within(0.001).of(0.875)
      expect(metrics[:median]).to be_within(0.001).of(0.875)
    end

    it "handles empty item groups" do
      metrics = csv_generator.calculate_confidence_metrics([])

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

      metrics = csv_generator.calculate_confidence_metrics(items)

      expect(metrics[:min]).to be_within(0.001).of(0.85)
      expect(metrics[:max]).to be_within(0.001).of(0.9)
      expect(metrics[:mean]).to be_within(0.001).of(0.875)
      expect(metrics[:median]).to be_within(0.001).of(0.875)
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

    it "uses calculate_confidence_metrics for confidence calculations" do
      csv_generator = described_class.new

      # Create a mock for calculate_confidence_metrics
      expect(csv_generator).to receive(:calculate_confidence_metrics).with([{confidence: 0.9}, {confidence: 0.8}]).and_return({
        min: 0.8,
        max: 0.9,
        mean: 0.85,
        median: 0.85
      })

      group = {
        id: 5,
        speaker: "Speaker_Test",
        transcript: "Test transcript",
        items: [{confidence: 0.9}, {confidence: 0.8}],
        speaker_count: 1
      }

      row = csv_generator.build_row(group)

      expect(row[:confidence_min]).to eq(0.8)
      expect(row[:confidence_max]).to eq(0.9)
      expect(row[:confidence_mean]).to eq(0.85)
      expect(row[:confidence_median]).to eq(0.85)
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

  describe "#process_parsed_items" do
    let(:csv_generator) { described_class.new }

    it "processes parsed items into rows" do
      parsed_items = [
        {speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "Hello", confidence: 0.9, type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: ",", confidence: nil, type: "punctuation"},
        {speaker_label: "spk_0", start_time: 1.1, end_time: 1.5, content: "world", confidence: 0.85, type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: ".", confidence: nil, type: "punctuation"},
        {speaker_label: "spk_1", start_time: 2.0, end_time: 2.5, content: "How", confidence: 0.8, type: "pronunciation"},
        {speaker_label: "spk_1", start_time: 2.6, end_time: 3.0, content: "are", confidence: 0.9, type: "pronunciation"},
        {speaker_label: "spk_1", start_time: 3.1, end_time: 3.5, content: "you", confidence: 0.95, type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: "?", confidence: nil, type: "punctuation"}
      ]

      speaker_identities = {
        "spk_0" => "Bob",
        "spk_1" => "Alice"
      }

      rows = csv_generator.process_parsed_items(parsed_items, speaker_identities)

      expect(rows.size).to eq(2)

      # First row (Bob)
      expect(rows[0][:id]).to eq(1)
      expect(rows[0][:speaker]).to eq("Bob")
      expect(rows[0][:transcript]).to eq("Hello, world.")
      expect(rows[0][:confidence_min]).to be_within(0.001).of(0.85)
      expect(rows[0][:confidence_max]).to be_within(0.001).of(0.9)

      # Second row (Alice)
      expect(rows[1][:id]).to eq(2)
      expect(rows[1][:speaker]).to eq("Alice")
      expect(rows[1][:transcript]).to eq("How are you?")
      expect(rows[1][:confidence_min]).to be_within(0.001).of(0.8)
      expect(rows[1][:confidence_max]).to be_within(0.001).of(0.95)
    end

    it "handles empty input" do
      rows = csv_generator.process_parsed_items([], {})
      expect(rows).to eq([])
    end

    it "handles unknown speakers" do
      parsed_items = [
        {speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "Hello", confidence: 0.9, type: "pronunciation"}
      ]

      # No speaker identity for spk_0
      speaker_identities = {}

      rows = csv_generator.process_parsed_items(parsed_items, speaker_identities)

      expect(rows.size).to eq(1)
      expect(rows[0][:speaker]).to eq("Unknown")
    end

    it "respects natural pauses to create separate rows" do
      parsed_items = [
        {speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "First", confidence: 0.9, type: "pronunciation"},
        {speaker_label: nil, start_time: nil, end_time: nil, content: ".", confidence: nil, type: "punctuation"},
        {speaker_label: "spk_0", start_time: 3.0, end_time: 3.5, content: "Second", confidence: 0.85, type: "pronunciation"}
      ]

      speaker_identities = {"spk_0" => "Speaker"}

      rows = csv_generator.process_parsed_items(parsed_items, speaker_identities, silence_threshold: 1.5)

      expect(rows.size).to eq(2)
      expect(rows[0][:transcript]).to eq("First.")
      expect(rows[1][:transcript]).to eq("Second")
    end
  end

  describe "#time_gap_exceeds_threshold?" do
    let(:csv_generator) { described_class.new }

    it "returns true when time gap exceeds threshold" do
      # Case 1: Simple comparison
      expect(csv_generator.time_gap_exceeds_threshold?(1.0, 3.0, 1.5)).to be true
      
      # Case 2: Exactly at threshold
      expect(csv_generator.time_gap_exceeds_threshold?(1.0, 2.5, 1.5)).to be true
      
      # Case 3: Below threshold
      expect(csv_generator.time_gap_exceeds_threshold?(1.0, 2.0, 1.5)).to be false
    end

    it "returns false when either time is nil" do
      expect(csv_generator.time_gap_exceeds_threshold?(nil, 3.0, 1.5)).to be false
      expect(csv_generator.time_gap_exceeds_threshold?(1.0, nil, 1.5)).to be false
      expect(csv_generator.time_gap_exceeds_threshold?(nil, nil, 1.5)).to be false
    end

    it "handles zero and negative thresholds" do
      expect(csv_generator.time_gap_exceeds_threshold?(1.0, 1.0, 0)).to be false
      expect(csv_generator.time_gap_exceeds_threshold?(1.0, 1.1, 0)).to be true
      expect(csv_generator.time_gap_exceeds_threshold?(1.0, 0.9, -0.2)).to be true
    end
  end

  describe "#process_segment" do
    let(:csv_generator) { described_class.new }
    let(:parser) { instance_double("TranscriptParser") }
    let(:segment) { {"speaker_label" => "spk_0", "transcript" => "Hello world", "items" => ["item1", "item2"], "start_time" => "10.0", "end_time" => "15.0"} }
    let(:speaker_identities) { {"spk_0" => "John Doe"} }
    let(:current_row) { {speaker: "John Doe", end_time: 9.0} }
    
    before do
      # Mock the parser behavior
      allow(parser).to receive(:audio_segments).and_return([segment, segment])
      
      # Mock items with confidence values
      item1 = {"id" => "item1", "alternatives" => [{"confidence" => "0.9"}]}
      item2 = {"id" => "item2", "alternatives" => [{"confidence" => "0.8"}]}
      allow(parser).to receive(:items).and_return([item1, item2])
      
      # Allow print to avoid output during tests
      allow(csv_generator).to receive(:print)
    end
    
    it "uses calculate_confidence_metrics to process segment data" do
      # Spy on calculate_confidence_metrics to verify it's called with correctly formatted data
      expect(csv_generator).to receive(:calculate_confidence_metrics).and_call_original
      
      result = csv_generator.process_segment(segment, 0, current_row, speaker_identities, parser)
      
      # Verify confidence values are set correctly
      expect(result[:min_conf]).to be_within(0.001).of(0.8)
      expect(result[:max_conf]).to be_within(0.001).of(0.9)
      expect(result[:mean_conf]).to be_within(0.001).of(0.85)
      expect(result[:median_conf]).to be_within(0.001).of(0.85)
      expect(result[:note]).to eq("")
    end
    
    it "handles segments with no confidence values" do
      # Mock items with no valid confidence values
      allow(parser).to receive(:items).and_return([])
      
      result = csv_generator.process_segment(segment, 0, current_row, speaker_identities, parser)
      
      # Verify default values are set
      expect(result[:min_conf]).to eq(0.0)
      expect(result[:max_conf]).to eq(0.0)
      expect(result[:mean_conf]).to eq(0.0)
      expect(result[:median_conf]).to eq(0.0)
      expect(result[:note]).to eq("error")
    end
  end
end
