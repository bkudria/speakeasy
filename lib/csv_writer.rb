require 'csv'

class CsvWriter
  def initialize(output_dir)
    @output_dir = output_dir
    @consecutive_errors = 0
  end
  
  def write_transcript(rows, base_filename)
    csv_filename = generate_unique_filename(base_filename)
    
    CSV.open(csv_filename, "w") do |csv|
      # Write header row
      csv << ["ID", "Speaker", "Transcript", "Confidence Min", "Confidence Max", "Confidence Mean", "Confidence Median", "Note"]
      
      # Write data rows
      rows.each do |row|
        if row[:note] == "error"
          @consecutive_errors += 1
          if @consecutive_errors >= 3
            puts "Three consecutive errors encountered. Aborting."
            exit(1)
          end
        else
          @consecutive_errors = 0
        end
        
        csv << [
          row[:id].to_s,
          row[:speaker].to_s,
          row[:transcript].to_s,
          row[:confidence_min].to_s,
          row[:confidence_max].to_s,
          row[:confidence_mean].to_s,
          row[:confidence_median].to_s,
          row[:note].to_s
        ]
      end
    end
    
    csv_filename
  end
  
  private
  
  def generate_unique_filename(base_filename)
    filename = File.join(@output_dir, "#{base_filename}.csv")
    counter = 1
    
    while File.exist?(filename)
      filename = File.join(@output_dir, "#{base_filename}.#{counter}.csv")
      counter += 1
    end
    
    filename
  end
end
