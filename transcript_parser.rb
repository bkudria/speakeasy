require 'json'

class TranscriptParser
  def initialize(transcript_path)
    @transcript_path = transcript_path
    @parsed_data = JSON.parse(File.read(@transcript_path))
  end

  def parse
    @parsed_data
  end

  def speaker_count
    @parsed_data.dig("results", "speaker_labels", "speakers").to_i
  end

  def audio_segments
    segments = @parsed_data.dig("results", "audio_segments")
    return [] unless segments.is_a?(Array)
    segments
  end

  def items
    items = @parsed_data.dig("results", "items")
    return [] unless items.is_a?(Array)
    items
  end
end
