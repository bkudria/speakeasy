require "spec_helper"
require_relative "../lib/csv_writer"

RSpec.describe CsvWriter do
  describe "#write_transcript" do
    it "writes CSV rows correctly for normal output" do
      # Create a temporary directory for output
      output_dir = Dir.mktmpdir

      # Create test data
      rows = [
        {
          id: 1,
          speaker: "Speaker 1",
          transcript: "Hello world",
          confidence_min: 0.8,
          confidence_max: 0.95,
          confidence_mean: 0.88,
          confidence_median: 0.89,
          note: ""
        },
        {
          id: 2,
          speaker: "Speaker 2",
          transcript: "This is a test",
          confidence_min: 0.75,
          confidence_max: 0.92,
          confidence_mean: 0.85,
          confidence_median: 0.86,
          note: ""
        }
      ]

      # Initialize CsvWriter and write transcript
      csv_writer = CsvWriter.new(output_dir)
      csv_filename = csv_writer.write_transcript(rows, "test_transcript")

      # Verify the file exists
      expect(File.exist?(csv_filename)).to be true

      # Read the CSV file and verify its contents
      csv_content = CSV.read(csv_filename)

      # Check header row
      expect(csv_content[0]).to eq(["ID", "Speaker", "Transcript", "Confidence Min", "Confidence Max", "Confidence Mean", "Confidence Median", "Note"])

      # Check data rows
      expect(csv_content[1][0]).to eq("1")
      expect(csv_content[1][1]).to eq("Speaker 1")
      expect(csv_content[1][2]).to eq("Hello world")
      expect(csv_content[1][3]).to eq("0.8")
      expect(csv_content[1][4]).to eq("0.95")
      expect(csv_content[1][5]).to eq("0.88")
      expect(csv_content[1][6]).to eq("0.89")
      expect(csv_content[1][7]).to eq("")

      expect(csv_content[2][0]).to eq("2")
      expect(csv_content[2][1]).to eq("Speaker 2")
      expect(csv_content[2][2]).to eq("This is a test")
      expect(csv_content[2][3]).to eq("0.75")
      expect(csv_content[2][4]).to eq("0.92")
      expect(csv_content[2][5]).to eq("0.85")
      expect(csv_content[2][6]).to eq("0.86")
      expect(csv_content[2][7]).to eq("")

      # Clean up
      FileUtils.remove_entry(output_dir)
    end

    context "when writing rows with errors" do
      it "stops after three consecutive errors" do
        output_dir = Dir.mktmpdir
        csv_writer = CsvWriter.new(output_dir)

        # Three consecutive rows mocked to cause errors
        rows = [
          {id: 1, speaker: "X", transcript: "Some text", note: "error"},
          {id: 2, speaker: "Y", transcript: "Some text", note: "error"},
          {id: 3, speaker: "Z", transcript: "Some text", note: "error"}
        ]

        expect do
          csv_writer.write_transcript(rows, "error_test")
        end.to raise_error(SystemExit)

        FileUtils.remove_entry(output_dir)
      end
    end
  end
end
