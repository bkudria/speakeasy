require 'json'

class TranscriptParser
  def initialize(transcript_path)
    @transcript_path = transcript_path
  end

  def parse
    JSON.parse(File.read(@transcript_path))
  end
end
