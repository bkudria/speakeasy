require "spec_helper"
require "speaker_extraction"
require "open3"

RSpec.describe SpeakerExtraction do
  context "normal extraction" do
    it "extracts speaker audio successfully" do
      # ...
    end
  end

  context "error scenarios" do
    it "handles extraction errors appropriately" do
      # ...
    end
  end

  context "ffmpeg extraction" do
    let(:mock_parser) do
      instance_double(
        "TranscriptParser",
        speaker_count: 1,
        audio_segments: [
          {"speaker_label" => "spk_0", "start_time" => "0.0", "end_time" => "2.0"}
        ]
      )
    end

    subject { described_class.new(mock_parser, "test_audio.m4a", "output_dir") }

    before do
      allow(Open3).to receive(:capture3).and_return(["", "", instance_double(Process::Status, success?: true)])
      allow(FileUtils).to receive(:rm)
      allow(File).to receive(:open).and_call_original
      allow(File).to receive(:open).with("spk_0_segments.txt", "w").and_yield(StringIO.new)
    end

    it "calls ffmpeg with the correct arguments" do
      expect { subject.extract }.to output.to_stdout
      expect(Open3).to have_received(:capture3).with(a_string_including("ffmpeg -hide_banner -loglevel error -y -f concat -safe 0 -i spk_0_segments.txt -c copy spk_0.m4a"))
    end

    it "creates a temporary segments file with correct format" do
      file_mock = StringIO.new
      allow(File).to receive(:open).with("spk_0_segments.txt", "w").and_yield(file_mock)

      expect { subject.extract }.to output.to_stdout

      expect(file_mock.string).to include("file 'test_audio.m4a'")
      expect(file_mock.string).to include("inpoint 0.0")
      expect(file_mock.string).to include("outpoint 2.0")
    end

    it "cleans up temporary files after extraction" do
      expect { subject.extract }.to output.to_stdout
      expect(FileUtils).to have_received(:rm).with("spk_0_segments.txt")
    end

    context "when ffmpeg fails" do
      before do
        allow(Open3).to receive(:capture3).and_return(["", "Simulated ffmpeg error", instance_double(Process::Status, success?: false)])
      end

      it "reports an error" do
        expect { subject.extract }.to output(/Error creating audio file for spk_0/).to_stdout
      end
    end
  end
end
