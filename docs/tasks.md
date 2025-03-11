# Tasks

## Refactoring

- [ ] Refactor duplicate code identified by flay
  - Files: lib/misalignment_detector.rb, lib/transcript_processor.rb, lib/csv_generator.rb
  - [x] Refactor similar code in :call blocks in MisalignmentDetector (8)
    - Files: lib/misalignment_detector.rb
    - [x] Extract duplicated check and issue creation pattern from lines 170, 181, 217, and 299 (5)
    - [x] Create helper method for issue creation with common parameters (3)
  
  - [x] Refactor error handling code in TranscriptProcessor (8)
    - Files: lib/transcript_processor.rb
    - [x] Extract common error handling pattern from :resbody blocks at lines 137, 169, 201, and 210 (5)
    - [x] Create reusable error handling method with appropriate parameters (3)
  
  - [ ] Refactor similar code blocks in TranscriptProcessor (5)
    - Files: lib/transcript_processor.rb
    - [x] Extract duplicate speaker file handling logic from blocks at lines 46 and 70 (5)
  
  - [ ] Refactor confidence check code in MisalignmentDetector (5)
    - Files: lib/misalignment_detector.rb
    - [x] Extract duplicated confidence threshold checking logic from lines 136 and 147 (3)
    - [x] Create helper method for confidence-related issue detection (2)
  
  - [-] Refactor duplicate conditional logic in CsvGenerator (3)
    - Files: lib/csv_generator.rb
    - [-] Extract common condition checking from :and conditions at lines 26 and 168 (3)
