# frozen_string_literal: true

require "spec_helper"
require_relative "../lib/processing_coordinator"

RSpec.describe ProcessingCoordinator do
  include_context "transcript processor file system mocks"

  let(:transcript_path) { valid_json_path }
  let(:audio_path) { valid_audio_path }
  let(:output_dir) { Dir.pwd }
  let(:mock_input) { StringIO.new("go\n") }
  
  let(:file_validator) { instance_double(FileValidator) }
  let(:speaker_file_manager) { instance_double(SpeakerFileManager) }
  let(:transcript_processor) { instance_double(TranscriptProcessor, process: true) }
  
  let(:coordinator) do
    ProcessingCoordinator.new(
      transcript_path, 
      audio_path, 
      input: mock_input,
      output_dir: output_dir,
      file_validator: file_validator,
      speaker_file_manager: speaker_file_manager,
      transcript_processor: transcript_processor
    )
  end
  
  describe "#initialize" do
    it "initializes with dependencies" do
      expect(coordinator).to be_a(ProcessingCoordinator)
    end
    
    it "initializes with default dependencies" do
      allow(FileValidator).to receive(:new).and_return(file_validator)
      allow(SpeakerFileManager).to receive(:new).and_return(speaker_file_manager)
      allow(TranscriptProcessor).to receive(:new).and_return(transcript_processor)
      
      coordinator = ProcessingCoordinator.new(transcript_path, audio_path)
      
      expect(coordinator).to be_a(ProcessingCoordinator)
    end
  end
  
  describe "#process" do
    before do
      allow(file_validator).to receive(:validate)
      allow(speaker_file_manager).to receive(:check_speaker_files).and_return(false)
      allow(transcript_processor).to receive(:send).with(any_args)
      allow(coordinator).to receive(:puts)
    end
    
    it "validates input files" do
      expect(file_validator).to receive(:validate).with(transcript_path, audio_path)
      coordinator.process
    end
    
    it "checks for existing speaker files" do
      expect(speaker_file_manager).to receive(:check_speaker_files)
      coordinator.process
    end
    
    context "when no speaker files exist" do
      before do
        allow(speaker_file_manager).to receive(:check_speaker_files).and_return(false)
      end
      
      it "extracts speaker audio" do
        expect(transcript_processor).to receive(:send).with(:extract_speaker_audio)
        coordinator.process
      end
      
      it "waits for speaker identification" do
        expect(transcript_processor).to receive(:send).with(:wait_for_speaker_identification)
        coordinator.process
      end
      
      it "generates CSV transcript" do
        expect(transcript_processor).to receive(:send).with(:generate_csv_transcript)
        coordinator.process
      end
      
      it "identifies segments to review" do
        expect(transcript_processor).to receive(:send).with(:identify_segments_to_review)
        coordinator.process
      end
      
      it "returns a result hash with processing status" do
        result = coordinator.process
        expect(result).to be_a(Hash)
        expect(result).to include(:speakers_extracted, :csv_generated)
      end
    end
    
    context "when named speaker files exist" do
      let(:result) { { speakers_extracted: true } }
      
      before do
        allow(speaker_file_manager).to receive(:check_speaker_files).and_return(true)
      end
      
      it "skips speaker extraction" do
        expect(transcript_processor).not_to receive(:send).with(:extract_speaker_audio)
        coordinator.process
      end
      
      it "still completes remaining processing" do
        expect(transcript_processor).to receive(:send).with(:wait_for_speaker_identification, skip: true)
        expect(transcript_processor).to receive(:send).with(:generate_csv_transcript)
        expect(transcript_processor).to receive(:send).with(:identify_segments_to_review)
        
        coordinator.process
      end
    end
    
    context "when errors occur" do
      it "handles extraction errors" do
        # Reset stubs before each test
        allow(transcript_processor).to receive(:send).with(any_args).and_return(nil)
        
        # Set up error for specific method
        allow(transcript_processor).to receive(:send).with(:extract_speaker_audio).and_raise(StandardError.new("Extraction error"))
        
        expect(coordinator).to receive(:puts).with(/Error extracting speaker audio: Extraction error/)
        expect { coordinator.process }.not_to raise_error
      end
      
      it "handles identification errors" do
        # Reset stubs before each test
        allow(transcript_processor).to receive(:send).with(any_args).and_return(nil)
        
        # Allow extract_speaker_audio to succeed, but fail on wait_for_speaker_identification
        allow(transcript_processor).to receive(:send).with(:wait_for_speaker_identification).and_raise(StandardError.new("Identification error"))
        
        expect(coordinator).to receive(:puts).with(/Error during speaker identification: Identification error/)
        expect { coordinator.process }.not_to raise_error
      end
      
      it "handles CSV generation errors" do
        # Reset stubs before each test
        allow(transcript_processor).to receive(:send).with(any_args).and_return(nil)
        
        # Fail on generate_csv_transcript
        allow(transcript_processor).to receive(:send).with(:generate_csv_transcript).and_raise(StandardError.new("CSV error"))
        
        expect(coordinator).to receive(:puts).with(/Error generating CSV transcript: CSV error/)
        expect { coordinator.process }.not_to raise_error
      end
      
      it "handles segment review errors" do
        # Reset stubs before each test
        allow(transcript_processor).to receive(:send).with(any_args).and_return(nil)
        
        # Fail on identify_segments_to_review
        allow(transcript_processor).to receive(:send).with(:identify_segments_to_review).and_raise(StandardError.new("Review error"))
        
        expect(coordinator).to receive(:puts).with(/Error identifying segments to review: Review error/)
        expect { coordinator.process }.not_to raise_error
      end
      
      it "returns a result hash with error information" do
        # Reset stubs before each test
        allow(transcript_processor).to receive(:send).with(any_args).and_return(nil)
        
        # Set up error for specific method
        allow(transcript_processor).to receive(:send).with(:extract_speaker_audio).and_raise(StandardError.new("Extraction error"))
        
        result = coordinator.process
        expect(result).to include(:error)
        expect(result[:error]).to be_a(StandardError)
      end
    end
  end
end