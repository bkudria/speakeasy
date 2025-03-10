require "rspec"
require "open3"
require "json"
require "fileutils"

module FileSystemHelpers
  # Helper methods for setting up specific mocks

  # Mock for File.exist?
  def mock_file_exists(file_path, exists = true)
    allow(File).to receive(:exist?).with(file_path).and_return(exists)
  end

  # Mock for File.read
  def mock_file_content(file_path, content)
    allow(File).to receive(:read).with(file_path).and_return(content)
  end

  # Mock for File.basename
  def mock_file_basename(file_path, extension = nil, result)
    if extension
      allow(File).to receive(:basename).with(file_path, extension).and_return(result)
    else
      allow(File).to receive(:basename).with(file_path).and_return(result)
    end
  end

  # Mock for Dir.glob
  def mock_dir_glob(pattern, files = [])
    allow(Dir).to receive(:glob).with(pattern).and_return(files)
  end

  # Mock for FileUtils operations
  def mock_fileutils_mkdir_p(dir_path)
    allow(FileUtils).to receive(:mkdir_p).with(dir_path)
  end

  def mock_fileutils_rm_f(file_path)
    allow(FileUtils).to receive(:rm_f).with(file_path)
  end

  def mock_fileutils_cp(source, destination)
    allow(FileUtils).to receive(:cp).with(source, destination)
  end

  # Mock for Kernel.system
  def mock_system_command(command_pattern, success = true)
    allow(Kernel).to receive(:system).with(command_pattern).and_return(success)
  end

  # Mock for Open3.capture3
  def mock_open3_command(command, stdout = "", stderr = "", status = double(success?: true))
    allow(Open3).to receive(:capture3).with(command).and_return([stdout, stderr, status])
  end

  # Mock for JSON.parse
  def mock_json_parse(content, result)
    allow(JSON).to receive(:parse).with(content).and_return(result)
  end
end

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
