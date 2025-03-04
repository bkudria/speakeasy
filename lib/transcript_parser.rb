require "json"

class TranscriptParser
  def initialize(transcript_path)
    @transcript_path = transcript_path
    @parsed_data = JSON.parse(File.read(@transcript_path))
  end

  def parse
    @parsed_data
  end

  # We assume the "speaker_labels" key in the JSON is always a Hash.
  # If it isn't, this method defaults the speaker count to 0.
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

  def parsed_items
    @parsed_data["results"]["items"].map do |item|
      {
        speaker_label: item["speaker_label"],
        start_time: item["start_time"]&.to_f,
        end_time: item["end_time"]&.to_f,
        content: item.dig("alternatives", 0, "content"),
        confidence: item.dig("alternatives", 0, "confidence")&.to_f,
        type: item["type"]
      }
    end
  end
end
