require 'spec_helper'
require 'open3'
require 'tmpdir'

RSpec.describe 'TranscriptProcessor input validation' do
  context 'when the transcript file is missing' do
    it 'exits with a non-zero status and shows an error message' do
      Dir.mktmpdir do |tmpdir|
        # Create a dummy audio file in tmpdir
        audio_path = File.join(tmpdir, "test_audio.wav")
        File.write(audio_path, "fake audio content")

        # Run the script
        output, status = Open3.capture2e("ruby bin/speakeasy #{tmpdir}")
        expect(status).not_to be_success
        expect(output).to match(/Transcript file 'asrOutput.json' not found/i)
      end
    end
  end

  context 'when no audio file is found' do
    it 'exits with a non-zero status and shows an error message' do
      Dir.mktmpdir do |tmpdir|
        # Create a dummy transcript file but no audio
        transcript_path = File.join(tmpdir, "asrOutput.json")
        File.write(transcript_path, '{"results":{}}')

        # Run the script
        output, status = Open3.capture2e("ruby bin/speakeasy #{tmpdir}")
        expect(status).not_to be_success
        expect(output).to match(/No audio files found/i)
      end
    end
  end
end
