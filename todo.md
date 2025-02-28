- [ ] Modify the transcript naming convention.

  - [ ] Change the output transcript filename to `transcript.csv`.
  - [ ] If `transcript.csv` already exists in the directory, append an incrementing number to the filename (e.g., `transcript.1.csv`, `transcript.2.csv`) to avoid overwriting existing files.

- [ ] After generating speaker audio files, open the working directory in the system file manager so the user can listen to the files and identify the speakers.

  - [ ] Detect the operating system within the script.
    - [ ] On **macOS**, use `open <directory>`.
    - [ ] On **Windows**, use `start <directory>`.
    - [ ] On **Linux**, use `xdg-open <directory>`.
  - [ ] Execute the corresponding command to open the directory.

- [ ] Set up RSpec for testing.

  - [ ] Install RSpec in the project.
  - [ ] Initialize RSpec configuration files.

- [ ] Write basic tests to ensure the script works as expected.

  - [ ] Test that the script accepts the correct command-line arguments and handles missing or invalid inputs gracefully.
  - [ ] Test that the script validates input files and directories correctly.
  - [ ] Test the core functionality of the script with valid inputs.

- [ ] Write advanced tests.

  - [ ] Create test fixtures based on `asrOutput.json`.
    - [ ] Write a one-off script to generate a test fixture with a fake and humorous meeting transcript.
      - [ ] Remove most of the original data in `asrOutput.json`.
      - [ ] Replace the remaining data with a fake transcript.
      - [ ] Replace timestamp data with artificial but realistic and self-consistent timestamps.
  - [ ] Use the test fixture to test complex scenarios.
    - [ ] Test how the script handles multiple speakers with overlapping dialogues.
    - [ ] Test the script's error handling with malformed or unexpected data.

- [ ] 
