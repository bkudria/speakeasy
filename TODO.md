- [x] Make sure to delete the generated audio file after the TranscriptProcessor spec is done

- [x] Replace the commented placeholders in the "creates a CSV file" in `spec/transcript_processor_spec.rb` with an actual spec

- [x] Add the `standard` gem

- [x] Add the `simplecov_json_formatter` gem, so we can use the coverage report to identify untested code regions

- [ ] Ensure `SPEC.md` is correct, complete, and up-to-date
  - [x] Verify each step in the specification matches current code behavior
  - [x] Update any outdated references to data structures, input formats, or behaviors

- [ ] After generating speaker audio files, open the working directory in the system file manager so the user can listen to the files and identify the speakers.
  - [ ] Detect the operating system within the script.
    - [ ] On **macOS**, use `open <directory>`.
    - [ ] On **Windows**, use `start <directory>`.
    - [ ] On **Linux**, use `xdg-open <directory>`.
  - [ ] Execute the corresponding command to open the directory.
  

- [ ] Document the code with comments for un-intuitive parts of the code
  - [ ] Highlight any unusual logic in `csv_generator.rb` and `transcript_processor.rb`
  - [ ] Note assumptions about the transcript JSON structure

- [ ] Write a `README.md` for end-users
  - [ ] Explain how to install, run, and provide input to the script
  - [ ] Include usage examples

- [ ] Improve Specs
  - [x] Ensure code that prints output does not interfere with RSpec output
  - [ ] Adopt RSpec best practices (e.g., use `describe/context/it`, avoid `should`)
  - [ ] Refactor specs to ensure they are mutually exclusive
  - [ ] Make specs collectively exhaustive
  - [ ] Avoid functionally redundant tests
  - [ ] Only test custom logic rather than external library behavior

- [ ] Detect and correct speaker mis-identification in the input JSON, and correct it in the output CSV
  - [ ] Detect incorrectly labeled segments by analyzing sentence boundaries
  - [ ] Realign them with the correct speaker label in the final CSV
  - [ ] Word-level confidence & overlap checks
  - [ ] Pause & silence analysis

- [ ] Implement the "multiple speakers" note - if a row has segments or items whose timestamp overlaps with previous or
      subsequent rows with differing speakers, both or all 3 rows should have "multiple speakers" in the notes column

- [ ] Provide a manual review step if mis-labeling is suspected

- [ ] 
