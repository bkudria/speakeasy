require "spec_helper"
require_relative "../lib/misalignment_detector"

RSpec.describe MisalignmentDetector do
  let(:rows) do
    [
      {
        id: 1,
        speaker: "John",
        transcript: "Hello, how are you today?",
        confidence_mean: 0.9,
        confidence_min: 0.85,
        confidence_max: 0.95,
        confidence_median: 0.9,
        start_time: 0.0,
        end_time: 2.5
      },
      {
        id: 2,
        speaker: "John",
        transcript: "I am doing great.",
        confidence_mean: 0.85,
        confidence_min: 0.75,
        confidence_max: 0.95,
        confidence_median: 0.85,
        start_time: 3.0,
        end_time: 4.5
      },
      {
        id: 3,
        speaker: "Mary",
        transcript: "That's wonderful to hear.",
        confidence_mean: 0.8,
        confidence_min: 0.7,
        confidence_max: 0.9,
        confidence_median: 0.8,
        start_time: 4.6,
        end_time: 6.0
      }
    ]
  end

  subject(:detector) { described_class.new(rows) }
  
  describe "initialization" do
    it "accepts empty rows" do
      expect { described_class.new([]) }.not_to raise_error
    end
    
    it "accepts empty options" do
      expect { described_class.new(rows, {}) }.not_to raise_error
    end
    
    it "raises ArgumentError for non-array rows" do
      expect { described_class.new("not an array") }.to raise_error(ArgumentError, "Rows must be an array")
    end
    
    it "raises ArgumentError for non-hash options" do
      expect { described_class.new(rows, "not a hash") }.to raise_error(ArgumentError, "Options must be a hash")
    end
    
    it "uses default thresholds when not specified" do
      detector = described_class.new(rows)
      # We can't directly test private instance variables, but we can infer their values
      # by testing behavior with various inputs
      expect(detector).to be_a(MisalignmentDetector)
    end
    
    it "accepts custom thresholds" do
      custom_options = {
        min_confidence_threshold: 0.7,
        confidence_drop_threshold: 0.3,
        significant_pause_threshold: 2.0,
        min_sentence_overlap: 5
      }
      
      expect { described_class.new(rows, custom_options) }.not_to raise_error
    end
  end

  describe "#detect_issues" do
    it "returns an array of misalignment issues" do
      issues = detector.detect_issues
      expect(issues).to be_an(Array)
    end

    it "returns empty array when no issues are found" do
      # When all tests pass, we should have no issues
      allow(detector).to receive(:check_sentence_boundaries).and_return([])
      allow(detector).to receive(:check_speaker_labels).and_return([])
      allow(detector).to receive(:check_word_confidence).and_return([])
      allow(detector).to receive(:check_pause_silences).and_return([])
      allow(detector).to receive(:check_time_adjacency).and_return([])
      allow(detector).to receive(:check_cross_speaker_transitions).and_return([])
      allow(detector).to receive(:check_aggregated_confidence_drops).and_return([])

      issues = detector.detect_issues
      expect(issues).to be_empty
    end
    
    it "returns an empty array for empty rows" do
      empty_detector = described_class.new([])
      expect(empty_detector.detect_issues).to eq([])
    end

    it "aggregates issues from all check methods" do
      # Mock some issues being returned from checks
      allow(detector).to receive(:check_sentence_boundaries).and_return([{row_id: 1, issue_type: :incomplete_sentence}])
      allow(detector).to receive(:check_speaker_labels).and_return([{row_id: 2, issue_type: :inconsistent_speaker}])
      allow(detector).to receive(:check_word_confidence).and_return([])
      allow(detector).to receive(:check_pause_silences).and_return([])
      allow(detector).to receive(:check_time_adjacency).and_return([])
      allow(detector).to receive(:check_cross_speaker_transitions).and_return([])
      allow(detector).to receive(:check_aggregated_confidence_drops).and_return([])

      issues = detector.detect_issues
      expect(issues.size).to eq(2)
      expect(issues).to include(hash_including(row_id: 1, issue_type: :incomplete_sentence))
      expect(issues).to include(hash_including(row_id: 2, issue_type: :inconsistent_speaker))
    end

    it "handles errors in check methods" do
      allow(detector).to receive(:check_sentence_boundaries).and_raise(StandardError.new("Test error"))
      
      # Other checks return normally
      allow(detector).to receive(:check_speaker_labels).and_return([{row_id: 2, issue_type: :inconsistent_speaker}])
      allow(detector).to receive(:check_word_confidence).and_return([])
      allow(detector).to receive(:check_pause_silences).and_return([])
      allow(detector).to receive(:check_time_adjacency).and_return([])
      allow(detector).to receive(:check_cross_speaker_transitions).and_return([])
      allow(detector).to receive(:check_aggregated_confidence_drops).and_return([])

      # Should not crash and still return issues from working checks
      expect { detector.detect_issues }.not_to raise_error
      issues = detector.detect_issues
      expect(issues.size).to eq(1)
      expect(issues).to include(hash_including(row_id: 2, issue_type: :inconsistent_speaker))
    end
  end

  describe "#check_sentence_boundaries" do
    it "identifies incomplete sentences" do
      # Create rows with incomplete sentences
      incomplete_rows = [
        {
          id: 1,
          speaker: "John",
          transcript: "I think that", # Incomplete sentence
          confidence_mean: 0.9,
          start_time: 0.0,
          end_time: 1.5
        },
        {
          id: 2,
          speaker: "Mary",
          transcript: "we should go to the store.",
          confidence_mean: 0.85,
          start_time: 1.6,
          end_time: 3.0
        }
      ]
      
      detector = described_class.new(incomplete_rows)
      issues = detector.send(:check_sentence_boundaries)
      
      expect(issues).not_to be_empty
      expect(issues).to include(hash_including(row_id: 1, issue_type: :incomplete_sentence))
    end
  end

  describe "#check_speaker_labels" do
    it "identifies potential speaker label inconsistencies" do
      # Create rows with potential speaker issues
      mixed_speaker_rows = [
        {
          id: 1,
          speaker: "John",
          transcript: "Hello, how are you?",
          confidence_mean: 0.9,
          start_time: 0.0,
          end_time: 1.5
        },
        {
          id: 2,
          speaker: "John", # Same speaker but potentially should be different
          transcript: "I'm fine, thanks for asking.",
          confidence_mean: 0.6, # Lower confidence might indicate wrong speaker
          start_time: 1.6,
          end_time: 3.0
        }
      ]
      
      detector = described_class.new(mixed_speaker_rows)
      issues = detector.send(:check_speaker_labels)
      
      expect(issues).not_to be_empty
      expect(issues).to include(hash_including(row_id: 2, issue_type: :potential_speaker_mismatch))
    end
  end

  describe "#check_word_confidence" do
    it "identifies segments with suspicious word confidence patterns" do
      # Create rows with suspicious confidence patterns
      suspicious_rows = [
        {
          id: 1,
          speaker: "John",
          transcript: "This is a normal sentence.",
          confidence_mean: 0.9,
          confidence_min: 0.8,
          confidence_max: 0.95,
          start_time: 0.0,
          end_time: 2.0
        },
        {
          id: 2,
          speaker: "John",
          transcript: "This sentence has suspicious confidence.",
          confidence_mean: 0.7,
          confidence_min: 0.3, # Very low minimum
          confidence_max: 0.9,
          start_time: 2.1,
          end_time: 4.0
        }
      ]
      
      detector = described_class.new(suspicious_rows)
      issues = detector.send(:check_word_confidence)
      
      expect(issues).not_to be_empty
      expect(issues).to include(hash_including(row_id: 2, issue_type: :suspicious_confidence_pattern))
    end
  end

  describe "#check_pause_silences" do
    it "identifies potential missed segmentation at long pauses" do
      # Create rows with long pauses that should be segmented
      long_pause_rows = [
        {
          id: 1,
          speaker: "John",
          transcript: "This is the first part.",
          confidence_mean: 0.9,
          start_time: 0.0,
          end_time: 2.0
        },
        {
          id: 2,
          speaker: "John",
          transcript: "This should be a separate segment.", # There's an unusually long pause between segments
          confidence_mean: 0.85,
          start_time: 4.0, # 2-second gap here
          end_time: 6.0
        }
      ]
      
      detector = described_class.new(long_pause_rows)
      issues = detector.send(:check_pause_silences)
      
      expect(issues).not_to be_empty
      expect(issues).to include(hash_including(row_id: 2, issue_type: :potential_missed_segmentation))
    end
  end

  describe "#check_time_adjacency" do
    it "identifies overlapping segments" do
      # Create rows with time overlaps
      overlapping_rows = [
        {
          id: 1,
          speaker: "John",
          transcript: "This is the first segment.",
          confidence_mean: 0.9,
          start_time: 0.0,
          end_time: 3.0
        },
        {
          id: 2,
          speaker: "Mary",
          transcript: "This segment overlaps with the previous one.",
          confidence_mean: 0.85,
          start_time: 2.5, # Overlap here (starts before previous ends)
          end_time: 5.0
        }
      ]
      
      detector = described_class.new(overlapping_rows)
      issues = detector.send(:check_time_adjacency)
      
      expect(issues).not_to be_empty
      expect(issues).to include(hash_including(row_id: 2, issue_type: :segment_overlap))
    end
  end

  describe "#check_cross_speaker_transitions" do
    it "identifies suspicious speaker transitions" do
      # Create rows with suspicious speaker transitions
      suspicious_transition_rows = [
        {
          id: 1,
          speaker: "John",
          transcript: "Hello, how are you today?",
          confidence_mean: 0.9,
          start_time: 0.0,
          end_time: 2.0
        },
        {
          id: 2,
          speaker: "Mary", # Different speaker
          transcript: "I'm doing well.",
          confidence_mean: 0.7, # Lower confidence
          start_time: 2.05, # Very short gap between speakers
          end_time: 3.0
        },
        {
          id: 3,
          speaker: "John", # Back to first speaker
          transcript: "That's great to hear.",
          confidence_mean: 0.75,
          start_time: 3.1,
          end_time: 4.0
        }
      ]
      
      detector = described_class.new(suspicious_transition_rows)
      issues = detector.send(:check_cross_speaker_transitions)
      
      expect(issues).not_to be_empty
      expect(issues).to include(hash_including(row_id: 2, issue_type: :suspicious_speaker_transition))
    end
  end

  describe "#check_aggregated_confidence_drops" do
    it "identifies segments with significant confidence drops" do
      # Create rows with confidence drops
      confidence_drop_rows = [
        {
          id: 1,
          speaker: "John",
          transcript: "This segment has high confidence.",
          confidence_mean: 0.95,
          start_time: 0.0,
          end_time: 2.0
        },
        {
          id: 2,
          speaker: "John",
          transcript: "This segment has much lower confidence.",
          confidence_mean: 0.65, # Significant drop in confidence
          start_time: 2.1,
          end_time: 4.0
        }
      ]
      
      detector = described_class.new(confidence_drop_rows)
      issues = detector.send(:check_aggregated_confidence_drops)
      
      expect(issues).not_to be_empty
      expect(issues).to include(hash_including(row_id: 2, issue_type: :significant_confidence_drop))
    end
  end
end