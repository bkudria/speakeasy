# frozen_string_literal: true

require_relative "file_validator"
require_relative "speaker_file_manager"
require_relative "transcript_processor"

# ProcessingCoordinator is responsible for coordinating the transcript processing workflow
# It manages the interactions between various components of the system
class ProcessingCoordinator
  # Initialize the ProcessingCoordinator with necessary dependencies
  #
  # @param transcript_path [String] Path to the transcript file
  # @param audio_path [String] Path to the audio file
  # @param input [IO] Input stream for user interaction, defaults to $stdin
  # @param output_dir [String] Directory for output files, defaults to current directory
  # @param file_validator [FileValidator] Validator for input files
  # @param speaker_file_manager [SpeakerFileManager] Manager for speaker audio files
  # @param transcript_processor [TranscriptProcessor] Processor for transcript data
  def initialize(transcript_path, audio_path, input: $stdin, output_dir: Dir.pwd,
                file_validator: FileValidator.new,
                speaker_file_manager: SpeakerFileManager.new(output_dir, input: input),
                transcript_processor: nil)
    @transcript_path = transcript_path
    @audio_path = audio_path
    @output_dir = output_dir
    @input = input
    @file_validator = file_validator
    @speaker_file_manager = speaker_file_manager
    @transcript_processor = transcript_processor || TranscriptProcessor.new(transcript_path, audio_path, input: input, output_dir: output_dir)
    @error_count = 0
  end

  # Process the transcript and audio files
  # Coordinates the workflow between different components
  #
  # @return [Hash] Result of the processing with status information
  def process
    puts "Starting Amazon Transcribe processing script"
    
    # Initialize result hash to track processing status
    result = {
      csv_generated: false,
      speakers_extracted: false,
      misalignments_detected: false
    }
    
    begin
      # Step 0: Validate input files
      @file_validator.validate(@transcript_path, @audio_path)
      
      # Step 1: Check for existing speaker files
      if @speaker_file_manager.check_speaker_files(result)
        # If speaker files exist, skip extraction but complete remaining steps
        wait_for_speaker_identification_with_skip(result)
        return complete_processing(result)
      end
      
      # Step 2: Extract speaker audio
      extract_speaker_audio(result)
      
      # Step 3: Wait for speaker identification
      wait_for_speaker_identification(result)
      
      # Complete remaining processing steps
      complete_processing(result)
    rescue StandardError => e
      # Handle any uncaught errors
      puts "Error during processing: #{e.message}"
      puts e.backtrace.join("\n") if ENV["DEBUG"]
      result[:error] = e
      result
    end
  end
  
  private
  
  # Extract speaker audio from the transcript
  # @param result [Hash] Result hash to update
  def extract_speaker_audio(result)
    puts "\n=== Step 1: Extracting speaker audio ==="
    begin
      # Use the process method directly, which calls extract_speaker_audio internally
      @transcript_processor.send(:extract_speaker_audio)
      result[:speakers_extracted] = true
    rescue StandardError => e
      @error_count += 1
      puts "Error extracting speaker audio: #{e.message}"
      puts e.backtrace.join("\n") if ENV["DEBUG"]
      result[:error] = e
    end
  end
  
  # Wait for speaker identification to complete
  # @param result [Hash] Result hash to update
  def wait_for_speaker_identification(result)
    begin
      @transcript_processor.send(:wait_for_speaker_identification)
    rescue StandardError => e
      @error_count += 1
      puts "Error during speaker identification: #{e.message}"
      puts e.backtrace.join("\n") if ENV["DEBUG"]
      result[:error] = e
    end
  end
  
  # Wait for speaker identification with skip option
  # @param result [Hash] Result hash to update
  def wait_for_speaker_identification_with_skip(result)
    begin
      @transcript_processor.send(:wait_for_speaker_identification, skip: true)
    rescue StandardError => e
      @error_count += 1
      puts "Error during speaker identification: #{e.message}"
      puts e.backtrace.join("\n") if ENV["DEBUG"]
      result[:error] = e
    end
  end
  
  # Generate CSV transcript from the parsed data
  # @param result [Hash] Result hash to update
  def generate_csv_transcript(result)
    puts "\n=== Step 2: Generating CSV transcript ==="
    begin
      @transcript_processor.send(:generate_csv_transcript)
      result[:csv_generated] = true
    rescue StandardError => e
      @error_count += 1
      puts "Error generating CSV transcript: #{e.message}"
      puts e.backtrace.join("\n") if ENV["DEBUG"]
      result[:error] = e
    end
  end
  
  # Identify segments that need review
  # @param result [Hash] Result hash to update
  def identify_segments_to_review(result)
    puts "\n=== Step 3: Identifying segments to review ==="
    begin
      @transcript_processor.send(:identify_segments_to_review)
    rescue StandardError => e
      @error_count += 1
      puts "Error identifying segments to review: #{e.message}"
      puts e.backtrace.join("\n") if ENV["DEBUG"]
      result[:error] = e
    end
  end
  
  # Complete the processing workflow
  # @param result [Hash] Result hash to update
  # @return [Hash] Updated result hash
  def complete_processing(result)
    # Generate CSV transcript
    generate_csv_transcript(result)
    
    # Identify segments to review
    identify_segments_to_review(result)
    
    puts "Processing complete!"
    result
  end
end