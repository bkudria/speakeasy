require "rspec"
require "open3"
require "json"
require "fileutils"

# @module FileSystemHelpers
#
# A comprehensive mocking strategy for managing external dependencies in tests,
# particularly file system operations and external commands.
#
# ## Mocking Strategy Principles
#
# 1. **Safe Default Behavior**: By default, prevent any actual file system operations in tests.
#    All file system calls are either mocked to return empty/false values or configured to raise
#    clear error messages when not explicitly mocked.
#
# 2. **Consistent API**: All mock methods follow a consistent naming convention starting with `mock_`
#    and have consistent parameter ordering (target path first, then expected return values).
#
# 3. **Shared Contexts**: Use shared RSpec contexts to set up common testing scenarios and reuse
#    mock configurations across multiple test files.
#
# 4. **Explicit Mocking**: Each test explicitly declares the mocks it requires, making tests
#    self-contained and avoiding hidden dependencies between tests.
#
# 5. **Verify Partial Doubles**: Uses RSpec's `verify_partial_doubles = true` to ensure mocked
#    methods actually exist on the original objects, preventing errors from mocking non-existent methods.
#
# ## Using This Module
#
# - Include this module in your test file or shared context: `include FileSystemHelpers`
# - For common file system protection, include the shared context: `include_context "file system mocks"`
# - For specific component tests, use the specialized contexts like: `include_context "transcript processor file system mocks"`
# - Set up specific mocks using the helper methods below for each test case
#
# ## Example Usage
#
# ```ruby
# RSpec.describe MyClass do
#   include FileSystemHelpers
#
#   before do
#     mock_file_exists("config.json", true)
#     mock_file_content("config.json", '{"setting": "value"}')
#     mock_json_parse('{"setting": "value"}', {"setting" => "value"})
#   end
#
#   it "reads settings from a config file" do
#     result = MyClass.new.read_config
#     expect(result).to eq({"setting" => "value"})
#   end
# end
# ```
module FileSystemHelpers
  #--------------------------------------------------
  # File Operations
  #--------------------------------------------------

  # Mock the File.exist? method for a specific file path
  #
  # @param file_path [String] Path to the file to mock
  # @param exists [Boolean] Whether the file should exist or not (default: true)
  #
  # @example
  #   # Mock a file that exists
  #   mock_file_exists("config.json", true)
  #
  #   # Mock a file that doesn't exist
  #   mock_file_exists("missing.txt", false)
  def mock_file_exists(file_path, exists = true)
    allow(File).to receive(:exist?).with(file_path).and_return(exists)
  end

  # Mock the File.read method for a specific file path
  #
  # @param file_path [String] Path to the file to mock
  # @param content [String] Content to return when the file is read
  #
  # @example
  #   # Mock file content as JSON
  #   mock_file_content("config.json", '{"key": "value"}')
  #
  #   # Mock file content as plain text
  #   mock_file_content("log.txt", "Error message")
  def mock_file_content(file_path, content)
    allow(File).to receive(:read).with(file_path).and_return(content)
  end

  # Mock the File.basename method for a specific file path
  #
  # @param file_path [String] Path to the file to mock
  # @param extension [String, nil] Optional extension to strip (default: nil)
  # @param result [String] The basename to return
  #
  # @example
  #   # Mock basename without extension
  #   mock_file_basename("/path/to/file.txt", nil, "file.txt")
  #
  #   # Mock basename with extension stripped
  #   mock_file_basename("/path/to/file.txt", ".txt", "file")
  def mock_file_basename(file_path, extension = nil, result)
    if extension
      allow(File).to receive(:basename).with(file_path, extension).and_return(result)
    else
      allow(File).to receive(:basename).with(file_path).and_return(result)
    end
  end

  #--------------------------------------------------
  # Directory Operations
  #--------------------------------------------------

  # Mock the Dir.glob method for a specific pattern
  #
  # @param pattern [String] Glob pattern to mock
  # @param files [Array<String>] List of file paths to return (default: empty array)
  #
  # @example
  #   # Mock finding no files
  #   mock_dir_glob("*.txt", [])
  #
  #   # Mock finding specific files
  #   mock_dir_glob("*.txt", ["file1.txt", "file2.txt"])
  def mock_dir_glob(pattern, files = [])
    allow(Dir).to receive(:glob).with(pattern).and_return(files)
  end

  #--------------------------------------------------
  # FileUtils Operations
  #--------------------------------------------------

  # Mock the FileUtils.mkdir_p method
  #
  # @param dir_path [String] Directory path to mock creation for
  #
  # @example
  #   # Mock creating a directory
  #   mock_fileutils_mkdir_p("tmp/output")
  def mock_fileutils_mkdir_p(dir_path)
    allow(FileUtils).to receive(:mkdir_p).with(dir_path)
  end

  # Mock the FileUtils.rm_f method
  #
  # @param file_path [String] File path to mock removal for
  #
  # @example
  #   # Mock removing a file
  #   mock_fileutils_rm_f("tmp/output/file.txt")
  def mock_fileutils_rm_f(file_path)
    allow(FileUtils).to receive(:rm_f).with(file_path)
  end

  # Mock the FileUtils.cp method
  #
  # @param source [String] Source file path
  # @param destination [String] Destination file path
  #
  # @example
  #   # Mock copying a file
  #   mock_fileutils_cp("source.txt", "destination.txt")
  def mock_fileutils_cp(source, destination)
    allow(FileUtils).to receive(:cp).with(source, destination)
  end

  #--------------------------------------------------
  # System Commands
  #--------------------------------------------------

  # Mock the Kernel.system method
  #
  # @param command_pattern [String, Regexp] Command string or pattern to match
  # @param success [Boolean] Whether the command succeeds (default: true)
  #
  # @example
  #   # Mock a successful command
  #   mock_system_command("ffmpeg -i input.mp4 output.mp3", true)
  #
  #   # Mock a failed command
  #   mock_system_command("invalid_command", false)
  #
  #   # Mock using a regex pattern
  #   mock_system_command(/^ffmpeg/, true)
  def mock_system_command(command_pattern, success = true)
    allow(Kernel).to receive(:system).with(command_pattern).and_return(success)
  end

  # Mock the Open3.capture3 method
  #
  # @param command [String] Command to mock
  # @param stdout [String] Standard output to return (default: empty string)
  # @param stderr [String] Standard error to return (default: empty string)
  # @param status [Object] Status object with success? method (default: successful)
  #
  # @example
  #   # Mock a successful command with output
  #   mock_open3_command("echo hello", "hello", "", double(success?: true))
  #
  #   # Mock a failed command with error
  #   mock_open3_command("invalid", "", "command not found", double(success?: false))
  def mock_open3_command(command, stdout = "", stderr = "", status = double(success?: true))
    allow(Open3).to receive(:capture3).with(command).and_return([stdout, stderr, status])
  end

  #--------------------------------------------------
  # Data Parsing
  #--------------------------------------------------

  # Mock the JSON.parse method
  #
  # @param content [String] JSON string to mock parsing for
  # @param result [Hash, Array] Result to return when parsing
  #
  # @example
  #   # Mock parsing JSON to a Hash
  #   mock_json_parse('{"key": "value"}', {"key" => "value"})
  def mock_json_parse(content, result)
    allow(JSON).to receive(:parse).with(content).and_return(result)
  end

  #--------------------------------------------------
  # Complex Mocking Helpers
  #--------------------------------------------------

  # Mock a complete file read and parse workflow
  #
  # @param file_path [String] Path to the file
  # @param content [String] Raw file content
  # @param parsed_result [Hash, Array] Result of parsing the content
  #
  # @example
  #   # Mock reading and parsing a JSON file
  #   mock_file_read_and_parse(
  #     "config.json",
  #     '{"setting": "value"}',
  #     {"setting" => "value"}
  #   )
  def mock_file_read_and_parse(file_path, content, parsed_result)
    mock_file_exists(file_path, true)
    mock_file_content(file_path, content)
    mock_json_parse(content, parsed_result)
  end

  # Mock a file write operation
  #
  # @param file_path [String] Path to the file
  # @param expected_content [String] Content expected to be written
  #
  # @example
  #   # Mock writing to a file
  #   mock_file_write("output.txt", "Hello, world!")
  def mock_file_write(file_path, expected_content)
    file_double = double("File")
    allow(File).to receive(:open).with(file_path, "w").and_yield(file_double)
    allow(file_double).to receive(:write).with(expected_content)
  end
  
  # Mock a command execution with arguments
  #
  # @param command [String] Base command
  # @param args [Array<String>] Command arguments
  # @param success [Boolean] Whether the command succeeds
  # @param stdout [String] Standard output to return
  # @param stderr [String] Standard error to return
  #
  # @example
  #   # Mock executing ffmpeg with arguments
  #   mock_command_with_args(
  #     "ffmpeg",
  #     ["-i", "input.mp4", "-c:a", "aac", "output.m4a"],
  #     true,
  #     "Processing complete",
  #     ""
  #   )
  #
  #   # This will mock these exact commands:
  #   # system("ffmpeg -i input.mp4 -c:a aac output.m4a")
  #   # Open3.capture3("ffmpeg -i input.mp4 -c:a aac output.m4a")
  def mock_command_with_args(command, args, success = true, stdout = "", stderr = "")
    full_command = [command, *args].join(" ")
    allow(Kernel).to receive(:system).with(full_command).and_return(success)
    allow(Open3).to receive(:capture3).with(full_command).and_return([stdout, stderr, double(success?: success)])
  end
