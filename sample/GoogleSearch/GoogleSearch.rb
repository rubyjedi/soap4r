# urn:GoogleSearch
class GoogleSearchResult
  attr_accessor :documentFiltering	# {http://www.w3.org/2001/XMLSchema}boolean
  attr_accessor :searchComments	# {http://www.w3.org/2001/XMLSchema}string
  attr_accessor :estimatedTotalResultsCount	# {http://www.w3.org/2001/XMLSchema}int
  attr_accessor :estimateIsExact	# {http://www.w3.org/2001/XMLSchema}boolean
  attr_accessor :resultElements	# {urn:GoogleSearch}ResultElementArray
  attr_accessor :searchQuery	# {http://www.w3.org/2001/XMLSchema}string
  attr_accessor :startIndex	# {http://www.w3.org/2001/XMLSchema}int
  attr_accessor :endIndex	# {http://www.w3.org/2001/XMLSchema}int
  attr_accessor :searchTips	# {http://www.w3.org/2001/XMLSchema}string
  attr_accessor :directoryCategories	# {urn:GoogleSearch}DirectoryCategoryArray
  attr_accessor :searchTime	# {http://www.w3.org/2001/XMLSchema}double

  def initialize( documentFiltering = nil,
      searchComments = nil,
      estimatedTotalResultsCount = nil,
      estimateIsExact = nil,
      resultElements = nil,
      searchQuery = nil,
      startIndex = nil,
      endIndex = nil,
      searchTips = nil,
      directoryCategories = nil,
      searchTime = nil )
    @documentFiltering = documentFiltering
    @searchComments = searchComments
    @estimatedTotalResultsCount = estimatedTotalResultsCount
    @estimateIsExact = estimateIsExact
    @resultElements = resultElements
    @searchQuery = searchQuery
    @startIndex = startIndex
    @endIndex = endIndex
    @searchTips = searchTips
    @directoryCategories = directoryCategories
    @searchTime = searchTime
  end
end

# urn:GoogleSearch
class ResultElement
  attr_accessor :summary	# {http://www.w3.org/2001/XMLSchema}string
  attr_accessor :url	# {http://www.w3.org/2001/XMLSchema}string
  attr_accessor :snippet	# {http://www.w3.org/2001/XMLSchema}string
  attr_accessor :title	# {http://www.w3.org/2001/XMLSchema}string
  attr_accessor :cachedSize	# {http://www.w3.org/2001/XMLSchema}string
  attr_accessor :relatedInformationPresent	# {http://www.w3.org/2001/XMLSchema}boolean
  attr_accessor :hostName	# {http://www.w3.org/2001/XMLSchema}string
  attr_accessor :directoryCategory	# {urn:GoogleSearch}DirectoryCategory
  attr_accessor :directoryTitle	# {http://www.w3.org/2001/XMLSchema}string

  def initialize( summary = nil,
      url = nil,
      snippet = nil,
      title = nil,
      cachedSize = nil,
      relatedInformationPresent = nil,
      hostName = nil,
      directoryCategory = nil,
      directoryTitle = nil )
    @summary = summary
    @url = url
    @snippet = snippet
    @title = title
    @cachedSize = cachedSize
    @relatedInformationPresent = relatedInformationPresent
    @hostName = hostName
    @directoryCategory = directoryCategory
    @directoryTitle = directoryTitle
  end
end

# urn:GoogleSearch
class ResultElementArray < Array; end

# urn:GoogleSearch
class DirectoryCategoryArray < Array; end

# urn:GoogleSearch
class DirectoryCategory
  attr_accessor :fullViewableName	# {http://www.w3.org/2001/XMLSchema}string
  attr_accessor :specialEncoding	# {http://www.w3.org/2001/XMLSchema}string

  def initialize( fullViewableName = nil,
      specialEncoding = nil )
    @fullViewableName = fullViewableName
    @specialEncoding = specialEncoding
  end
end

