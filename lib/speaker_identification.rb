require "json"

class SpeakerIdentification
  def initialize(parser, audio_path, output_dir)
    @parser = parser
    @audio_path = audio_path
    @output_dir = output_dir
  end

  def identify(skip: false)
    return if skip

    puts "\n=== Speaker Identification ==="
    puts "Please identify each speaker by renaming the audio files:"
    puts "  Example: rename 'spk_0.m4a' to 'spk_0_John.m4a' if the speaker is John"
    puts "\nType `go` and press enter when you have finished identifying speakers..."
    until STDIN.gets.match("go")
      sleep 1
    end
  end
end
