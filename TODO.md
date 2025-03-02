- [x] Make sure to delete the generated audio file after the TranscriptProcessor spec is done

- [x] Replace the commented placeholders in the "creates a CSV file" in `spec/transcript_processor_spec.rb` with an actual spec

- [x] Add the `standard` gem

- [x] Add the `simplecov_json_formatter` gem, so we can use the coverage report to identify untested code regions

- [x] Ensure `SPEC.md` is correct, complete, and up-to-date
  - [x] Verify that each step in the specification matches the current code behavior
  - [x] Update any outdated references to data structures, input formats, or behaviors

- [ ] After generating speaker audio files, open the working directory in the system file manager so the user can listen to and rename the files:
  - [x] Detect the operating system in the script:
    - [x] On **macOS**, run `open <directory>`
    - [x] On **Windows**, run `start <directory>`
    - [x] On **Linux**, run `xdg-open <directory>`
  - [x] Execute the correct command to open the directory

- [ ] Document the code with comments for un-intuitive parts:
  - [ ] Highlight any unusual logic in `csv_generator.rb` and `transcript_processor.rb`
  - [ ] Note assumptions about the transcript JSON structure

- [ ] Write a `README.md` for end-users:
  - [ ] Explain how to install the script
  - [ ] Explain how to run and provide input
  - [ ] Show usage examples

- [ ] Improve Specs:
  - [x] Ensure code that prints output does not interfere with RSpec output
  - [ ] Adopt RSpec best practices (e.g., use `describe/context/it` instead of `should`)
  - [ ] Refactor specs so each test is mutually exclusive
  - [ ] Make the specs collectively exhaustive of expected behaviors
  - [ ] Avoid functionally redundant tests
  - [ ] Only test custom logic rather than external library behavior

- [ ] Detect and correct speaker mis-identification in the input JSON, and fix it in the output CSV:
  - [ ] Detect incorrectly labeled segments by analyzing sentence boundaries
  - [ ] Realign these segments with the correct speaker label in the final CSV
  - [ ] Perform word-level confidence and overlap checks
  - [ ] Perform pause and silence analysis
  - [ ] Add a "review" note to any rows you do not automatically correct

- [ ] Implement a "multiple speakers" note:
  - [ ] If a row's timestamps overlap with previous or subsequent rows that have different speakers, mark all involved rows with "multiple speakers" in the Note column

- [ ] As we generate each row, examine its confidence level and add a "review" note:
  - [ ] Allow multiple values in the "note" column, separated by a comma

- [ ] Provide a manual review step if mis-labeling is suspected. This step should occur after the entire CSV is written.

- [ ] Implement Logging
  - [ ] Add a configurable logging mechanism to capture debug/info/warning/error messages
  - [ ] Allow logs to be toggled or directed to a file

- [ ] Add CLI Flags
  - [ ] Allow users to set options (confidence threshold, paths, skipping steps, etc.) via command-line flags
  - [ ] Provide help text for each flag

- [ ] Create Integration Tests
  - [ ] Add end-to-end tests that run the entire script with sample JSON/audio input
  - [ ] Verify all steps work together correctly

- [ ] Automate OS Detection Tests
  - [ ] Test the script's "open directory" logic on each supported OS
  - [ ] Consider using CI with different OS runners

- [ ] Enhance Environmental Checks
  - [ ] Add checks for FFmpeg installation and other external dependencies
  - [ ] Guide the user if dependencies are missing

- [ ] 
