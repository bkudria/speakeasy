- [x] Install and configure the `simplecov` gem, for code coverage
  - SimpleCov's README is here: https://raw.githubusercontent.com/simplecov-ruby/simplecov/refs/heads/main/README.md
  - [x] Ensure tests print the coverage percentage clearly
  - [ ] Implement a coverage ratchet:
    - [ ] Configure SimpleCov to enforce a minimum acceptable coverage threshold
    - [ ] Fail tests if coverage dips below that threshold
    - [ ] Track and compare coverage from a prior run
    - [ ] Fail tests if coverage decreases from the prior run

- [ ] Improve the parser tests, using fixture file spec/fixture/asrOutput.json
  - You may not add this fixture directly, use placeholder data and temporarily disable tests. I replace placeholder data with what the correct values should be.
  - [x] Update or create parser tests that load and parse this fixture
  - [ ] Confirm coverage for:
    - [ ] normal transcript data
    - [ ] missing fields
    - [ ] malformed fields
    - [ ] error handling
  - [ ] Verify:
    - [ ] speaker_count
    - [ ] audio_segments
    - [ ] items
  - [ ] Add assertions that confirm correct identification of speakers and segments

- [ ] Refactor the main script so that the code related to generating the CSV data is separate and could be covered by unit tests.
  - [ ] Create a new file named `csv_generator.rb` with a `CsvGenerator` class or module
  - [ ] Move CSV row-building logic (including Note field logic for "multiple speakers", "unknown", "error") from `TranscriptProcessor` to `CsvGenerator`
  - [ ] Ensure `TranscriptProcessor` utilizes `CsvGenerator` for building transcript data rows
  - [ ] Add or move RSpec tests for CSV data generation:
    - [ ] normal output generation
    - [ ] error cases

- [ ] Refactor the main script so that the code related to writing the CSV is separate and could be covered by unit tests.
  - [ ] Create a new file named `csv_writer.rb` with a `CsvWriter` class or module
  - [ ] Move the CSV writing logic (including exit-on-error behavior for three consecutive errors) from `TranscriptProcessor` to `CsvWriter`
  - [ ] Ensure `TranscriptProcessor` calls `CsvWriter` to write the CSV output
  - [ ] Add or move RSpec tests for CSV writing:
    - [ ] normal output
    - [ ] handling or reporting errors

- [ ] Add RSpec coverage for `transcript_processor.rb`
  - [ ] Require `transcript_processor.rb` in a new or existing spec
  - [ ] Exercise its methods so SimpleCov accurately reports coverage

- [ ] 
