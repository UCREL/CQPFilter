

require_relative 'extractor.rb'

class SittingDate < Extractor
  def get_metadata(str)
    day   = search_tag_pattern(str, %w{dates sittingday},   false)
    return day.join(' ')
  end
end

class SittingDecade < Extractor
  def get_metadata(str)
    return search_tag_pattern(str, %w{dates sittingdecade},   true)
  end
end

class SittingMonth < Extractor
  def get_metadata(str)
    return search_tag_pattern(str, %w{dates sittingmonth},   true)
  end
end

class SittingYear < Extractor
  def get_metadata(str)
    return search_tag_pattern(str, %w{dates sittingyear},   true)
  end
end
