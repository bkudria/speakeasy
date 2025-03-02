require 'spec_helper'
require 'speaker_identification'

RSpec.describe SpeakerIdentification do
  let(:parser) { double('TranscriptParser') }
  let(:audio_path) { 'path/to/audio.mp3' }
  let(:output_dir) { 'path/to/output' }
  let(:identification) { SpeakerIdentification.new(parser, audio_path, output_dir) }

  context 'normal identification flow' do
    it 'completes speaker identification' do
      allow(STDIN).to receive(:gets).and_return("go")
      
      expect { identification.identify }.to output(/Speaker Identification/).to_stdout
      expect { identification.identify }.to output(/rename 'spk_0.m4a' to 'spk_0_John.m4a'/).to_stdout
    end
  end

  context 'error or corner cases' do
    it 'skips identification when requested' do
      expect { identification.identify(skip: true) }.not_to output.to_stdout
    end
  end
end
