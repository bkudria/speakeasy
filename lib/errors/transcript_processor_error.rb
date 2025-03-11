# frozen_string_literal: true

# Base error class for all errors raised by the TranscriptProcessor and related classes
class TranscriptProcessorError < StandardError; end

# Error class for validation failures (input files, formats, etc.)
class ValidationError < TranscriptProcessorError; end

# Error class for processing failures (processing transcript data)
class ProcessingError < TranscriptProcessorError; end

# Error class for speaker identification failures
class SpeakerIdentificationError < TranscriptProcessorError; end

# Error class for file operation failures (reading, writing, etc.)
class FileOperationError < TranscriptProcessorError; end