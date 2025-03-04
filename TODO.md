- [x] Document the code with comments for un-intuitive parts:
  - [x] Identify areas of the codebase suitable for documentation, and add a `TODO: document` comment
  - [x] Add a task for each comment to TODO.md, as a sibling to this task, and remove the comment
  - [x] Document the logic waiting for user to type 'go' to proceed in SpeakerIdentification
  - [x] Document how consecutive errors are handled and how it's used in CsvGenerator
  - [x] Document the creation of a temporary segments file for ffmpeg in SpeakerExtraction
  - [x] Document the assumption that 'speaker_labels' is always a Hash in TranscriptParser
  - [x] Document the nested logic checking for named vs unnamed speaker files in TranscriptProcessor

- [ ] Improve Specs:
  - [x] Ensure code that prints output does not interfere with RSpec output
  - [x] Review existing spec files to identify any that can be improved or do not follow RSpec best practices
    - Add a `TODO: improve` comment in each spec or block needing improvement

  - [ ] For each improvement identified with a `TODO: improve` comment, add a new sibling sub-task (i.e. add a new task
        after the one on this line) under this task describing what needs to be done, and remove the comment.

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
