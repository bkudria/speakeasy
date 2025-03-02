require_relative 'lib/csv_generator'

class TranscriptProcessor
  def generate_csv_transcript
    csv_gen = CsvGenerator.new
    
    CSV.open(output_csv_path, "wb") do |csv|
      csv << ["ID", "Speaker", "Transcript", "Confidence Min", "Confidence Max",
              "Confidence Mean", "Confidence Median", "Note"]
      segments.each do |segment|
        row_data = csv_gen.build_row(segment)
        csv << [
          row_data[:id],
          row_data[:speaker],
          row_data[:transcript],
          row_data[:confidence_min],
          row_data[:confidence_max],
          row_data[:confidence_mean],
          row_data[:confidence_median],
          row_data[:note]
        ]
      end
    end
  end
end
