
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
