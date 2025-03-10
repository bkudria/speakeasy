require 'spec_helper'
require 'fileutils'
require 'tempfile'
require 'tmpdir'
require_relative '../../lib/transcript_processor'

RSpec.describe "TranscriptProcessor Integration" do
  include_context "file system mocks"
  
  # Define paths for input and output files
  let(:temp_dir) { "/tmp/speakeasy_integration_test" }
  let(:json_path) { File.join(temp_dir, "asrOutput.json") }
  let(:audio_path) { File.join(temp_dir, "audio.m4a") }
  let(:output_dir) { File.join(temp_dir, "output") }
  let(:transcript_csv) { File.join(output_dir, "transcript.csv") }
  let(:json_content) { '{"results":{"transcripts":[{"transcript":"This is a sample transcript."}],"speaker_labels":{"speakers":2,"segments":[{"speaker_label":"spk_0","start_time":"0.0","end_time":"2.0"},{"speaker_label":"spk_1","start_time":"2.1","end_time":"4.0"}]}}}' }
  
  before do
    # Allow specific file operations for testing
    allow(Dir).to receive(:exist?).and_call_original
    allow(Dir).to receive(:glob).and_call_original
    allow(FileUtils).to receive(:mkdir_p).and_call_original
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:join).and_call_original
    
    # Mock specific files
    mock_file_exists(json_path, true)
    mock_file_content(json_path, json_content)
    mock_file_exists(audio_path, true)
    
    # Mock JSON parsing
    mock_json_parse(json_content, JSON.parse(json_content))
    
    # Mock directory checks
    allow(Dir).to receive(:glob).with(File.join(output_dir, "spk_*_*.m4a")).and_return([])
    allow(Dir).to receive(:glob).with(File.join(output_dir, "spk_*.m4a")).and_return([])
    
    # Mock CSV output
    mock_file_exists(transcript_csv, true)
    allow(File).to receive(:read).with(transcript_csv).and_return("Speaker,Text,Start Time,End Time,Confidence\nspk_0,Hello world,0:00,0:05,0.95")
    
    # Mock speaker files
    speaker_file = File.join(output_dir, "speaker_0.mp3")
    allow(Dir).to receive(:glob).with(File.join(output_dir, "speaker_*.mp3")).and_return([speaker_file])
    mock_file_exists(speaker_file, true)
    
    # Mock system calls
    allow(Kernel).to receive(:system).and_return(true)
    allow(Open3).to receive(:capture3).and_return(["", "", double(success?: true)])
  end
  
  it "processes transcript and audio files end-to-end" do
    # Mock specific methods to avoid actual processing
    allow_any_instance_of(TranscriptProcessor).to receive(:extract_speaker_audio).and_return(nil) 
    allow_any_instance_of(TranscriptProcessor).to receive(:wait_for_speaker_identification).and_return(nil)
    allow_any_instance_of(TranscriptProcessor).to receive(:generate_csv_transcript).and_return(nil)
    allow_any_instance_of(TranscriptProcessor).to receive(:identify_segments_to_review).and_return(nil)
    allow_any_instance_of(TranscriptProcessor).to receive(:open_output_directory).and_return(nil)
    
    # Initialize the TranscriptProcessor
    processor = TranscriptProcessor.new(json_path, audio_path, output_dir: output_dir)
    
    # Don't mock the process method - just use the updated implementation
    # allow(processor).to receive(:process) do
    #   # Return a mock result that does not include misalignments_detected
    #   {
    #     csv_generated: true,
    #     speakers_extracted: true
    #   }
    # end
    
    # Process the files
    result = processor.process
    
    # Verify basic processing occurred
    expect(result).to include(:csv_generated)
    expect(result).to include(:speakers_extracted)
    
    # The test should fail because misalignment detection isn't implemented yet
    expect(result).to include(:misalignments_detected)
  end
end