#!/usr/bin/env ruby

PROGRESS_OUTPUT = 51
TAG_BLACKLIST   = %w{s body}
INPUT_ENCODING  = 'iso8859-1'

input_dir  = ARGV[0]
output_dir = ARGV[1]

unless input_dir && output_dir
  warn "USAGE: #$0 INPUT_DIR OUTPUT_DIR"
  warn ""
  warn "Assumes #{INPUT_ENCODING} input files."
  exit(1)
end

require 'set'
$tags = Set.new

# Ensure tag ordering
$tag_stack = []

def process(output_dir, input, id)

  output = File.join(output_dir, "#{File.basename(input, '.smt')}.vrt")
  return if File.exist?(output)
  File.open(output, 'w') do |fout|
    
    fout.puts("<text id=\"#{id}\">")

    File.open(input, mode: 'r', encoding: INPUT_ENCODING) do |fin|
      fin.readlines.each_with_index do |line, i|

        # Drop first three lines
        next if i < 3

        line.encode!('utf-8')

        # If this is an XML tag, strip it
        if (m = line.match(/^<(?<slash>\/?)(?<tag>.*?)(\s.*?)?>/))
          tag = m[:tag].downcase
          next if TAG_BLACKLIST.include?(tag)

          $tags << tag

          if m[:slash] == ''
            # puts " - <#{tag}> : #{$tag_stack}"
            fout.puts "<#{tag}>"
            $tag_stack.push tag
          else
            # puts " - </#{tag}> : #{$tag_stack}"
           
            if $tag_stack.include?(tag)
              expected_tag = $tag_stack.pop

              while(!$tag_stack.empty? && expected_tag != tag)
                puts "expected #{expected_tag} but got #{tag}" 
                puts "Closing #{expected_tag} as a patch.  This is risky."
                fout.puts "</#{expected_tag}>"
                expected_tag = $tag_stack.pop
              end
              
              fout.puts "</#{tag}>"
            else
              # fout.puts "[/#{tag}]"
              warn "*** Closing tag that is already closed (#{tag})."
              warn "    This normally indicates a previous screwup, and can't be fixed automatically."
            end
            
          end

          # Skip
          next
        end

        # Write line
        fout.write(line)
      end

      fout.write("</text>\n")

    end


  end
end


# UUIDs
require 'securerandom'
require 'fileutils'

# Create output dir
FileUtils.mkdir_p(output_dir) unless File.exist?(output_dir) && File.directory?(output_dir)


count = 0
puts "Counting files..."
num_files = Dir.glob(File.join(input_dir, '*.smt')).length

puts "Converting ~#{num_files} files for output..."
Dir.glob(File.join(input_dir, '*.smt')) do |fn|
  count += 1

  id = File.basename(fn)
  # if m = File.basename(fn).to_s.match(/\d{5}/)
  #   id = m[0]
  # end

  print "\r #{count} / #{num_files} (#{(count.to_f / num_files.to_f * 100).round(2)}%)  " if count % PROGRESS_OUTPUT == 0

  process(output_dir, fn, id)
end
print "\n"


# Write tags found to a file
tags_filename = File.join(output_dir, 'tags')
puts "Writing discovered tags to #{tags_filename}"
File.open(tags_filename, 'w') do |fout|
  fout.puts "Tags found: \n\n#{$tags.to_a.sort.join("\n")}\n\n"
end

puts "Before importing into CQPWeb, you'll need to build an index."
