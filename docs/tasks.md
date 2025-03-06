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

  - [ ] Enhance CsvGenerator to work with individual items
    - Files: lib/csv_generator.rb, spec/csv_generator_spec.rb
    - [x] Implement calculate_confidence_metrics method for item groups (3)
      - Add method to calculate min, max, mean, and median confidence from a group of items
      - Handle edge cases like empty groups or missing confidence values
      - Add tests for the new method
    - [ ] Update build_row method to work with grouped items (3)
      - Modify to accept a group of items instead of a segment
      - Use calculate_confidence_metrics for confidence calculations
      - Add tests for the updated method
    - [ ] Add process_parsed_items method to generate rows from parsed items (5)
      - Create method to process parsed_items from TranscriptParser
      - Use group_items_by_speaker and detect_natural_pauses in the implementation
      - Add tests for the new method
    
  - [ ] Update TranscriptProcessor workflow
    - Files: lib/transcript_processor.rb, spec/transcript_processor_spec.rb
    - [ ] Modify generate_csv_transcript to use the new item-based approach (5)
      - Update to use parser.parsed_items instead of audio_segments
      - Use CsvGenerator's new process_parsed_items method
      - Add tests for the updated method
    - [ ] Update speaker mapping for item-based approach (3)
      - Ensure speaker identities are correctly applied to grouped items
      - Update tests to verify correct speaker mapping
    - [ ] Implement error handling for item processing (2)
      - Add specific error handling for item processing failures
      - Add tests for error scenarios

  - [ ] Implement misalignment detection
    - Files: lib/misalignment_detector.rb, spec/misalignment_detector_spec.rb
    - [ ] Create basic test structure for MisalignmentDetector (2)
      - Set up test file with basic test cases
      - Define expected behavior for detect_issues method
    - [ ] Implement detect_issues method (5)
      - Create method to identify misalignments in rows
      - Return a structured list of detected issues
      - Add tests for the method
    - [ ] Implement check_sentence_boundaries method (3)
      - Detect incorrect segment labeling through sentence structure
      - Add tests for the method
    - [ ] Implement check_word_confidence method (3)
      - Check confidence patterns to identify potential misalignments
      - Add tests for the method
    - [ ] Implement check_pause_silences method (3)
      - Use silence data for correct segmentation
      - Add tests for the method
    - [ ] Implement check_time_adjacency method (2)
      - Check for short time offsets between segments
      - Add tests for the method
    - [ ] Implement check_cross_speaker_transitions method (3)
      - Analyze speaker transitions for anomalies
      - Add tests for the method
    - [ ] Implement check_aggregated_confidence_drops method (3)
      - Detect abrupt confidence drops as misalignment indicators
      - Add tests for the method

  - [ ] Implement misalignment correction
    - Files: lib/misalignment_corrector.rb, spec/misalignment_corrector_spec.rb
    - [ ] Create basic test structure for MisalignmentCorrector (2)
      - Set up test file with basic test cases
      - Define expected behavior for correct! method
    - [ ] Implement correct! method (5)
      - Create method to fix identified issues in rows
      - Apply corrections based on detected issues
      - Add tests for the method
    - [ ] Implement move_short_misalignments method (3)
      - Add logic to move misaligned text to correct segments
      - Add tests for the method
    - [ ] Implement mark_review_if_unsure method (2)
      - Mark segments for review when correction is uncertain
      - Add tests for the method
    - [ ] Implement reassign_words_by_timing method (3)
      - Reassign words to speakers based on timing data
      - Add tests for the method
    - [ ] Implement handle_uncertain_speaker method (3)
      - Handle ambiguous speaker assignments
      - Add tests for the method

  - [ ] Integration and finalization
    - [ ] Integrate misalignment detection and correction into TranscriptProcessor (5)
      - Files: lib/transcript_processor.rb, spec/transcript_processor_spec.rb
      - Add calls to MisalignmentDetector and MisalignmentCorrector
      - Add tests for the integration
    - [ ] Create end-to-end tests for misalignment correction (5)
      - Files: spec/transcript_processor_spec.rb
      - Test with realistic misalignment scenarios from examples
      - Verify correct handling of various misalignment types
    - [ ] Remove deprecated audio_segments code (2)
      - Files: lib/transcript_parser.rb, lib/transcript_processor.rb
      - Safely remove old code after confirming new approach works
      - Update tests to reflect the changes
    - [ ] Update documentation to reflect the new architecture (3)
      - Files: docs/specification.md
      - Document misalignment detection and correction capabilities
      - Update processing steps to reflect the new item-based approach
    - [ ] Perform performance testing and optimization (3)
      - Benchmark performance of the new approach
      - Optimize any bottlenecks identified
