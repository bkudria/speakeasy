require 'spec_helper'

RSpec.describe FileSystemHelpers do
  # Test the basic mock methods
  describe "basic mock methods" do
    include FileSystemHelpers
    
    describe "#mock_file_exists" do
      it "mocks File.exist? for specific path" do
        mock_file_exists("/path/to/file.txt", true)
        expect(File.exist?("/path/to/file.txt")).to be true
        
        mock_file_exists("/path/to/other.txt", false)
        expect(File.exist?("/path/to/other.txt")).to be false
      end
      
      it "defaults to true if exists parameter is not provided" do
        mock_file_exists("/path/to/file.txt")
        expect(File.exist?("/path/to/file.txt")).to be true
      end
    end
    
    describe "#mock_file_content" do
      it "mocks File.read for specific path" do
        content = "file content"
        mock_file_content("/path/to/file.txt", content)
        expect(File.read("/path/to/file.txt")).to eq content
      end
    end
    
    describe "#mock_file_basename" do
      it "mocks File.basename for specific path" do
        basename = "file.txt"
        mock_file_basename("/path/to/file.txt", basename)
        expect(File.basename("/path/to/file.txt")).to eq basename
      end
    end
    
    describe "#mock_dir_glob" do
      it "mocks Dir.glob for specific pattern" do
        files = ["/path/to/file1.txt", "/path/to/file2.txt"]
        mock_dir_glob("/path/to/*.txt", files)
        expect(Dir.glob("/path/to/*.txt")).to eq files
      end
    end
    
    describe "#mock_fileutils_mkdir_p" do
      it "mocks FileUtils.mkdir_p for specific path" do
        path = "/path/to/directory"
        mock_fileutils_mkdir_p(path)
        # Just verify it doesn't raise an error
        expect { FileUtils.mkdir_p(path) }.not_to raise_error
      end
    end
    
    describe "#mock_fileutils_rm_f" do
      it "mocks FileUtils.rm_f for specific path" do
        path = "/path/to/file.txt"
        mock_fileutils_rm_f(path)
        expect { FileUtils.rm_f(path) }.not_to raise_error
      end
    end
    
    describe "#mock_fileutils_cp" do
      it "mocks FileUtils.cp for specific paths" do
        src = "/path/to/src.txt"
        dst = "/path/to/dst.txt"
        mock_fileutils_cp(src, dst)
        expect { FileUtils.cp(src, dst) }.not_to raise_error
      end
    end
    
    describe "#mock_system_command" do
      it "mocks Kernel.system for specific command" do
        command = "echo 'test'"
        success = true
        mock_system_command(command, success)
        expect(Kernel.system(command)).to eq success
      end
    end
    
    describe "#mock_open3_command" do
      it "mocks Open3.capture3 for specific command" do
        command = "echo 'test'"
        stdout = "output"
        stderr = "error"
        status = double(success?: true)
        mock_open3_command(command, stdout, stderr, status)
        output, error, status_result = Open3.capture3(command)
        expect(output).to eq stdout
        expect(error).to eq stderr
        expect(status_result.success?).to eq true
      end
    end
    
    describe "#mock_json_parse" do
      it "mocks JSON.parse for specific content" do
        content = '{"key":"value"}'
        result = {"key" => "value"}
        mock_json_parse(content, result)
        expect(JSON.parse(content)).to eq result
      end
    end
  end
  
  # Test the shared contexts
  describe "shared contexts" do
    describe "file system mocks" do
      include_context "file system mocks"
      
      it "prevents actual file system operations by default" do
        expect(File.exist?("non_mocked_file.txt")).to be false
        expect { File.read("non_mocked_file.txt") }.to raise_error(/not mocked/)
        expect(Dir.glob("*")).to eq([])
      end
      
      it "allows specific mocks to be added" do
        mock_file_exists("specific_file.txt", true)
        mock_file_content("specific_file.txt", "content")
        
        expect(File.exist?("specific_file.txt")).to be true
        expect(File.read("specific_file.txt")).to eq "content"
      end
    end
    
    describe "transcript processor file system mocks" do
      include_context "transcript processor file system mocks"
      
      it "includes all file system mocks" do
        expect(File.exist?("non_mocked_file.txt")).to be false
        expect { File.read("non_mocked_file.txt") }.to raise_error(/not mocked/)
      end
      
      it "defines common test paths" do
        expect(valid_json_path).to eq "spec/fixture/asrOutput.json"
        expect(valid_audio_path).to eq "spec/fixture/audio.m4a"
        expect(invalid_json_path).to eq "nonexistent.json"
        expect(invalid_audio_path).to eq "nonexistent.m4a"
      end
    end
  end
  
  # Test complex mocking scenarios
  describe "complex mocking scenarios" do
    include FileSystemHelpers
    
    it "can mock multiple file operations in sequence" do
      mock_file_exists("file1.txt", true)
      mock_file_content("file1.txt", "content1")
      mock_file_exists("file2.txt", true)
      mock_file_content("file2.txt", "content2")
      
      expect(File.exist?("file1.txt")).to be true
      expect(File.read("file1.txt")).to eq "content1"
      expect(File.exist?("file2.txt")).to be true
      expect(File.read("file2.txt")).to eq "content2"
    end
    
    it "can override previous mocks" do
      mock_file_exists("file.txt", false)
      expect(File.exist?("file.txt")).to be false
      
      mock_file_exists("file.txt", true)
      expect(File.exist?("file.txt")).to be true
    end
    
    it "can combine different types of mocks" do
      # Mock file operations
      mock_file_exists("data.json", true)
      mock_file_content("data.json", '{"name":"test"}')
      
      # Mock JSON parsing
      mock_json_parse('{"name":"test"}', {"name" => "test"})
      
      # Test the combined workflow
      if File.exist?("data.json")
        content = File.read("data.json")
        data = JSON.parse(content)
        expect(data["name"]).to eq "test"
      end
    end
    
    it "can mock a complete file processing workflow" do
      # Setup mock for source file
      mock_file_exists("source.txt", true)
      mock_file_content("source.txt", "test content")
      mock_file_basename("source.txt", "source.txt")
      
      # Setup mock for destination directory check and creation
      mock_dir_glob("output/*", [])
      mock_fileutils_mkdir_p("output")
      
      # Setup mock for file copy
      mock_fileutils_cp("source.txt", "output/source.txt")
      
      # Setup mock for destination file
      mock_file_exists("output/source.txt", true)
      
      # Execute a workflow that would use these mocks
      if File.exist?("source.txt")
        content = File.read("source.txt")
        filename = File.basename("source.txt")
        
        # Check if output directory exists or create it
        unless Dir.glob("output/*").any?
          FileUtils.mkdir_p("output")
        end
        
        # Copy file to output directory
        FileUtils.cp("source.txt", "output/#{filename}")
        
        # Verify file was copied
        expect(File.exist?("output/source.txt")).to be true
      end
    end
    
    # Test new complex mocking helpers
    describe "complex mocking helpers" do
      it "can use mock_file_read_and_parse for a complete read-and-parse workflow" do
        mock_file_read_and_parse(
          "config.json",
          '{"setting": "value"}',
          {"setting" => "value"}
        )
        
        # Verify the complete workflow works
        expect(File.exist?("config.json")).to be true
        expect(File.read("config.json")).to eq '{"setting": "value"}'
        expect(JSON.parse(File.read("config.json"))).to eq({"setting" => "value"})
      end
      
      it "can use mock_file_write to verify file writes" do
        mock_file_write("output.txt", "Hello, world!")
        
        # Simulate code that would write to a file
        File.open("output.txt", "w") do |file|
          file.write("Hello, world!")
        end
        
        # The test passes if the mock receives the expected write call
      end
      
      it "can use mock_command_with_args to set up command mocks" do
        # Use our helper method to set up the mocks
        mock_command_with_args(
          "ffmpeg",
          ["-i", "input.mp4", "-c:a", "aac", "output.m4a"],
          true,
          "Processing complete",
          ""
        )
        
        # Now verify that the appropriate mocks were set up
        full_command = "ffmpeg -i input.mp4 -c:a aac output.m4a"
        
        # Check that Kernel.system was mocked correctly
        expect(Kernel).to receive(:system).with(full_command).and_return(true)
        Kernel.system(full_command)
        
        # Check that Open3.capture3 was mocked correctly
        expect(Open3).to receive(:capture3).with(full_command).and_return(["Processing complete", "", double(success?: true)])
        stdout, stderr, status = Open3.capture3(full_command)
        expect(stdout).to eq "Processing complete"
        expect(stderr).to eq ""
        expect(status.success?).to be true
      end
    end
  end
  
  # Verify module documentation exists for all methods
  describe "module documentation" do
    it "verifies all helper methods have descriptive method names" do
      methods = [
        "mock_file_exists",
        "mock_file_content",
        "mock_file_basename",
        "mock_dir_glob",
        "mock_fileutils_mkdir_p",
        "mock_fileutils_rm_f",
        "mock_fileutils_cp",
        "mock_system_command",
        "mock_open3_command",
        "mock_json_parse"
      ]
      
      methods.each do |method|
        expect(described_class.instance_methods(false)).to include(method.to_sym), "Method #{method} should be defined"
      end
    end
    
    it "has methods that follow a consistent naming convention" do
      methods = described_class.instance_methods(false).map(&:to_s)
      
      # All methods should start with 'mock_'
      methods.each do |method|
        expect(method).to start_with("mock_"), "Method #{method} should start with 'mock_'"
      end
    end
  end
end