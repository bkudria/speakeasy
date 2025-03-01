require 'spec_helper'
require_relative '../transcript_parser'

RSpec.describe TranscriptParser do
  let(:sample_json) do
    {
      "results" => {
        "speaker_labels" => { "speakers" => 2 },
        "audio_segments" => [
          { "start_time" => "0.00", "end_time" => "1.23", "speaker_label" => "spk_0" }
        ],
        "items" => [
          { "id" => 1, "alternatives" => [{ "confidence" => "0.85", "content" => "Hello" }] }
        ]
      }
    }
  end

  before do
    allow(File).to receive(:read).and_return(JSON.dump(sample_json))
  end

  describe '#initialize' do
    it 'loads JSON data from the transcript file' do
      parser = TranscriptParser.new('path/to/transcript.json')
      expect(parser.parse).to eq(sample_json)
    end
  end

  describe '#speaker_count' do
    it 'returns the number of speakers from JSON data' do
      parser = TranscriptParser.new('path/to/transcript.json')
      expect(parser.speaker_count).to eq(2)
    end
  end

  describe '#audio_segments' do
    it 'returns an array of audio segments' do
      parser = TranscriptParser.new('path/to/transcript.json')
      expect(parser.audio_segments.size).to eq(1)
      expect(parser.audio_segments.first["speaker_label"]).to eq("spk_0")
    end
  end

  describe '#items' do
    it 'returns an array of items' do
      parser = TranscriptParser.new('path/to/transcript.json')
      expect(parser.items.size).to eq(1)
      expect(parser.items.first["id"]).to eq(1)
    end
  end
end

describe 'with fixture file' do
  let(:fixture_path) { File.join(File.dirname(__FILE__), 'fixture', 'asrOutput.json') }
  subject(:fixture_parser) { TranscriptParser.new(fixture_path) }

  it 'parses the fixture file successfully' do
    data = fixture_parser.parse
    expect(data).not_to be_empty
    expect(data['results']).to have_key('speaker_labels')
    expect(data['results']).to have_key('audio_segments')
    expect(data['results']).to have_key('items')
  end
end

RSpec.describe TranscriptParser, "missing fields" do
  it "handles missing fields in the fixture gracefully" do
    fixture_path = File.join(File.dirname(__FILE__), 'fixture', 'asrOutput.json')
    parser = TranscriptParser.new(fixture_path)

    expect { parser.parse }.not_to raise_error

    # Replace these placeholder expectations with the correct values once the fixture is finalized.
    expect(parser.speaker_count).to eq(999)  # placeholder: change as needed
    expect(parser.audio_segments.size).to eq(999)  # placeholder: change as needed
    expect(parser.items.size).to eq(999)  # placeholder: change as needed

    # If the parser sets default values or discards incomplete data, add appropriate expectations, e.g.:
    # expect(parser.audio_segments.first["transcript"]).to eq("PLACEHOLDER_TEXT")
    # etc.
  end
end
