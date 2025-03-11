# frozen_string_literal: true

# SpeakerFileManager handles all operations related to speaker audio files
# It is responsible for finding, identifying, and managing speaker files
class SpeakerFileManager
  def initialize(output_dir, input: $stdin)
    @output_dir = output_dir
    @input = input
  end

  # Get named speaker files from output directory
  # @return [Array] List of named speaker files
  def get_named_speaker_files
    Dir.glob(File.join(@output_dir, "spk_*_*.m4a"))
  end
  
  # Get unnamed speaker files from output directory
  # @param named_files [Array] List of named speaker files to exclude
  # @return [Array] List of unnamed speaker files
  def get_unnamed_speaker_files(named_files)
    Dir.glob(File.join(@output_dir, "spk_*.m4a")) - named_files
  end
  
  # Handle unnamed speaker files by prompting user to rename them
  # @param result [Hash] The result hash to update
  # @return [Boolean] Whether to continue processing or exit
  def handle_unnamed_speaker_files(result)
    puts "\nUnnamed speaker files detected."
    puts "Please identify each speaker by renaming the audio files:"
    puts "  Example: rename 'spk_0.m4a' to 'spk_0_Alex.m4a' if the speaker is Alex"
    puts "\nType `go` and press enter after renaming the files..."
    until @input.gets.strip.downcase == "go"
      sleep 1
    end
    
    # After renaming, check for named speaker files again
    named_speaker_files = get_named_speaker_files
    if named_speaker_files.any?
      process_named_speaker_files(result, "Named speaker files detected after renaming. Skipping speaker audio extraction step.")
      return false # Don't continue processing in the caller
    else
      puts "No named speaker files found after renaming. Exiting."
      exit 1
    end
  end

  # Process named speaker files with common logic
  # @param result [Hash] The result hash to update
  # @param message [String] Custom message to display about speaker files detection
  # @return [Boolean] True to indicate processing completed
  def process_named_speaker_files(result, message)
    puts "\n#{message}"
    result[:speakers_extracted] = true
    true
  end

  # Find speaker identifications from renamed audio files
  # @return [Hash] Map of speaker labels to speaker names
  def find_speaker_identities
    speaker_identities = {}
    Dir.glob(File.join(@output_dir, "spk_*_*.m4a")).each do |file|
      if file =~ /spk_(\d+)_(.+)\.m4a/
        speaker_label = "spk_#{$1}"
        speaker_name = $2
        speaker_identities[speaker_label] = speaker_name
      end
    end
    speaker_identities
  end

  # Check for existing speaker files and handle them appropriately
  # @param result [Hash] The result hash to update
  # @return [Boolean] Whether processing should continue or not
  def check_speaker_files(result)
    # Check for existing named speaker files
    # If we detect any files matching "spk_*_*.m4a", we assume the user has already
    # named the speakers, so we skip extraction. Otherwise, we look for unnamed
    # speaker files ("spk_#.m4a"), prompt the user to rename them, and then retry.
    named_speaker_files = get_named_speaker_files
    if named_speaker_files.any?
      return process_named_speaker_files(result, "Named speaker files detected. Skipping speaker audio extraction step.")
    end

    # Check for existing unnamed speaker files
    unnamed_speaker_files = get_unnamed_speaker_files(named_speaker_files)
    if unnamed_speaker_files.any?
      return handle_unnamed_speaker_files(result)
    end

    # No speaker files found, continue with normal processing
    false
  end
end