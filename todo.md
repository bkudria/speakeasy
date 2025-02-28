- [x] After generating speaker audio, the script should pause until the user types "go".

- [x] Modify the script to accept a directory as an input argument and use it as the working directory.

  - [x] Update the script to accept a single directory path as the command-line argument.
  - [x] Validate that the provided directory exists and is accessible.
  - [x] Set the working directory to the provided directory throughout the script.

- [x] Modify the script to locate input files within the specified directory.

  - [x] In the specified directory, find the largest audio file to use as the audio input.
    - [x] Search for audio files with common extensions (e.g., `.wav`, `.mp3`, `.m4a`).
    - [x] Determine the largest audio file by file size among these.
  - [x] In the specified directory, find `asrOutput.json` to use as the transcript file.
  - [x] Validate that both the audio file and `asrOutput.json` exist.
    - [x] If they don't exist, inform the user with a clear error message and exit the script.

- [x] Modify the script to handle existing speaker audio files.

  - [x] Check if **named** speaker files exist in the directory (files matching `spk_*_*.m4a`, where the second `*` is the speaker's name).
    - [x] If named speaker files exist, skip the speaker audio extraction step and proceed to generate the transcript.
  - [x] If **unnamed** speaker files exist (files matching `spk_*.m4a` without speaker names), inform the user.
    - [x] Instruct the user to rename the files to identify the speakers.
    - [x] Wait for the user to type `go` and press Enter after renaming.
  - [x] If no speaker files exist, proceed to extract speaker audio as normal.

- [ ] Modify the transcript naming convention.

  - [ ] Change the output transcript filename to `transcript.csv`.
  - [ ] If `transcript.csv` already exists in the directory, append an incrementing number to the filename (e.g., `transcript.1.csv`, `transcript.2.csv`) to avoid overwriting existing files.

- [ ] After speaker-specific audio files are generated, execute a system command to open the working directory in the
      system file manager so the user can listen to the files and identify the speakers.

  - [ ] Use the appropriate command based on the operating system:
    - [ ] On **macOS**, use `open <directory>`.
    - [ ] On **Windows**, use `start <directory>`.
    - [ ] On **Linux**, use `xdg-open <directory>`.
  - [ ] Detect the operating system within the script and execute the corresponding command.
  
- [ ] Update script documentation.

  - [ ] Update the usage instructions and help messages to reflect the new command-line arguments and behaviors.
  - [ ] Ensure the script's README or documentation is updated accordingly.

- [ ] 
