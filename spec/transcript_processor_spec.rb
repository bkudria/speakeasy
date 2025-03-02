require "tmpdir"
require "spec_helper"
require_relative "../lib/transcript_processor"
require "open3"
require "fileutils"

RSpec.describe TranscriptProcessor do
  before do
    allow(Kernel).to receive(:system) do |cmd|
      case cmd
      when /\A(open|start|xdg-open)\s/
        true  # Stub these so they do NOT actually open anything
      else
        Kernel.system(cmd)  # Pass all other commands (like ffmpeg) through
      end
    end
  end
  before(:all) do
    FileUtils.mkdir_p("spec/fixture")
    system("ffmpeg -f lavfi -i anullsrc=r=44100:cl=mono -t 0.5 -q:a 9 -loglevel error -nostats spec/fixture/audio.m4a")
  end

  after(:all) do
    FileUtils.rm_f("spec/fixture/audio.m4a")
  end
  let(:valid_json_path) { "spec/fixture/asrOutput.json" }
  let(:valid_audio_path) { "spec/fixture/audio.m4a" }

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
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:read).and_return("invalid json")

      expect {
        TranscriptProcessor.new("invalid.json", valid_audio_path)
      }.to raise_error(SystemExit)
    end

    it "aborts if ffmpeg is not available" do
      allow(File).to receive(:exist?).and_return(true)
      allow(JSON).to receive(:parse).and_return({})
      allow(Open3).to receive(:capture3).with("ffmpeg -version").and_return(["", "error", double(success?: false)])

      expect {
        TranscriptProcessor.new(valid_json_path, valid_audio_path)
      }.to raise_error(SystemExit)
    end
  end

  describe "#process" do
    let(:mock_input) { StringIO.new("go\n") }
    let(:processor) { TranscriptProcessor.new(valid_json_path, valid_audio_path, input: mock_input) }
    let(:parser) { instance_double("TranscriptParser") }
    let(:speaker_extraction) { instance_double("SpeakerExtraction") }
    let(:speaker_identification) { instance_double("SpeakerIdentification") }
    let(:csv_writer) { instance_double("CsvWriter") }
    let(:csv_generator) { instance_double("CsvGenerator") }
    let(:low_confidence_detector) { instance_double("LowConfidenceDetector") }

    before do
      allow(TranscriptParser).to receive(:new).and_return(parser)
      allow(SpeakerExtraction).to receive(:new).and_return(speaker_extraction)
      allow(SpeakerIdentification).to receive(:new).and_return(speaker_identification)
      allow(CsvWriter).to receive(:new).and_return(csv_writer)
      allow(CsvGenerator).to receive(:new).and_return(csv_generator)
      allow(LowConfidenceDetector).to receive(:new).and_return(low_confidence_detector)

      allow(Dir).to receive(:glob).with(File.join(Dir.pwd, "spk_*_*.m4a")).and_return([])
      allow(Dir).to receive(:glob).with(File.join(Dir.pwd, "spk_*.m4a")).and_return([])
      allow(speaker_extraction).to receive(:extract)
      allow(speaker_identification).to receive(:identify)
      allow(parser).to receive(:audio_segments).and_return([])
      allow(csv_writer).to receive(:write_transcript)
      allow(low_confidence_detector).to receive(:identify_segments_to_review)
      allow(processor).to receive(:puts)
    end

    it "completes successfully with valid inputs" do
      expect { processor.process }.not_to raise_error
    end

    it "skips extraction when named speaker files exist" do
      allow(Dir).to receive(:glob).with(File.join(Dir.pwd, "spk_*_*.m4a")).and_return(["spk_0_John.m4a"])

      expect(speaker_extraction).not_to receive(:extract)
      expect(speaker_identification).to receive(:identify).with(skip: true)

      processor.process
    end

    it "prompts for speaker identification when unnamed speaker files exist" do
      # Use and_call_original so other unrelated Dir.glob calls still behave normally
      allow(Dir).to receive(:glob).and_call_original

      # First call to check named speaker files → should return []
      expect(Dir).to receive(:glob).with(File.join(Dir.pwd, "spk_*_*.m4a")).once.and_return([])

      # Then check for unnamed speaker files → returns ["spk_0.m4a"]
      expect(Dir).to receive(:glob).with(File.join(Dir.pwd, "spk_*.m4a")).twice.and_return(["spk_0.m4a"])

      expect(processor).to receive(:puts).with(/Please identify each speaker/)

      # After user types "go", the code checks named speaker files again
      expect(Dir).to receive(:glob).with(File.join(Dir.pwd, "spk_*_*.m4a")).once.and_return(["spk_0_John.m4a"])

      processor.process
    end

    it "generates CSV transcript with proper data" do
      segment = {
        start_time: "0.0",
        end_time: "5.0",
        speaker_label: "spk_0"
      }

      allow(parser).to receive(:audio_segments).and_return([segment])

      result = {
        start_new_row: true,
        speaker_name: "John",
        transcript_text: "Hello world",
        min_conf: 0.8,
        max_conf: 0.9,
        mean_conf: 0.85,
        median_conf: 0.85,
        note: "",
        start_time: "0.0",
        end_time: "5.0"
      }

      allow(csv_generator).to receive(:process_segment).and_return(result)

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

      expect(csv_writer).to receive(:write_transcript).with([expected_row], anything)

      processor.process
    end

    it "identifies segments to review" do
      allow(processor).to receive(:generate_csv_transcript) do
        processor.instance_variable_set(:@rows, [{id: 1}])
      end

      expect(low_confidence_detector).to receive(:identify_segments_to_review).with([{id: 1}])

      processor.process
    end

    it "creates a CSV file" do
      Dir.mktmpdir do |tmpdir|
        # Copy our valid fixtures into a temp directory
        test_json_path = File.join(tmpdir, "asrOutput.json")
        FileUtils.cp(valid_json_path, test_json_path)

        test_audio_path = File.join(tmpdir, "audio.m4a")
        FileUtils.cp(valid_audio_path, test_audio_path)

        # Set up specific stubs for speaker patterns and call original for everything else
        allow(Dir).to receive(:glob).with(File.join(tmpdir, "spk_*_*.m4a")).and_return([])
        allow(Dir).to receive(:glob).with(File.join(tmpdir, "spk_*.m4a")).and_return([])
        allow(Dir).to receive(:glob).with(anything).and_call_original

        # Override the global stub to use the real CsvWriter
        allow(CsvWriter).to receive(:new).and_call_original

        # Run the processor
        processor = TranscriptProcessor.new(
          test_json_path,
          test_audio_path,
          input: StringIO.new("go\n"),
          output_dir: tmpdir
        )
        processor.process

        # Verify that a CSV file was created
        csv_files = Dir.glob(File.join(tmpdir, "*.csv"))
        expect(csv_files).not_to be_empty
      end
    end
  end
  
  describe "#open_output_directory" do
    let(:processor) do
      TranscriptProcessor.new(valid_json_path, valid_audio_path, input: StringIO.new, output_dir: "spec/fixture")
    end

    context "when the system command is recognized" do
      it "calls system with the correct command" do
        allow(processor).to receive(:open_directory_command).and_return("open")
        expect(Kernel).to receive(:system).with("open spec/fixture")

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
