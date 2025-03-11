# frozen_string_literal: true

require "spec_helper"
require_relative "../../lib/errors/transcript_processor_error"

RSpec.describe TranscriptProcessorError do
  describe "class hierarchy" do
    it "inherits from StandardError" do
      expect(described_class.superclass).to eq(StandardError)
    end
  end

  describe "initialization" do
    it "accepts a message" do
      error = described_class.new("An error occurred")
      expect(error.message).to eq("An error occurred")
    end
  end
end

RSpec.describe ValidationError do
  describe "class hierarchy" do
    it "inherits from TranscriptProcessorError" do
      expect(described_class.superclass).to eq(TranscriptProcessorError)
    end
  end
end

RSpec.describe ProcessingError do
  describe "class hierarchy" do
    it "inherits from TranscriptProcessorError" do
      expect(described_class.superclass).to eq(TranscriptProcessorError)
    end
  end
end

RSpec.describe SpeakerIdentificationError do
  describe "class hierarchy" do
    it "inherits from TranscriptProcessorError" do
      expect(described_class.superclass).to eq(TranscriptProcessorError)
    end
  end
end

RSpec.describe FileOperationError do
  describe "class hierarchy" do
    it "inherits from TranscriptProcessorError" do
      expect(described_class.superclass).to eq(TranscriptProcessorError)
    end
  end
end