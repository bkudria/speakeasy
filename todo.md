
- [ ] Write a one-off script to generate a test fixture with a fake and humorous meeting transcript, based on the `asrOutput.json` file present.
  - this will be run once to generate the fixture, so no need to write tests for this script, and no need to update the spec for it. it will be deleted once it is run. it can be a ruby script, or a shell script. `jq` is available to use for shell scripts.
  - [ ] Remove any of the data from `asrOutput.json` that represents any content not from the middle 15 minutes of the transcript
  - [ ] Replace the remaining data with a fake transcript.
  - [ ] Replace timestamp data with artificial but realistic and self-consistent timestamps.
  
- [ ] Improve the parser tests, and use the new transcript fixture file
  - [ ] Ensure the one-off script's fake transcript fixture is correctly checked into the repository
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
