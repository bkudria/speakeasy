- [x] Refactor the main script so that the code related to speaker audio extraction is separate and could be covered by unit tests.
  - [x] Create a new file named `speaker_extraction.rb` with a `SpeakerExtraction` class or module
  - [x] Move all audio extraction logic from `TranscriptProcessor` to `SpeakerExtraction`
  - [x] Ensure `TranscriptProcessor` calls `SpeakerExtraction`
  - [x] Add or move RSpec tests for audio extraction:
    - [x] normal audio extraction
    - [x] error scenarios

- [x] Refactor the main script so that the code related to speaker identification is separate and could be covered by unit tests.
  - [x] Create a new file named `speaker_identification.rb` with a `SpeakerIdentification` class or module
  - [x] Move the speaker identification logic (e.g., `wait_for_speaker_identification`) from `TranscriptProcessor` to `SpeakerIdentification`
  - [x] Ensure `TranscriptProcessor` calls `SpeakerIdentification`
  - [x] Add or move RSpec tests for speaker identification:
    - [x] normal identification flow
    - [x] error or corner cases

- [x] Refactor the main script so that the code related to generating the CSV data is separate and could be covered by unit tests.
  - [x] Create a new file named `csv_generator.rb` with a `CsvGenerator` class or module
  - [x] Move CSV row-building logic (including Note field logic for "multiple speakers", "unknown", "error") from `TranscriptProcessor` to `CsvGenerator`
  - [x] Ensure `TranscriptProcessor` utilizes `CsvGenerator` for building transcript data rows
  - [x] Add or move RSpec tests for CSV data generation:
    - [x] normal output generation
    - [x] error cases

- [x] Refactor the main script so that the code related to writing the CSV is separate and could be covered by unit tests.
  - [x] Create a new file named `csv_writer.rb` with a `CsvWriter` class or module
  - [x] Move the CSV writing logic (including exit-on-error behavior for three consecutive errors) from `TranscriptProcessor` to `CsvWriter`
  - [x] Ensure `TranscriptProcessor` calls `CsvWriter` to write the CSV output
  - [x] Add or move RSpec tests for CSV writing:
    - [x] normal output
    - [x] handling or reporting errors

- [x] Refactor the main script so that the code related to low confidence segment detection is separate and could be covered by unit tests.
  - [x] Create a new file named `low_confidence_detector.rb` with a `LowConfidenceDetector` class or module
  - [x] Move low-confidence detection logic (e.g., `identify_segments_to_review`) from `TranscriptProcessor`
  - [x] Ensure `TranscriptProcessor` calls `LowConfidenceDetector`
  - [ ] Add or move RSpec tests for low-confidence detection:
    - [ ] normal detection
    - [ ] corner/error cases

- [ ] Add RSpec coverage for `transcript_processor.rb`
  - [ ] Require `transcript_processor.rb` in a new or existing spec
  - [ ] Exercise its methods so SimpleCov accurately reports coverage
  - [ ] Confirm the script aborts if three consecutive segment errors occur
  - [ ] Verify appropriate exit code is returned when errors persist

- [ ] Improve Specs
  - [ ] Refactor specs to ensure they are mutually exclusive, and collectively exhaustive. No spec should test only code
        that is already covered by another spec, and the specs should test all functionality of the code they cover.
    - [ ] Only test custom logic. If logic is only standard straightforward Ruby (e.g. accessor methods, exposing JSON
          keys parsed), either a unit test or an integration test is sufficient.
    - [ ] Avoid functionally redundant tests - the test suite must remain fast.
    - [ ] Each line of code must be covered once, and ideally is not covered more than once.
  - [ ] Bring the specs in-line with agreed-upon RSpec best practices

- [ ] Add the `standard` gem

- [ ] Add an integration test covering an entire run of the script
  - [ ] Simulate or mock the presence of a valid transcript JSON and audio file
  - [ ] Verify speaker extraction, speaker identification, CSV generation, CSV writing, and low-confidence detection
  - [ ] Confirm correct script exit behavior and error handling

- [ ] 
