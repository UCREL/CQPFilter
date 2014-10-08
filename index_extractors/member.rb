

require_relative 'extractor.rb'

class Member < Extractor
  def get_metadata(str)
    day   = search_tag_pattern(str, %w{member},   false)
    return day.join(' ')
  end
end