end

# Shared context for basic file system mocks
#
# This context prevents any actual file system operations by default by
# setting up restrictive mocks for common file system methods.
#
# @example
#   RSpec.describe MyClass do
#     include_context "file system mocks"
#
#     it "doesn't access the real file system" do
#       # All file system access is prevented by default
#       # You must explicitly mock what you need
#     end
#   end
RSpec.shared_context "file system mocks" do
  include FileSystemHelpers

  # Default mocks for common operations
  before do
    # Prevent any actual file system operations by default
    allow(File).to receive(:exist?).and_return(false)
    allow(File).to receive(:read).and_raise("File.read not mocked for this file")
    allow(Dir).to receive(:glob).and_return([])
    allow(FileUtils).to receive(:mkdir_p)
    allow(FileUtils).to receive(:rm_f)
    allow(FileUtils).to receive(:cp)

    # Mock system commands
    allow(Kernel).to receive(:system).and_return(true)

    # Mock Open3 commands
    allow(Open3).to receive(:capture3).and_return(["", "", double(success?: true)])
  end
end

# Specific shared context for TranscriptProcessor tests
#
# This context extends the basic file system mocks with specific
# configuration for TranscriptProcessor tests, including common
# test paths, test data, and mocked responses.
#
# @example
#   RSpec.describe TranscriptProcessor do
#     include_context "transcript processor file system mocks"
#
#     it "processes transcripts with mocked file operations" do
#       # All file system operations are mocked with TranscriptProcessor-specific values
#     end
#   end
RSpec.shared_context "transcript processor file system mocks" do
  include_context "file system mocks"

  # Common test paths
  let(:valid_json_path) { "spec/fixture/asrOutput.json" }
  let(:valid_audio_path) { "spec/fixture/audio.m4a" }
  let(:invalid_json_path) { "nonexistent.json" }
  let(:invalid_audio_path) { "nonexistent.m4a" }
  let(:output_dir) { Dir.pwd }

  # Common test data
  let(:valid_json_content) do
    # Read the actual fixture for use in tests
    File.read("spec/fixture/asrOutput.json")
  rescue
    '{"results":{"transcripts":[{"transcript":"Test"}],"speaker_labels":{"speakers":1,"segments":[]}}}'
  end

  let(:valid_json_data) do
    JSON.parse(valid_json_content)
  end

  before do
    # Mock file existence checks for common paths
    mock_file_exists(valid_json_path, true)
    mock_file_exists(valid_audio_path, true)
    mock_file_exists(invalid_json_path, false)
    mock_file_exists(invalid_audio_path, false)

    # Mock file content for common paths
    mock_file_content(valid_json_path, valid_json_content)

    # Mock JSON parsing
    mock_json_parse(valid_json_content, valid_json_data)

    # Mock file basename operations
    mock_file_basename(valid_json_path, ".*", "asrOutput")

    # Mock directory operations for speaker files
    mock_dir_glob(File.join(output_dir, "spk_*_*.m4a"), [])
    mock_dir_glob(File.join(output_dir, "spk_*.m4a"), [])

    # Mock system commands for opening directories
    allow(Kernel).to receive(:system) do |cmd|
      case cmd
      when /\A(open|start|xdg-open)\s/
      end
      true
    end

    # Mock ffmpeg availability check
    mock_open3_command("ffmpeg -version", "ffmpeg version", "", double(success?: true))
  end
end