
- [ ] Improve the parser tests, using fixture file spec/fixture/asrOutput.json
  - [ ] Update or create parser tests that load and parse this fixture
  - [ ] Confirm coverage for normal transcript data, missing or malformed fields, and error handling
  - [ ] Verify speaker_count, audio_segments, and items class methods behave correctly
  - [ ] Add assertions that confirm correct identification of speakers and segments

- [ ] Refactor the main script so that the code related to generating the CSV data is separate and could be covered by unit tests.
  - [ ] Create a new file named `csv_generator.rb` with a `CsvGenerator` class or module.
  - [ ] Move CSV row-building logic from `TranscriptProcessor` to `CsvGenerator`.
  - [ ] Ensure `TranscriptProcessor` utilizes `CsvGenerator` for building transcript data rows.
  - [ ] Add or move RSpec tests for CSV data generation.

- [ ] Refactor the main script so that the code related to writing the CSV is separate and could be covered by unit tests.
  - [ ] Create a new file named `csv_writer.rb` with a `CsvWriter` class or module.
  - [ ] Move the CSV writing logic from `TranscriptProcessor` to `CsvWriter`.
  - [ ] Ensure `TranscriptProcessor` calls `CsvWriter` to write the CSV output.
  - [ ] Add or move RSpec tests for CSV writing.

- [ ] 
