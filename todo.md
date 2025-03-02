- [x] Make sure to delete the generated audio file after the TranscriptProcessor spec is done

- [x] Replace the commented placeholders in the "creates a CSV file" in `spec/transcript_processor_spec.rb` with an actual spec

- [ ] Improve Specs
  - [x] Ensure code that prints output does not interfere with RSpec output
  - [ ] Refactor specs to ensure they are mutually exclusive
  - [ ] Make specs collectively exhaustive
  - [ ] Avoid functionally redundant tests
  - [ ] Only test custom logic
  - [ ] Ensure each line of code is tested at least once
  - [ ] Adopt RSpec best practices

- [ ] Add the `standard` gem

- [ ] Add an integration test covering an entire run of the script
  - There is a valid transcript JSON file in spec/fixture/asrOutput.json
  - [ ] Verify speaker extraction, speaker identification, CSV generation, CSV writing, and low-confidence detection
  - [ ] Confirm correct script exit behavior and error handling

- [ ] 
