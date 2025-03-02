- [x] Make sure to delete the generated audio file after the TranscriptProcessor spec is done

- [x] Replace the commented placeholders in the "creates a CSV file" in `spec/transcript_processor_spec.rb` with an actual spec

- [x] Add the `standard` gem

- [ ] Add the `simplecov_json_formatter` gem, so we can use the coverage report to identify untested code regions

- [ ] Ensure `SPEC.md` is correct, complete, and up-to-date
  - Verify each step in the specification matches current code behavior
  - Update any outdated references to data structures, input formats, or behaviors

- [ ] Document the code with comments for un-intuitive parts of the code
  - Highlight any unusual logic in "csv_generator.rb" and "transcript_processor.rb"
  - Note assumptions about the transcript JSON structure

- [ ] Write a `README.md` for end-users
  - Explain how to install, run, and provide input to the script
  - Include usage examples

- [ ] Improve Specs
  - [x] Ensure code that prints output does not interfere with RSpec output
  - [ ] Adopt RSpec best practices (e.g., use `describe/context/it`, avoid `should`)
  - [ ] Refactor specs to ensure they are mutually exclusive
  - [ ] Make specs collectively exhaustive
  - [ ] Avoid functionally redundant tests
  - [ ] Only test custom logic rather than external library behavior
  - [ ] Ensure each line of code is tested at least once

- [ ] Add an integration test covering an entire run of the script
  - There is a valid transcript JSON file in `spec/fixture/asrOutput.json`
  - [ ] Verify speaker extraction, speaker identification, CSV generation, CSV writing, and low-confidence detection
  - [ ] Confirm correct script exit behavior and error handling

- [ ] 
