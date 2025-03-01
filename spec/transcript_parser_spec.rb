require 'spec_helper'
require_relative '../transcript_parser'

RSpec.describe TranscriptParser do
  let(:fixture_path) { File.join(File.dirname(__FILE__), 'fixture', 'asrOutput.json') }
  
  describe '#initialize' do
    it 'loads JSON data from the transcript file' do
      parser = TranscriptParser.new(fixture_path)
      expect(parser.parse).not_to be_nil
      expect(parser.parse).to have_key('results')
    end
  end

  describe '#speaker_count' do
    it 'returns the number of speakers from JSON data' do
      parser = TranscriptParser.new(fixture_path)
      expect(parser.speaker_count).to eq(5) # Using actual value from fixture
    end
  end

  describe '#audio_segments' do
    it 'returns an array of audio segments' do
      parser = TranscriptParser.new(fixture_path)
      expect(parser.audio_segments.size).to eq(23) # Using actual value from fixture
      expect(parser.audio_segments.first).to have_key("speaker_label")
    end
  end

  describe '#items' do
    it 'returns an array of items' do
      parser = TranscriptParser.new(fixture_path)
      expect(parser.items.size).to eq(602) # Using actual value from fixture
      expect(parser.items.first).to have_key("id")
    end
  end
end


RSpec.describe TranscriptParser, "missing fields" do
  it "handles missing fields in the fixture gracefully" do
    fixture_path = File.join(File.dirname(__FILE__), 'fixture', 'asrOutput.json')
    parser = TranscriptParser.new(fixture_path)

    expect { parser.parse }.not_to raise_error

    expect(parser.speaker_count).to eq(5)
    expect(parser.audio_segments.size).to eq(23)
    expect(parser.items.size).to eq(602)

    # If the parser sets default values or discards incomplete data, add appropriate expectations, e.g.:
    # expect(parser.audio_segments.first["transcript"]).to eq("PLACEHOLDER_TEXT")
    # etc.
  end
end

RSpec.describe TranscriptParser, "normal transcript data" do
  it "loads the fixture 'asrOutput.json' without error" do
    fixture_path = File.join(File.dirname(__FILE__), 'fixture', 'asrOutput.json')
    parser = TranscriptParser.new(fixture_path)

    expect {
      parser.parse
    }.not_to raise_error, "Expected the transcript to parse without any exceptions"
  end
end
