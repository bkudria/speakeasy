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
    speaker_labels = @parsed_data.dig("results", "speaker_labels")
    if speaker_labels.is_a?(Hash)
      speaker_labels["speakers"].to_i
    else
      0
    end
  end

  def audio_segments
    segments = @parsed_data.dig("results", "audio_segments")
    segments.is_a?(Array) ? segments : []
  end

  def items
    items_val = @parsed_data.dig("results", "items")
    items_val.is_a?(Array) ? items_val : []
  end
end
