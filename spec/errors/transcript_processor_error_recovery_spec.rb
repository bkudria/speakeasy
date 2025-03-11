# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/transcript_processor"
require_relative "../../lib/errors/transcript_processor_error"

RSpec.describe "TranscriptProcessor Error Recovery" do
  include_context "transcript processor file system mocks"

  let(:processor) do
    TranscriptProcessor.new(valid_json_path, valid_audio_path)
  end

  describe "#handle_error" do
    before do
      # Make the processor be quiet during tests
      allow(processor).to receive(:puts)
    end

    context "with different error types" do
      it "applies appropriate recovery strategy for ValidationError" do
        test_block = -> { raise ValidationError, "Invalid input detected" }

        expect(processor).to receive(:puts).with(/Error validation operation: Invalid input detected/)

        processor.send(:handle_error, "validation operation", nil) { test_block.call }

        # Test with recovery options
        recovery_options = {
          retry_count: 2,
          fallback_proc: -> { "fallback value" }
        }

        result = processor.send(:handle_error, "validation with recovery", nil, recovery_options) { test_block.call }
        expect(result).to eq("fallback value")
      end

      it "applies appropriate recovery strategy for ProcessingError" do
        attempt_count = 0
        test_block = -> {
          if attempt_count < 2
            attempt_count += 1
            raise ProcessingError, "Processing failed, attempt #{attempt_count}"
          end
          "processing succeeded on attempt #{attempt_count + 1}"
        }

        recovery_options = {retry_count: 3}

        result = processor.send(:handle_error, "processing with retry", nil, recovery_options) { test_block.call }
        expect(result).to eq("processing succeeded on attempt 3")
      end

      it "applies appropriate recovery strategy for FileOperationError" do
        mock_logger = double("Logger")
        allow(mock_logger).to receive(:error)

        test_block = -> { raise FileOperationError, "File operation failed" }

        recovery_options = {
          log_to: mock_logger,
          notification: "Critical file error"
        }

        expect(mock_logger).to receive(:error).with(/File operation failed/)

        processor.send(:handle_error, "file operation", nil, recovery_options) { test_block.call }
      end
    end

    context "with recovery strategies" do
      it "retries the operation specified number of times" do
        attempts = 0

        # This block will succeed on the third attempt
        test_block = -> {
          attempts += 1
          raise "Error" if attempts < 3
          "success"
        }

        recovery_options = {retry_count: 3, retry_delay: 0.01}

        result = processor.send(:handle_error, "retryable operation", nil, recovery_options) { test_block.call }
        expect(result).to eq("success")
        expect(attempts).to eq(3)
      end

      it "executes fallback proc when all retries fail" do
        test_block = -> { raise "Always fails" }

        recovery_options = {
          retry_count: 2,
          fallback_proc: -> { "fallback result" }
        }

        result = processor.send(:handle_error, "failing operation", nil, recovery_options) { test_block.call }
        expect(result).to eq("fallback result")
      end

      it "notifies about critical errors" do
        test_block = -> { raise "Critical error" }

        recovery_options = {notification: "Critical error detected"}
        expect(processor).to receive(:puts).with(/Critical error detected/)

        processor.send(:handle_error, "critical operation", nil, recovery_options) { test_block.call }
      end
    end
  end
end
