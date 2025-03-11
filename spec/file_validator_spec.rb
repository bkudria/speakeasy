# frozen_string_literal: true

require "spec_helper"
require_relative "../lib/file_validator"
require "open3"

RSpec.describe FileValidator do
  include_context "file system mocks"

  let(:validator) { FileValidator.new }
  let(:valid_json_path) { "spec/fixture/asrOutput.json" }
  let(:valid_audio_path) { "spec/fixture/audio.m4a" }

  describe "#validate" do
    it "does not raise an error with valid inputs" do
      mock_file_exists(valid_json_path, true)
      mock_file_exists(valid_audio_path, true)

      # Mock JSON parsing
      mock_file_content(valid_json_path, '{"key":"value"}')
      mock_json_parse('{"key":"value"}', {"key" => "value"})

      # Mock ffmpeg check
      mock_open3_command("ffmpeg -version", "", "", double(success?: true))

      expect { validator.validate(valid_json_path, valid_audio_path) }.not_to raise_error
    end

    it "aborts if transcript file doesn't exist" do
      mock_file_exists("nonexistent.json", false)
      mock_file_exists(valid_audio_path, true)

      expect {
        validator.validate("nonexistent.json", valid_audio_path)
      }.to raise_error(SystemExit)
    end

    it "aborts if audio file doesn't exist" do
      mock_file_exists(valid_json_path, true)
      mock_file_exists("nonexistent.m4a", false)

      expect {
        validator.validate(valid_json_path, "nonexistent.m4a")
      }.to raise_error(SystemExit)
    end

    it "aborts if transcript file has invalid JSON" do
      mock_file_exists(valid_json_path, true)
      mock_file_exists(valid_audio_path, true)

      # Mock invalid JSON content
      mock_file_content(valid_json_path, "invalid json")
      allow(JSON).to receive(:parse).with("invalid json").and_raise(JSON::ParserError.new("Invalid JSON format"))

      expect {
        validator.validate(valid_json_path, valid_audio_path)
      }.to raise_error(SystemExit)
    end

    it "aborts if ffmpeg is not available" do
      mock_file_exists(valid_json_path, true)
      mock_file_exists(valid_audio_path, true)

      # Mock JSON parsing
      mock_file_content(valid_json_path, '{"key":"value"}')
      mock_json_parse('{"key":"value"}', {"key" => "value"})

      # Mock ffmpeg unavailable
      mock_open3_command("ffmpeg -version", "", "error", double(success?: false))

      expect {
        validator.validate(valid_json_path, valid_audio_path)
      }.to raise_error(SystemExit)
    end
  end
end
