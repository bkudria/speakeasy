- [x] Modify the transcript naming convention.

  - [x] Change the output transcript filename to `transcript.csv`.
  - [x] If `transcript.csv` already exists in the directory, append an incrementing number to the filename (e.g., `transcript.1.csv`, `transcript.2.csv`) to avoid overwriting existing files.

- [x] Set up RSpec for testing.

  - [x] Add `rspec` to the `Gemfile`.

  - [x] Run `bundle install` to install RSpec.

  - [x] Initialize RSpec by running `rspec --init`.

  - [x] Create a `spec` directory for test files.

  - [x] Verify RSpec setup by running a sample test.

- [x] Write basic tests to ensure the script works as expected.

  - [x] Test that the script accepts the correct command-line arguments and handles missing or invalid inputs gracefully.
  - [x] Test that the script validates input files and directories correctly.

- [ ] Refactor the main script so that the code related to parsing the transcript is separate and could be covered by unit tests.
  - [x] Create a new file named `transcript_parser.rb` with a `TranscriptParser` class.
  - [x] Move only the transcript-related JSON parsing code from `TranscriptProcessor` to `TranscriptParser`.
  - [ ] Keep any CSV generation code in `TranscriptProcessor`.
  - [ ] Update `TranscriptProcessor` to call `TranscriptParser` for parsing and accessing transcript data.
  - [ ] Add or move RSpec tests ensuring `TranscriptParser` functionality is correctly covered.

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
