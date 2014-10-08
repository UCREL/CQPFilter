#!/usr/bin/env ruby
#
# Builds CQPWeb metadata files from an input directory
# full of .vrt files.
#

# Require all ruby files from the plugin dir
Dir.glob(File.join(File.dirname(__FILE__), 'index_extractors', '*.rb')) do |fn|
  require_relative fn unless File.directory?(fn)
end

# Which fields to extract
METADATA_FIELDS = {
  date:   SittingDate.new(),
  decade: SittingDecade.new(),
  year:   SittingYear.new(),
  month:  SittingMonth.new(),
  member: Member.new(),
}






PROGRESS_OUTPUT = 31

input_dir = ARGV[0]

unless input_dir
  warn "USAGE: #$0 INPUT_DIR"
  exit(1)
end



index_filename = File.join(input_dir, 'index.tsv')
puts "Outputting index to #{index_filename}"
File.open(index_filename, 'w') do |fout|

  # Read data from each of the files
  puts "Counting files..."
  num_files = Dir.glob(File.join(input_dir, '*.vrt')).count

  puts "Annotating #{num_files} files..."
  count = 0
  Dir.glob(File.join(input_dir, '*.vrt')) do |fn|
    str = File.read(fn)

    # Read the text_id attribute from the first line
    if (m = str.match(/^<\s*text\s*id\s*=\s*"(?<id>.*?)"\s*>/))
      id = m[:id]
    else
      warn "\nNo id found for #{File.basename(fn)}.  Skipping."
      next
    end

    # Extract each of the items for the list
    row = [id.to_s]
    METADATA_FIELDS.each do |field, extractor|
      value = ''
      begin
        value = extractor.get_metadata(str)
      rescue StandardError => e
        warn "Error finding field '#{field}' for #{File.basename(fn)}: #{e}"
      end

      # Clean up for CQPWeb
      value.to_s.gsub!(/[^\w]/, '_')

      # puts "#{field} = #{value}"
      row << value
    end

    # Output the row
    fout.puts row.join("\t")

    print "\r #{count} / #{num_files} (#{(count.to_f / num_files * 100.0).round(2)}%) " if count % PROGRESS_OUTPUT == 0
    count += 1
  end
end
print "\n"

