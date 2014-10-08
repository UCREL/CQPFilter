


class Extractor
  def get_metadata(string)
    return nil
  end



private

  def search_tag_pattern(str, tags = [], first_result_only = false)

    # puts "=> #{str}"
    results = []

    # currently `active' tags
    tag_stack = []

    # Loop over the lines to extract stuff
    str.gsub!(/\r\n?/, $/)
    str.lines.each_with_index do |line, i|

      line.chomp!
      parts = line.split("\t")
      # puts "[#{i}] ## #{tag_stack} | #{parts[0]} | #{line} /#"

      # Split the line and read data
      if m = parts[0].to_s.match(/^<(?<slash>\/?)(?<tag>\w+)\s*?.*?>/)

        # puts " #{parts[0]}  //  #{m[:slash]}  //  #{m[:tag]}"

        if m[:slash] != ''
          tag = tag_stack.pop
          fail "Line #{i}: Mismatched tag #{m[:tag]} closed but </#{tag}> expected." if tag != m[:tag]
        else
          tag_stack.push(m[:tag])
        end

        # puts " stack: #{tag_stack}"
        
        # Skip since this is just a tag
        next
      end

      ## At this point we have some data.
      word = parts[0]
      if tag_stack.include_array?(tags)
        return word if first_result_only
        results << word
      end
    end

    return nil if first_result_only && results.empty?
    return results
  end

end





class Array
  # Does one array include another?
  def include_array?(subarray)
    test_array = self.dup
    while(test_array.length > 0)

      i = test_array.index(subarray[0])
      return false unless i

      # Test if the rest matches
      return true if subarray[1..-1] == test_array[i + 1 .. i + subarray.length - 1]

      test_array = test_array[i + 1 .. -1]
    end

    return true
  end
end



