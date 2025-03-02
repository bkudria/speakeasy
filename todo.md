- [x] Install and configure the `simplecov` gem, for code coverage
  - SimpleCov's README is here: https://raw.githubusercontent.com/simplecov-ruby/simplecov/refs/heads/main/README.md
  - [x] Ensure tests print the coverage percentage clearly
  - [x] Implement a coverage ratchet:
    - [x] Configure SimpleCov to enforce a minimum acceptable coverage threshold
    - [x] Fail tests if coverage dips below that threshold
    - [x] Track and compare coverage from a prior run
    - [x] Fail tests if coverage decreases from the prior run

- [ ] Improve the parser tests, using fixture file spec/fixture/asrOutput.json as the source of well-formed transcript
      JSON
  - the fixture file will always contain well-formed and correct data.
  - Use placeholder values as comparison values, and temporarily disable the tests. The user will replace placeholder
    data with what the correct values should be, and re-enable the tests
  - Use only the digit `9` for placeholder numbers, and only uppercase letters for placeholder strings. If you see other
    values, that means they are not placeholders any more because the user updated them, you should not change them.
  - To write tests for malformed data, do not modify the fixture file. Instead, in the specs, either:
    - generate and use sample malformed data, or
    - parse the fixture file, and mutate the parse result so that it become malformed
  - [x] Update or create parser tests that load and parse this fixture
  - [x] Update any specs that use well-formed sample data to use the fixture data instead. To test malformed data,
        continue using or add in-spec sample data
  - [ ] Confirm coverage for:
    - [x] normal transcript data
      - [x] Ensure fixture "asrOutput.json" is loaded without error
      - [x] Validate `speaker_count` matches expected placeholder
      - [x] Validate `audio_segments` matches expected placeholder
      - [x] Validate `items` matches expected placeholder
    - [ ] missing fields
    - [ ] malformed fields
      - [ ] Introduce expectations with sample malformed transcript JSON
    - [ ] error handling
      - [ ] Introduce placeholder expectations for missing audio file scenario
      - [ ] Introduce placeholder expectations for invalid JSON structure scenario
      - [ ] Confirm the parser aborts if three consecutive segment errors occur
      - [ ] Verify appropriate exit code is returned when errors persist
  - [ ] Verify:
    - [ ] speaker_count
    - [ ] audio_segments
    - [ ] items
  - [ ] Add assertions that confirm correct identification of speakers and segments
  
- [ ] Refactor specs to ensure they are mutually exclusive, and collectively exhaustive. No spec should test only code
      that is already covered by another spec, and the specs should test all functionality of the code the cover.
- [ ] Organize the repo according to best practices for Ruby projects. Either run the commands yourself, or output the
      correct structure so the user can organize it themselves

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
