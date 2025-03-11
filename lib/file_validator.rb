# frozen_string_literal: true

require "json"
require "open3"

# FileValidator is responsible for validating input files and dependencies
# It validates file existence, JSON format, and external dependencies like ffmpeg
class FileValidator
  # Validates transcript and audio files and external dependencies
  # @param transcript_path [String] Path to the transcript file
  # @param audio_path [String] Path to the audio file
  # @raise [SystemExit] If validation fails
  def validate(transcript_path, audio_path)
    validate_file_exists(transcript_path, "Transcript")
    validate_file_exists(audio_path, "Audio")
    validate_json_format(transcript_path)
    validate_ffmpeg_available
  end

  private

  # Validate that a required file exists
  # @param file_path [String] Path to the file
  # @param file_type [String] Type of file for error message
  # @raise [SystemExit] If the file does not exist
  def validate_file_exists(file_path, file_type)
    unless File.exist?(file_path)
      abort "Error: #{file_type} file '#{file_path}' not found."
    end
  end

  # Validate that the transcript file contains valid JSON
  # @param transcript_path [String] Path to the transcript file
  # @raise [SystemExit] If the file does not contain valid JSON
  def validate_json_format(transcript_path)
    JSON.parse(File.read(transcript_path))
  rescue JSON::ParserError => e
    abort "Error: Invalid JSON format in transcript file: #{e.message}"
  end

  # Validate that ffmpeg is available on the system
  # @raise [SystemExit] If ffmpeg is not available
  def validate_ffmpeg_available
    _, _, status = Open3.capture3("ffmpeg -version")
    unless status.success?
      abort "Error: ffmpeg is not installed or not in PATH. Please install ffmpeg to continue."
    end
  end
end
