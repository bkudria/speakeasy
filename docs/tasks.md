- [ ] Improve the codebase quality:

  - [ ] Create utility classes to reduce code duplication
    - [ ] Create ConfidenceCalculator utility (files: lib/csv_generator.rb, lib/low_confidence_detector.rb)
      - [ ] Extract calculate_confidence_metrics method from csv_generator.rb (2)
      - [ ] Extract confidence calculation from process_segment method (3)
      - [ ] Update references in low_confidence_detector.rb (1)
      - [ ] Add unit tests for ConfidenceCalculator (3)
    
    - [ ] Create ErrorHandler utility (files: lib/transcript_processor.rb, lib/csv_generator.rb)
      - [ ] Define standard error handling patterns (2)
      - [ ] Extract error handling from transcript_processor.rb (3)
      - [ ] Extract error handling from csv_generator.rb (2)
      - [ ] Implement error tracking and reporting (3)
      - [ ] Add unit tests for ErrorHandler (3)
    
    - [ ] Create FileOperations utility (files: lib/transcript_processor.rb)
      - [ ] Extract file path handling methods (2)
      - [ ] Extract directory opening logic (2)
      - [ ] Add unit tests for FileOperations (3)

  - [ ] Refactor lib/csv_generator.rb
    - [ ] Extract helper methods for clarity
      - [ ] Create method for transcript text building (2)
      - [ ] Create method for segment splitting logic (3)
    - [ ] Improve error handling
      - [ ] Add specific error types for different failures (2)
      - [ ] Implement consistent error logging (2)

  - [ ] Refactor lib/transcript_processor.rb
    - [ ] Simplify process method
      - [ ] Extract speaker file detection logic (3)
      - [ ] Create method for speaker identification workflow (3)
      - [ ] Separate CSV generation logic (2)
    - [ ] Improve error handling
      - [ ] Add specific error handling for each stage (3)
      - [ ] Implement better error reporting (2)
    - [ ] Remove redundant code
      - [ ] Consolidate speaker file detection logic (2)
      - [ ] Eliminate unnecessary conditional checks (1)

  - [ ] Implement MisalignmentDetector functionality (files: lib/misalignment_detector.rb)
    - [ ] Implement detect_issues method
      - [ ] Add sentence boundary detection (3)
      - [ ] Add speaker label consistency checking (3)
      - [ ] Add confidence drop detection (3)
    - [ ] Implement helper methods
      - [ ] Implement check_sentence_boundaries (3)
      - [ ] Implement check_speaker_labels (2)
      - [ ] Implement check_word_confidence (2)
      - [ ] Implement check_pause_silences (2)
      - [ ] Implement check_time_adjacency (2)
      - [ ] Implement check_cross_speaker_transitions (3)
      - [ ] Implement check_aggregated_confidence_drops (3)
    - [ ] Add unit tests for MisalignmentDetector (5)

  - [ ] Implement MisalignmentCorrector functionality (files: lib/misalignment_corrector.rb)
    - [ ] Implement correct! method
      - [ ] Add logic to apply corrections to rows (3)
      - [ ] Add validation of correction results (2)
    - [ ] Implement helper methods
      - [ ] Implement move_short_misalignments (3)
      - [ ] Implement mark_review_if_unsure (2)
      - [ ] Implement reassign_words_by_timing (3)
      - [ ] Implement handle_uncertain_speaker (3)
    - [ ] Add unit tests for MisalignmentCorrector (5)
