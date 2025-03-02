- [x] Make sure to delete the generated audio file after the TranscriptProcessor spec is done

- [x] Replace the commented placeholders in the "creates a CSV file" in `spec/transcript_processor_spec.rb` with an actual spec

- [ ] Add the `standard` gem

- [ ] Add the `simplecov_json_formatter` gem, so we can use the coverage report to automatically figure out where we need to add spec

- [ ] Ensure spec.md is correct, complete, and up-to-date

- [ ] Document the code with comments for un-intuitive parts of the code

- [ ] Write a README.md for end-users

- [ ] Improve Specs
  - [x] Ensure code that prints output does not interfere with RSpec output
  - [ ] Adopt RSpec best practices
  - [ ] Refactor specs to ensure they are mutually exclusive
  - [ ] Make specs collectively exhaustive
  - [ ] Avoid functionally redundant tests
  - [ ] Only test custom logic
  - [ ] Ensure each line of code is tested at least once

- [ ] Add an integration test covering an entire run of the script
  - There is a valid transcript JSON file in spec/fixture/asrOutput.json
  - [ ] Verify speaker extraction, speaker identification, CSV generation, CSV writing, and low-confidence detection
  - [ ] Confirm correct script exit behavior and error handling

- [ ] 
