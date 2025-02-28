- [x] after generating speaker audio, the script should pause until the user types "go"

- [ ] Modify the script to accept a directory as input argument and use it as the working directory.

  - [ ] Update the script to accept a single directory path as the command-line argument.
  - [ ] Set the working directory to the provided directory throughout the script.

- [ ] Modify the script to locate input files within the specified directory.

  - [ ] In the specified directory, find the largest audio file to use as the audio input.
  - [ ] In the specified directory, find `asrOutput.json` to use as the transcript file.
  - [ ] Validate that both the audio file and `asrOutput.json` exist.

- [ ] If named speaker files already exist in the directory, skip straight to generating the transcript.

  - [ ] Check if named speaker files exist in the directory (e.g., files matching `spk_*_*.m4a`).
  - [ ] If they exist, skip the speaker audio extraction step.

- [ ] Modify the transcript naming convention.

  - [ ] Change the output transcript filename to `transcript.csv`.
  - [ ] If `transcript.csv` already exists, append an incrementing number (e.g., `transcript.1.csv`, `transcript.2.csv`, etc.).

- [ ] 
