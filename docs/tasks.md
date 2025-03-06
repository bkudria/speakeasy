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
    - Files: lib/csv_generator.rb, spec/csv_generator_spec.rb
    - [ ] Implement confidence calculation methods for item groups (3)
      - Create methods to calculate min, max, mean, and median confidence
      - Handle edge cases like empty groups or missing confidence values
    - [ ] Update build_row method to work with grouped items (3)
      - Modify to accept grouped items instead of segments
      - Ensure all row fields are properly populated
    - [ ] Add special handling for punctuation and non-speech items (2)
      - Implement logic to handle punctuation items differently
      - Add tests for punctuation handling
    
  - [ ] Update TranscriptProcessor workflow
    - Files: lib/transcript_processor.rb, spec/transcript_processor_spec.rb
    - [ ] Modify generate_csv_transcript to use the new item-based CsvGenerator (3)
      - Update to use parsed_items instead of audio_segments
      - Integrate with the new CsvGenerator methods
    - [ ] Update integration with speaker identification (3)
      - Files: lib/speaker_identification.rb, spec/speaker_identification_spec.rb
      - Ensure speaker identification works with item-based approach
      - Update tests to verify correct speaker mapping
    - [ ] Ensure proper error handling for the new approach (2)
      - Add specific error handling for item processing failures
      - Implement graceful degradation for partial failures

  - [ ] Implement misalignment detection and correction
    - [ ] Create MisalignmentDetector
      - Files: lib/misalignment_detector.rb, spec/misalignment_detector_spec.rb
      - [ ] Implement core detection functionality (5)
        - Create detect_issues method to identify misalignments
        - Add methods for each detection type
      - [ ] Implement sentence boundary analysis (3)
        - Detect incorrect segment labeling through sentence structure
        - Add tests for boundary detection
      - [ ] Implement word-level confidence verification (3)
        - Check confidence patterns to identify potential misalignments
        - Test with various confidence scenarios
      - [ ] Implement pause/silence analysis (3)
        - Use silence data for correct segmentation
        - Test with different pause patterns
      - [ ] Add time-based adjacency checks (2)
        - Implement checks for short time offsets
        - Test with various timing scenarios
      - [ ] Implement cross-speaker transition verification (3)
        - Analyze speaker transitions for anomalies
        - Test with multiple speaker scenarios
      - [ ] Add confidence trend analysis (3)
        - Detect abrupt confidence drops as misalignment indicators
        - Test with varying confidence patterns

    - [ ] Create MisalignmentCorrector
      - Files: lib/misalignment_corrector.rb, spec/misalignment_corrector_spec.rb
      - [ ] Implement core correction functionality (5)
        - Create correct! method to fix identified issues
        - Add methods for each correction type
      - [ ] Implement short misalignment movement (3)
        - Add logic to move misaligned text to correct segments
        - Test with various misalignment scenarios
      - [ ] Add uncertain segment marking (2)
        - Mark segments for review when correction is uncertain
        - Test marking functionality
      - [ ] Implement timing-based word reassignment (3)
        - Reassign words to speakers based on timing data
        - Test with complex timing scenarios
      - [ ] Add uncertain speaker handling (3)
        - Implement logic for handling ambiguous speaker assignments
        - Test with multi-speaker scenarios

  - [ ] Testing and finalization
    - [ ] Create integration tests for the complete item-based workflow (5)
      - Files: spec/transcript_processor_spec.rb
      - Add end-to-end tests covering the full processing pipeline
      - Test with various input formats and edge cases
    - [ ] Validate final CSV rows under the new item-based workflow (3)
      - Files: spec/csv_generator_spec.rb
      - Confirm row-level confidence calculations match the aggregated items
      - Validate speaker and transcript text correctness after item grouping
    - [ ] Remove deprecated audio_segments code (2)
      - Files: lib/transcript_parser.rb, lib/transcript_processor.rb
      - Safely remove old code after confirming new approach works
      - Update references to removed functionality
    - [ ] Update documentation to reflect the new architecture (3)
      - Files: docs/specification.md
      - Update specification with new processing details
      - Add code comments explaining the item-based approach
    - [ ] Perform performance testing and optimization (3)
      - Benchmark performance against the old approach
      - Optimize any bottlenecks in the new implementation
