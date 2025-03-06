- [ ] Migrate transcript construction to use individual items instead of audio_segments
  - [x] Update TranscriptParser to provide a clear, structured list of items (tokens) ready for grouping by speaker
  - [ ] Adjust CsvGenerator (and related code in TranscriptProcessor) to iterate over items for row construction, rather than audio_segments.
    - [ ] Step 1 (Failing Spec): Ensure CsvGenerator uses item-based data instead of audio_segments
    - [ ] Step 2 (Implementation): Modify CsvGenerator to process individual items
    - [ ] Step 3 (Failing Spec): Verify TranscriptProcessor provides item-level data to CsvGenerator
    - [ ] Step 4 (Implementation): Update TranscriptProcessor to fully rely on items, not audio_segments
    - [ ] Step 5 (Failing Spec): Check speaker continuity at item level (time gaps, same speaker)
    - [ ] Step 6 (Implementation): Implement continuity logic to group items in rows
    - [ ] Step 7 (Failing Spec): Test punctuation, confidence, and multi-speaker transitions at item level
    - [ ] Step 8 (Implementation): Enhance item-based logic (punctuation, confidence calc, multi-speaker)
    - [ ] Step 9 (Failing Spec): Integration test with a JSON fixture using items only
    - [ ] Step 10 (Implementation): Clean up references to audio_segments and confirm end-to-end flow
  - [ ] Ensure speaker_label handling is consistent at the item level, preserving speaker continuity when forming rows.
  - [ ] Add or update specs to confirm the new item-driven approach produces correct transcripts (with speaker labels, punctuation, confidence stats).
  
- [ ] Write specs for mis-labeled segments and misaligned sentences in the input JSON
  - We will follow TDD to separate detection specs from correction specs, writing failing specs first
  - Generally, these mis-alignments are only one or two words, and corrected rows should reflect complete sentences

  - [ ] Detection specs:
    - [ ] Add specs for detecting incorrectly labeled segments by analyzing sentence boundaries (punctuation data)
      - Misalignment examples:
        - Sore Throat:
          - Misaligned:
              Bob: Of course, yeah, it sounds like, you have uh a bit of a sore throat, so I hope you feel better. Thank
              Gloria: you. I appreciate it.
          - Corrected:
              Bob: Of course, yeah, it sounds like, you have uh a bit of a sore throat, so I hope you feel better.
              Gloria: Thank you. I appreciate it.
        - Real Words:
          - Misaligned:
              Bob: It's a good talent to be able to say that. It's not actually
              Gloria: you. I appreciate it.
          - Corrected:
              Bob: Of course, yeah, it sounds like, you have uh a bit of a sore throat, so I hope you feel better.
              Jim: a real word. I learned that
        - Not a misalignment: even if Jim doesn't have a complete sentence, Bob starts a new sentence, indicating that
          Bob interrupted Jim. This transcript is correct:
            Jim: Hey Bob, question. Is it your intention or your recommendation that we fill up all 22 slots next Wednesday? That would be a
            Bob: I mean, I think that is the ideal scenario.

    - [ ] Add specs that test word-level confidence and overlap to verify alignment
    - [ ] Add specs that test pause/silence data to confirm correct segmentation
    - [ ] Add specs for time-based adjacency checks for short offsets from expected boundaries
    - [ ] Add specs for cross-speaker transition checks to verify trailing words belong to the next speaker
    - [ ] Add specs for aggregated confidence trending to detect abrupt confidence drops (indicating misalignment)

  - [ ] Correction specs:
    - [ ] Add specs to show that short misaligned words (1–2 words) are moved to the correct speaker row
    - [ ] If in doubt about which speaker a fragment belongs to, mark the affected row(s) with "review" in the Note

- [ ] Implement a "multiple speakers" note:
  - [ ] If any row's timestamps overlap with other rows bearing different speakers, mark all involved rows with "multiple speakers" in the Note column

- [ ] Add a "review" note for low-confidence segments:
  - [ ] Allow multiple values in the "note" column, separated by commas

- [ ] Provide a manual review step for suspected mis-labeling, occurring after the CSV is fully written.

- [ ] Implement mis-labeled segment detection logic in MisalignmentDetector
- [ ] Implement code to correct mis-labeled segments in MisalignmentCorrector

- [ ] Implement optional punctuation-based boundary detection
  - [ ] Create or update logic to detect sentence boundaries from punctuation tokens.
  - [ ] Use punctuation to form row segments, ensuring short fragments aren’t merged incorrectly.
  - [ ] Write new specs or update existing ones to verify punctuation-based segmentation (including edge cases).

- [ ] Validate final CSV rows under the new item-based workflow
  - [ ] Confirm row-level confidence calculations (min, max, mean, median) match the aggregated items.
  - [ ] Validate that each row’s speaker and transcript text are correct after item grouping.
  - [ ] Ensure existing integration specs (or new ones) pass with this approach.

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
  - [ ] Add a CLI option to configure threshold values for confidence-based detection
  - [ ] Add command-line flags to enable or disable specific misalignment checks
  - [ ] Provide help text for each flag

- [ ] Enhance Environmental Checks
  - [ ] Add checks for FFmpeg installation and other external dependencies
  - [ ] Guide the user if dependencies are missing

- [ ] Add Concurrency for Segment Processing
  - Reasoning: Parallelize the segment processing to speed up CSV generation for large transcripts.
  - use the ruby-concurrency gem

- [ ] Create Integration Tests
  - [ ] Add end-to-end tests that run the entire script with sample JSON/audio input
  - [ ] Verify all steps work together correctly

- [ ] Automate OS Detection Tests
  - [ ] Test the script's "open directory" logic on each supported OS
  - [ ] Consider using CI with different OS runners

- [ ] Thorough Error Logging with Time Stamps
  - Provide clearer debugging by including timestamps and error categories in logs.

- [ ] Write a `README.md` for end-users:
  - [ ] Explain how to install the script
  - [ ] Explain how to run and provide input
  - [ ] Show usage examples

- [ ] Add Performance Profiling
  - [ ] Identify bottlenecks in segment extraction and CSV generation
  - [ ] Use a Ruby profiling tool (e.g., ruby-prof) to measure run times
  - [ ] Summarize and report any areas needing optimization

- [ ] Generate a Code Coverage Report
  - [ ] Integrate a coverage tool (e.g., SimpleCov)
  - [ ] Include coverage reports in CI pipeline if present
  - [ ] Ensure minimal coverage thresholds for merging

- [ ] Provide Example Usage
  - [ ] Create an example folder with sample input data
  - [ ] Document expected usage flow in README or separate guide
  - [ ] Show sample output files to demonstrate typical results

- [ ] Improve Error Messages
  - [ ] Review existing error messages for clarity
  - [ ] Provide user-friendly guidance and suggested resolutions

- [ ] Create a Project Website
  - [ ] Provide a GitHub Pages or similar simple site
  - [ ] Include short guide, screenshots, and usage demos
