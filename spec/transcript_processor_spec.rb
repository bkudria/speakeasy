require "spec_helper"
require_relative "../lib/transcript_processor"
require "open3"
require "fileutils"

# TranscriptProcessor Tests
#
# This file demonstrates the consistent mocking strategy using the FileSystemHelpers module.
# It follows these principles:
#
# 1. Use shared contexts for common setup ("transcript processor file system mocks")
# 2. Use helper methods like mock_file_exists() instead of direct allow().to receive() calls
# 3. Use complex helpers like mock_file_read_and_parse() for multi-step operations
# 4. Add clear comments for complex mocking scenarios
# 5. Keep actual file system operations isolated from tests
#
# See spec/support/file_system_helpers.rb for the complete mocking API documentation.

RSpec.describe TranscriptProcessor do
  include_context "transcript processor file system mocks"

  describe "#initialize" do
    it "initializes with valid inputs" do
      expect { TranscriptProcessor.new(valid_json_path, valid_audio_path) }.not_to raise_error
    end

    it "aborts if transcript file doesn't exist" do
      expect {
        TranscriptProcessor.new("nonexistent.json", valid_audio_path)
      }.to raise_error(SystemExit)
    end

    it "aborts if audio file doesn't exist" do
      expect {
        TranscriptProcessor.new(valid_json_path, "nonexistent.m4a")
      }.to raise_error(SystemExit)
    end

    it "aborts if transcript file has invalid JSON" do
      # Use helper methods from FileSystemHelpers for file mocking
      mock_file_exists("invalid.json", true)
      mock_file_content("invalid.json", "invalid json")
      mock_file_basename("invalid.json", ".*", "invalid")

      # Mock JSON parsing error
      allow(JSON).to receive(:parse).with("invalid json").and_raise(JSON::ParserError.new("Invalid JSON format"))

      expect {
        TranscriptProcessor.new("invalid.json", valid_audio_path)
      }.to raise_error(SystemExit)
    end

    it "aborts if ffmpeg is not available" do
      # Use our helper method for ffmpeg version check
      mock_open3_command("ffmpeg -version", "", "error", double(success?: false))

      expect {
        TranscriptProcessor.new(valid_json_path, valid_audio_path)
      }.to raise_error(SystemExit)
    end
  end

  describe "#process" do
    let(:mock_input) { StringIO.new("go\n") }
    let(:processor) { TranscriptProcessor.new(valid_json_path, valid_audio_path, input: mock_input) }
    let(:parser) { instance_double("TranscriptParser") }
    before { allow(parser).to receive(:parsed_items).and_return([]) }
    let(:speaker_extraction) { instance_double("SpeakerExtraction") }
    let(:speaker_identification) { instance_double("SpeakerIdentification") }
    let(:csv_writer) { instance_double("CsvWriter") }
    let(:csv_generator) { instance_double("CsvGenerator") }
    let(:low_confidence_detector) { instance_double("LowConfidenceDetector") }

    before do
      # Set up test doubles for all component classes
      allow(TranscriptParser).to receive(:new).and_return(parser)
      allow(SpeakerExtraction).to receive(:new).and_return(speaker_extraction)
      allow(SpeakerIdentification).to receive(:new).and_return(speaker_identification)
      allow(CsvWriter).to receive(:new).and_return(csv_writer)
      allow(CsvGenerator).to receive(:new).and_return(csv_generator)
      allow(LowConfidenceDetector).to receive(:new).and_return(low_confidence_detector)

      # Use FileSystemHelpers methods for directory operations
      mock_dir_glob(File.join(Dir.pwd, "spk_*_*.m4a"), [])
      mock_dir_glob(File.join(Dir.pwd, "spk_*.m4a"), [])
      mock_dir_glob(File.join(processor.instance_variable_get(:@output_dir), "spk_*.m4a"), [])

      # Set up component behavior
      allow(speaker_extraction).to receive(:extract)
      allow(speaker_identification).to receive(:identify)
      allow(parser).to receive(:audio_segments).and_return([])
      allow(csv_generator).to receive(:process_parsed_items).and_return([])

      # Set up misalignment components
      misalignment_detector = double("MisalignmentDetector")
      misalignment_corrector = double("MisalignmentCorrector")
      allow(MisalignmentDetector).to receive(:new).and_return(misalignment_detector)
      allow(MisalignmentCorrector).to receive(:new).and_return(misalignment_corrector)
      allow(misalignment_detector).to receive(:detect_issues).and_return([])
      allow(misalignment_corrector).to receive(:correct!)

      # Other common behaviors
      allow(csv_writer).to receive(:write_transcript)
      allow(low_confidence_detector).to receive(:identify_segments_to_review)
      allow(processor).to receive(:puts)
      allow(processor).to receive(:open_output_directory)
    end

    context "when handling errors during item processing" do
      let(:processor) { TranscriptProcessor.new(valid_json_path, valid_audio_path, input: mock_input) }

      before do
        # Initialize the error count for testing
        processor.instance_variable_set(:@error_count, 0)
      end

      it "handles empty parsed items gracefully" do
        allow(parser).to receive(:parsed_items).and_return([])

        expect(csv_generator).to receive(:process_parsed_items)
          .with([], anything, silence_threshold: 1.0)
          .and_return([])

        expect { processor.process }.not_to raise_error
      end

      it "handles nil parsed items gracefully" do
        allow(parser).to receive(:parsed_items).and_return(nil)

        # The implementation should convert nil to empty array
        expect(csv_generator).to receive(:process_parsed_items)
          .with([], anything, silence_threshold: 1.0)
          .and_return([])

        expect { processor.process }.not_to raise_error
      end

      it "handles errors during CSV generation" do
        allow(parser).to receive(:parsed_items).and_return([{speaker_label: "spk_0", content: "Hello"}])
        allow(csv_generator).to receive(:process_parsed_items).and_raise(StandardError.new("CSV generation error"))

        # The implementation should catch the error and log it
        expect(processor).to receive(:puts).with(/Error processing transcript items: CSV generation error/)
        expect { processor.process }.not_to raise_error
      end

      it "increments error count when processing fails" do
        allow(parser).to receive(:parsed_items).and_return([{speaker_label: "spk_0", content: "Hello"}])
        allow(csv_generator).to receive(:process_parsed_items).and_raise(StandardError.new("CSV generation error"))

        # The implementation should increment an error counter
        expect { processor.process }.to change { processor.instance_variable_get(:@error_count) }.from(0).to(1)
      end

      it "sets empty rows array when processing fails" do
        allow(parser).to receive(:parsed_items).and_return([{speaker_label: "spk_0", content: "Hello"}])
        allow(csv_generator).to receive(:process_parsed_items).and_raise(StandardError.new("CSV generation error"))

        # The implementation should ensure @rows is initialized even on error
        processor.process
        expect(processor.instance_variable_get(:@rows)).to eq([])
      end

      it "handles malformed speaker identity data" do
        allow(parser).to receive(:parsed_items).and_return([{speaker_label: "spk_0", content: "Hello"}])

        # Use helper to mock glob with malformed file pattern
        mock_dir_glob(File.join(Dir.pwd, "spk_*_*.m4a"), ["spk_0_invalid*.m4a"])

        # The implementation should handle invalid speaker identity patterns
        expect { processor.process }.not_to raise_error
      end

      it "handles errors during misalignment detection" do
        allow(parser).to receive(:parsed_items).and_return([{speaker_label: "spk_0", content: "Hello"}])
        allow(csv_generator).to receive(:process_parsed_items).and_return([{id: 1, speaker: "John", transcript: "Hello"}])

        # Simulate an error during misalignment detection
        allow(MisalignmentDetector).to receive(:new).and_raise(StandardError.new("Misalignment detection error"))

        # The implementation should catch the error and log it
        expect(processor).to receive(:puts).with(/Error detecting misalignments: Misalignment detection error/)
        expect { processor.process }.not_to raise_error
      end

      it "handles errors during misalignment correction" do
        allow(parser).to receive(:parsed_items).and_return([{speaker_label: "spk_0", content: "Hello"}])
        allow(csv_generator).to receive(:process_parsed_items).and_return([{id: 1, speaker: "John", transcript: "Hello"}])

        misalignment_detector = double("MisalignmentDetector")
        allow(MisalignmentDetector).to receive(:new).and_return(misalignment_detector)
        allow(misalignment_detector).to receive(:detect_issues).and_return([])

        # Simulate an error during misalignment correction
        allow(MisalignmentCorrector).to receive(:new).and_raise(StandardError.new("Misalignment correction error"))

        # The implementation should catch the error and log it
        expect(processor).to receive(:puts).with(/Error correcting misalignments: Misalignment correction error/)
        expect { processor.process }.not_to raise_error
      end

      it "handles errors during CSV writing" do
        allow(parser).to receive(:parsed_items).and_return([{speaker_label: "spk_0", content: "Hello"}])
        allow(csv_generator).to receive(:process_parsed_items).and_return([{id: 1, speaker: "John", transcript: "Hello"}])

        # Simulate an error during CSV writing
        allow(csv_writer).to receive(:write_transcript).and_raise(StandardError.new("CSV writing error"))

        # The implementation should catch the error and log it
        expect(processor).to receive(:puts).with(/Error writing CSV transcript: CSV writing error/)
        expect { processor.process }.not_to raise_error
      end

      it "provides debug information when DEBUG environment variable is set" do
        allow(ENV).to receive(:[]).with("DEBUG").and_return("true")
        allow(parser).to receive(:parsed_items).and_return([{speaker_label: "spk_0", content: "Hello"}])
        allow(csv_generator).to receive(:process_parsed_items).and_raise(StandardError.new("CSV generation error"))

        # The implementation should print backtrace when DEBUG is set
        expect(processor).to receive(:puts).with(/Error processing transcript items: CSV generation error/)
        expect(processor).to receive(:puts).with(instance_of(String)) # For the backtrace

        processor.process
      end
    end

    it "maps speaker identities correctly in the CSV" do
      parsed_items = [
        {speaker_label: "spk_0", start_time: 0.0, end_time: 1.0, content: "Hello", confidence: 0.9, type: "pronunciation"},
        {speaker_label: "spk_1", start_time: 1.1, end_time: 2.0, content: "world", confidence: 0.85, type: "pronunciation"}
      ]

      allow(parser).to receive(:parsed_items).and_return(parsed_items)

      # Use our helper for mocking Dir.glob with named speaker files
      mock_dir_glob(File.join(Dir.pwd, "spk_*_*.m4a"), ["spk_0_Alice.m4a", "spk_1_Bob.m4a"])

      expected_rows = [
        {id: 1, speaker: "Alice", transcript: "Hello", confidence_min: 0.9, confidence_max: 0.9, confidence_mean: 0.9, confidence_median: 0.9, note: ""},
        {id: 2, speaker: "Bob", transcript: "world", confidence_min: 0.85, confidence_max: 0.85, confidence_mean: 0.85, confidence_median: 0.85, note: ""}
      ]

      expect(csv_generator).to receive(:process_parsed_items)
        .with(parsed_items, {"spk_0" => "Alice", "spk_1" => "Bob"}, silence_threshold: 1.0)
        .and_return(expected_rows)

      expect(csv_writer).to receive(:write_transcript).with(expected_rows, anything)

      processor.process
    end

    it "completes successfully with valid inputs" do
      allow(parser).to receive(:parsed_items).and_return([])
      expect { processor.process }.not_to raise_error
    end

    it "skips extraction when named speaker files exist" do
      # Use helper for mocking named speaker files
      mock_dir_glob(File.join(Dir.pwd, "spk_*_*.m4a"), ["spk_0_John.m4a"])

      expect(speaker_extraction).not_to receive(:extract)
      expect(speaker_identification).to receive(:identify).with(skip: true)

      processor.process
    end

    # This test requires specific sequencing of Dir.glob calls, which is a complex mocking scenario
    it "prompts for speaker identification when unnamed speaker files exist" do
      # Complex mocking scenario: We need three sequential Dir.glob calls with different results
      # 1. First check for named speaker files → returns []
      # 2. Check for unnamed speaker files → returns ["spk_0.m4a"]
      # 3. After user input "go", check named files again → returns ["spk_0_John.m4a"]

      expect(Dir).to receive(:glob).with(File.join(Dir.pwd, "spk_*_*.m4a")).twice.and_return([], ["spk_0_John.m4a"])
      expect(Dir).to receive(:glob).with(File.join(Dir.pwd, "spk_*.m4a")).once.and_return(["spk_0.m4a"])
      expect(processor).to receive(:puts).with(/Please identify each speaker/)
      expect(Dir).to receive(:glob).with(File.join(Dir.pwd, "spk_*_*.m4a")).once.and_return(["spk_0_John.m4a"])

      processor.process
    end

    context "when generating CSV transcript" do
      before do
        # Create a real instance of CsvGenerator instead of a double
        real_csv_generator = CsvGenerator.new
        allow(CsvGenerator).to receive(:new).and_return(real_csv_generator)
      end

      it "generates CSV transcript with proper data" do
        parsed_items = [
          {
            speaker_label: "spk_0",
            start_time: 0.0,
            end_time: 5.0,
            content: "Hello world",
            confidence: 0.85,
            type: "pronunciation"
          }
        ]

        allow(parser).to receive(:parsed_items).and_return(parsed_items)

        # Mock the process_parsed_items method to return the expected row
        expected_row = {
          id: 1,
          speaker: "John",
          transcript: "Hello world",
          confidence_min: 0.8,
          confidence_max: 0.9,
          confidence_mean: 0.85,
          confidence_median: 0.85,
          note: "",
          start_time: "0.0",
          end_time: "5.0"
        }

        # Set up the expectation for process_parsed_items
        expect(csv_generator).to receive(:process_parsed_items)
          .with(parsed_items, {"spk_0" => "John"}, silence_threshold: 1.0)
          .and_return([expected_row])

        expect(csv_writer).to receive(:write_transcript).with([expected_row], anything)

        # Use helper for mocking named speaker files
        mock_dir_glob(File.join(Dir.pwd, "spk_*_*.m4a"), ["spk_0_John.m4a"])

        processor.process
      end
    end

    it "identifies segments to review" do
      allow(processor).to receive(:generate_csv_transcript) do
        processor.instance_variable_set(:@rows, [{id: 1}])
      end

      expect(low_confidence_detector).to receive(:identify_segments_to_review).with([{id: 1}])

      processor.process
    end

    it "uses item-based approach with process_parsed_items" do
      # Setup
      allow(parser).to receive(:parsed_items).and_return([{speaker_label: "spk_0", content: "Hello"}])
      mock_input = StringIO.new("go\n")
      processor = TranscriptProcessor.new(valid_json_path, valid_audio_path, input: mock_input)

      # Mock parsed_items and speaker_identities
      parsed_items = [{speaker_label: "spk_0", content: "Hello"}]
      processed_rows = [{id: 1, speaker: "John", transcript: "Hello"}]

      # Expectations for the new approach
      expect(parser).to receive(:parsed_items).and_return(parsed_items)

      # Use composite helper for mocking multiple directory operations
      mock_dir_glob(File.join(Dir.pwd, "spk_*_*.m4a"), ["spk_0_John.m4a"])
      mock_dir_glob(File.join(Dir.pwd, "spk_*.m4a"), ["spk_0_John.m4a"])
      mock_dir_glob(File.join(processor.instance_variable_get(:@output_dir), "spk_*.m4a"), ["spk_0_John.m4a"])

      # This is the key expectation for the new approach
      expect(csv_generator).to receive(:process_parsed_items)
        .with(parsed_items, {"spk_0" => "John"}, silence_threshold: 1.0)
        .and_return(processed_rows)

      # We should not use the old approach
      expect(parser).not_to receive(:audio_segments)
      expect(csv_generator).not_to receive(:process_segment)

      # Expectations for the rest of the method
      allow(MisalignmentDetector).to receive(:new).and_return(double(detect_issues: []))
      allow(MisalignmentCorrector).to receive(:new).and_return(double(correct!: nil))
      expect(csv_writer).to receive(:write_transcript).with(processed_rows, anything)

      # Run the method
      processor.send(:generate_csv_transcript)
    end

    it "creates a CSV file" do
      # Use complex mock helper to set up a complete file processing scenario
      tmpdir = "/tmp/mock_test_dir"
      test_json_path = File.join(tmpdir, "asrOutput.json")
      test_audio_path = File.join(tmpdir, "audio.m4a")
      csv_output_path = File.join(tmpdir, "asrOutput.csv")

      # Set up file system mocks using helper methods
      mock_file_exists(test_json_path, true)
      mock_file_exists(test_audio_path, true)
      mock_file_content(test_json_path, valid_json_content)
      mock_json_parse(valid_json_content, valid_json_data)
      mock_file_basename(test_json_path, ".*", "asrOutput")
      
      # Mock directory operations
      mock_dir_glob(File.join(tmpdir, "spk_*_*.m4a"), [])
      mock_dir_glob(File.join(tmpdir, "spk_*.m4a"), [])
      
      # Mock system commands using helpers
      mock_system_command(/^(open|start|xdg-open)\s/, true)
      mock_open3_command("ffmpeg -version", "ffmpeg version", "", double(success?: true))
      
      # For any glob patterns, return empty array
      allow(Dir).to receive(:glob).with(anything).and_return([])

      # Mock file existence for generate_unique_filename in CsvWriter
      allow(File).to receive(:exist?).with(File.join(tmpdir, "asrOutput.csv")).and_return(false)
      
      # Mock CSV.open instead of using real CsvWriter
      csv_double = double("CSV")
      allow(CSV).to receive(:open).with(any_args).and_yield(csv_double)
      allow(csv_double).to receive(:<<)

      # Use a mock CsvWriter instead of the real one
      csv_writer_double = instance_double(CsvWriter)
      allow(CsvWriter).to receive(:new).with(tmpdir).and_return(csv_writer_double)
      allow(csv_writer_double).to receive(:write_transcript).and_return(csv_output_path)
      
      # Run the processor
      processor = TranscriptProcessor.new(
        test_json_path,
        test_audio_path,
        input: StringIO.new("go\n"),
        output_dir: tmpdir
      )
      
      # Process with all file system operations mocked
      processor.process

      # Verify that CsvWriter's write_transcript was called, which indicates the CSV file was created
      expect(csv_writer_double).to have_received(:write_transcript)
    end
  end

  describe "#open_output_directory" do
    let(:processor) do
      TranscriptProcessor.new(valid_json_path, valid_audio_path, input: StringIO.new, output_dir: "spec/fixture")
    end

    context "when the system command is recognized" do
      it "calls system with the correct command" do
        allow(processor).to receive(:open_directory_command).and_return("open")
        # Use our helper for mocking Kernel.system
        mock_system_command("open spec/fixture", true)

        processor.send(:open_output_directory)
      end
    end

    context "when the system command is nil" do
      it "prints a warning instead of calling system" do
        allow(processor).to receive(:open_directory_command).and_return(nil)
        expect(Kernel).not_to receive(:system)
        expect(processor).to receive(:puts).with("Unable to open directory automatically for this platform.")

        processor.send(:open_output_directory)
      end
    end
  end
end