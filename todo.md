- [x] Modify the transcript naming convention.

  - [x] Change the output transcript filename to `transcript.csv`.
  - [x] If `transcript.csv` already exists in the directory, append an incrementing number to the filename (e.g., `transcript.1.csv`, `transcript.2.csv`) to avoid overwriting existing files.

- [x] Set up RSpec for testing.

  - [x] Add `rspec` to the `Gemfile`.

  - [x] Run `bundle install` to install RSpec.

  - [x] Initialize RSpec by running `rspec --init`.

  - [x] Create a `spec` directory for test files.

  - [x] Verify RSpec setup by running a sample test.

- [x] Write basic tests to ensure the script works as expected.

  - [x] Test that the script accepts the correct command-line arguments and handles missing or invalid inputs gracefully.
  - [x] Test that the script validates input files and directories correctly.

- [ ] Refactor the main script so that the code related to parsing the transcript is seperate and could be covered by unit tests.

- [ ] 
