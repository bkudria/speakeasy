- [ ] Document the code with comments for un-intuitive parts:
  - [x] Identify areas of the codebase suitable for documentation, and add a `TODO: document` comment
    - areas that include assumptions about the transcript JSON structure
    - areas where just reading the code wouldn't lead to a full understanding
    - areas where the code does not impart the full motivation
    - code that is particularly difficult to understand or change
    - code that appears simple but has un-intuitive or surprising behavior
  - [x] Add a task for each comment to TODO.md, as a sibling to this task, and remove the comment

- [ ] Document the logic waiting for user to type 'go' to proceed in SpeakerIdentification
- [ ] Document how consecutive errors are handled and how it's used in CsvGenerator
- [ ] Document the creation of a temporary segments file for ffmpeg in SpeakerExtraction
- [ ] Document the assumption that 'speaker_labels' is always a Hash in TranscriptParser
- [ ] Document the nested logic checking for named vs unnamed speaker files in TranscriptProcessor

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

- [ ] Add JSON Schema Validation
  - Ensures the transcript JSON strictly follows Amazon Transcribe’s structure before processing.

- [ ] Implement Logging
  - [ ] Add a configurable logging mechanism to capture debug/info/warning/error messages
  - [ ] Allow logs to be toggled or directed to a file
  - [ ] Ensure all program output (including from external `system` calls) goes through the logger, and update
        spec_helper.rb to capture logs and output them only if a spec fails, instead of mocking the global stdout/stderr
        streams.

- [ ] Add CLI Flags
  - [ ] Allow users to set options (confidence threshold, paths, skipping steps, etc.) via command-line flags
  - [ ] Provide help text for each flag

- [ ] Enhance Environmental Checks
  - [ ] Add checks for FFmpeg installation and other external dependencies
  - [ ] Guide the user if dependencies are missing

- [ ] Add Concurrency for Segment Processing
  - Reasoning: Parallelize the segment processing to speed up CSV generation for large transcripts.
  - use the ruby-concurrency gem

- [ ] 
