- [ ] Detect and correct mis-labeled transcript items
    - Misalignment examples:
      - Sore Throat:
        - Misaligned:
            Bob: Of course, yeah, it sounds like, you have uh a bit of a sore throat, so I hope you feel better. Thank
            Gloria: you. I appreciate it.
        - Corrected:
            Bob: Of course, yeah, it sounds like, you have uh a bit of a sore throat, so I hope you feel better.
            Gloria: Thank you. I appreciate it.
      - Real Words:
        - Misaligned:
            Bob: It's a good talent to be able to say that. It's not actually
            Gloria: you. I appreciate it.
        - Corrected:
            Bob: Of course, yeah, it sounds like, you have uh a bit of a sore throat, so I hope you feel better.
            Jim: a real word. I learned that
      - Not a misalignment: even if Jim doesn't have a complete sentence, Bob starts a new sentence, indicating that
        Bob interrupted Jim. This transcript is correct:
          Jim: Hey Bob, question. Is it your intention or your recommendation that we fill up all 22 slots next Wednesday? That would be a
          Bob: I mean, I think that is the ideal scenario.

  - [x] Update TranscriptParser to provide clear, structured list of items (tokens) ready for grouping by speaker
  - [x] Create method to group items by speaker and silence gaps
  - [x] Implement logic to detect natural pauses and segment boundaries

  - [ ] Implement and test CsvGenerator to work with individual items
    - [ ] Implement confidence calculation methods for item groups (3)
      - Create methods to calculate min, max, mean, and median confidence
      - Handle edge cases like empty groups or missing confidence values
    - [ ] Update build_row method to work with grouped items (3)
      - Modify to accept grouped items instead of segments
      - Ensure all row fields are properly populated
    - [ ] Add special handling for punctuation and non-speech items
    
  - [ ] Update TranscriptProcessor workflow
    - [ ] Modify generate_csv_transcript to use the new item-based CsvGenerator
    - [ ] Update integration with speaker identification
    - [ ] Ensure proper error handling for the new approach
  - [ ] Validate final CSV rows under the new item-based workflow
    - [ ] Confirm row-level confidence calculations match the aggregated items
    - [ ] Validate speaker and transcript text correctness after item grouping
    - [ ] Ensure existing integration specs pass with this approach
  - [ ] Remove deprecated audio_segments code after confirming new approach works

- [ ] Create MisalignmentDetector to detect mis-labeled segments
  - [ ] Detect incorrect segment labeling through sentence boundary analysis
  - [ ] Implement word-level confidence and overlap verification
  - [ ] Implement pause/silence data analysis for correct segmentation
  - [ ] Add time-based adjacency checks for short offsets
  - [ ] Implement cross-speaker transition verification
  - [ ] Add aggregated confidence trending to detect abrupt drops
    - [ ] Add special handling for punctuation and non-speech items (2)
      - Implement logic to handle punctuation items differently
  - [ ] Update TranscriptProcessor workflow
    - Files: lib/transcript_processor.rb, spec/transcript_processor_spec.rb
    - [ ] Modify generate_csv_transcript to use the new item-based CsvGenerator (3)
      - Update to use parsed_items instead of audio_segments
      - Integrate with the new CsvGenerator methods
    - [ ] Update integration with speaker identification (3)
      - Files: lib/transcript_processor.rb, lib/speaker_identification.rb, spec/transcript_processor_spec.rb, spec/speaker_identification_spec.rb
      - Ensure speaker identification works with item-based approach
      - Update tests to verify correct speaker mapping
    - [ ] Ensure proper error handling for the new approach (2)
      - Add specific error handling for item processing failures
      - Implement graceful degradation for partial failures
  - [ ] Enhance misalignment detection and correction
    - [ ] Implement core MisalignmentDetector functionality (5)
      - Files: lib/misalignment_detector.rb, spec/misalignment_detector_spec.rb
      - Implement `detect_issues` method to identify misalignments
      - Add methods for each detection type (sentence boundaries, speaker labels, etc.)
    - [ ] Implement core MisalignmentCorrector functionality (5)
      - Files: lib/misalignment_corrector.rb, spec/misalignment_corrector_spec.rb
      - Implement `correct!` method to fix identified issues
      - Add methods for each correction type (move_short_misalignments, etc.)
    - [ ] Create comprehensive tests for detection and correction (3)
      - Files: spec/misalignment_detector_spec.rb, spec/misalignment_corrector_spec.rb
      - Add tests for each detection and correction method
      - Include edge cases and integration tests
  - [ ] Testing and finalization
    - [ ] Create integration tests for the complete item-based workflow (5)
      - Add end-to-end tests covering the full processing pipeline
      - Test with various input formats and edge cases
    - [ ] Remove deprecated audio_segments code (2)
      - Safely remove old code after confirming new approach works
      - Update documentation to reflect removed functionality
    - [ ] Update documentation to reflect the new architecture (3)
      - Update specification.md with new processing details
      - Add code comments explaining the item-based approach
    - [ ] Perform performance testing and optimization (3)
      - Benchmark performance against the old approach
      - Optimize any bottlenecks in the new implementation
