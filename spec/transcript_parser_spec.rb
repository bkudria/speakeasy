require "spec_helper"
require_relative "../lib/transcript_parser"

RSpec.describe TranscriptParser do
  let(:fixture_path) { File.join(File.dirname(__FILE__), "fixture", "asrOutput.json") }
  subject(:parser) { TranscriptParser.new(fixture_path) }
  # TODO: improve - add thorough tests for partial/missing fields beyond standard fixture

  describe "#initialize" do
    it "loads JSON data from the transcript file" do
      expect(parser.parse).not_to be_nil
      expect(parser.parse).to have_key("results")
    end
  end

  describe "#speaker_count" do
    it "returns the number of speakers from JSON data" do
      expect(parser.speaker_count).to eq(5) # Using actual value from fixture
    end
  end

  describe "#audio_segments" do
    it "returns an array of audio segments" do
      expect(parser.audio_segments.size).to eq(23) # Using actual value from fixture
      expect(parser.audio_segments.first).to have_key("speaker_label")
    end
  end

  describe "#items" do
    it "returns an array of items" do
      expect(parser.items.size).to eq(602) # Using actual value from fixture
      expect(parser.items.first).to have_key("id")
    end
  end

  context "normal transcript data" do
    it "loads the fixture 'asrOutput.json' without error" do
      expect {
        parser.parse
      }.not_to raise_error, "Expected the transcript to parse without any exceptions"
    end

    it "validates speaker_count matches expected value" do
      expect(parser.speaker_count).to eq(5)
    end

    it "validates audio_segments matches expected count" do
      expect(parser.audio_segments.size).to eq(23)
    end

    it "validates items matches expected count" do
      expect(parser.items.size).to eq(602)
    end
  end

  context "missing fields" do
    it "handles missing speaker_labels gracefully" do
      json_data = JSON.parse(File.read(fixture_path))
      json_data["results"].delete("speaker_labels")

      allow(File).to receive(:read).and_return(json_data.to_json)

      parser = TranscriptParser.new(fixture_path)
      expect(parser.speaker_count).to eq(0)
    end

    it "handles missing audio_segments gracefully" do
      json_data = JSON.parse(File.read(fixture_path))
      json_data["results"].delete("audio_segments")

      allow(File).to receive(:read).and_return(json_data.to_json)

      parser = TranscriptParser.new(fixture_path)
      expect(parser.audio_segments).to eq([])
    end

    it "handles missing items gracefully" do
      json_data = JSON.parse(File.read(fixture_path))
      json_data["results"].delete("items")

      allow(File).to receive(:read).and_return(json_data.to_json)

      parser = TranscriptParser.new(fixture_path)
      expect(parser.items).to eq([])
    end
  end

  context "malformed fields" do
    it "handles malformed speaker_labels gracefully" do
      malformed_json = '{"results":{"speaker_labels":"invalid_format"}}'
      allow(File).to receive(:read).and_return(malformed_json)

      parser = TranscriptParser.new(fixture_path)
      expect(parser.speaker_count).to eq(0)
    end

    it "handles malformed audio_segments gracefully" do
      malformed_json = '{"results":{"audio_segments":"not_an_array"}}'
      allow(File).to receive(:read).and_return(malformed_json)

      parser = TranscriptParser.new(fixture_path)
      expect(parser.audio_segments).to eq([])
    end

    it "handles malformed items gracefully" do
      malformed_json = '{"results":{"items":"not_an_array"}}'
      allow(File).to receive(:read).and_return(malformed_json)

      parser = TranscriptParser.new(fixture_path)
      expect(parser.items).to eq([])
    end
  end

  context "error handling" do
    it "handles missing audio file scenario" do
      non_existent_path = "non_existent_file.json"
      expect { TranscriptParser.new(non_existent_path) }.to raise_error(Errno::ENOENT)
    end

    it "handles invalid JSON structure scenario" do
      allow(File).to receive(:read).and_return('{"invalid json')
      expect { TranscriptParser.new(fixture_path) }.to raise_error(JSON::ParserError)
    end
  end
end
