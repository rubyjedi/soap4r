require 'xsd/qname'

# {urn:GoogleSearch}GoogleSearchResult
class GoogleSearchResult
  @@schema_type = "GoogleSearchResult"
  @@schema_ns = "urn:GoogleSearch"
  @@schema_element = [["documentFiltering", "SOAP::SOAPBoolean"], ["searchComments", "SOAP::SOAPString"], ["estimatedTotalResultsCount", "SOAP::SOAPInt"], ["estimateIsExact", "SOAP::SOAPBoolean"], ["resultElements", "ResultElementArray"], ["searchQuery", "SOAP::SOAPString"], ["startIndex", "SOAP::SOAPInt"], ["endIndex", "SOAP::SOAPInt"], ["searchTips", "SOAP::SOAPString"], ["directoryCategories", "DirectoryCategoryArray"], ["searchTime", "SOAP::SOAPDouble"]]

  attr_accessor :documentFiltering
  attr_accessor :searchComments
  attr_accessor :estimatedTotalResultsCount
  attr_accessor :estimateIsExact
  attr_accessor :resultElements
  attr_accessor :searchQuery
  attr_accessor :startIndex
  attr_accessor :endIndex
  attr_accessor :searchTips
  attr_accessor :directoryCategories
  attr_accessor :searchTime

  def initialize(documentFiltering = nil, searchComments = nil, estimatedTotalResultsCount = nil, estimateIsExact = nil, resultElements = nil, searchQuery = nil, startIndex = nil, endIndex = nil, searchTips = nil, directoryCategories = nil, searchTime = nil)
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

# {urn:GoogleSearch}ResultElement
class ResultElement
  @@schema_type = "ResultElement"
  @@schema_ns = "urn:GoogleSearch"
  @@schema_element = [["summary", "SOAP::SOAPString"], ["uRL", ["SOAP::SOAPString", XSD::QName.new("urn:GoogleSearch", "URL")]], ["snippet", "SOAP::SOAPString"], ["title", "SOAP::SOAPString"], ["cachedSize", "SOAP::SOAPString"], ["relatedInformationPresent", "SOAP::SOAPBoolean"], ["hostName", "SOAP::SOAPString"], ["directoryCategory", "DirectoryCategory"], ["directoryTitle", "SOAP::SOAPString"]]

  attr_accessor :summary
  attr_accessor :snippet
  attr_accessor :title
  attr_accessor :cachedSize
  attr_accessor :relatedInformationPresent
  attr_accessor :hostName
  attr_accessor :directoryCategory
  attr_accessor :directoryTitle

  def URL
    @uRL
  end

  def URL=(value)
    @uRL = value
  end

  def initialize(summary = nil, uRL = nil, snippet = nil, title = nil, cachedSize = nil, relatedInformationPresent = nil, hostName = nil, directoryCategory = nil, directoryTitle = nil)
    @summary = summary
    @uRL = uRL
    @snippet = snippet
    @title = title
    @cachedSize = cachedSize
    @relatedInformationPresent = relatedInformationPresent
    @hostName = hostName
    @directoryCategory = directoryCategory
    @directoryTitle = directoryTitle
  end
end

# {urn:GoogleSearch}ResultElementArray
class ResultElementArray < ::Array
  @@schema_type = "ResultElement"
  @@schema_ns = "urn:GoogleSearch"
end

# {urn:GoogleSearch}DirectoryCategoryArray
class DirectoryCategoryArray < ::Array
  @@schema_type = "DirectoryCategory"
  @@schema_ns = "urn:GoogleSearch"
end

# {urn:GoogleSearch}DirectoryCategory
class DirectoryCategory
  @@schema_type = "DirectoryCategory"
  @@schema_ns = "urn:GoogleSearch"
  @@schema_element = [["fullViewableName", "SOAP::SOAPString"], ["specialEncoding", "SOAP::SOAPString"]]

  attr_accessor :fullViewableName
  attr_accessor :specialEncoding

  def initialize(fullViewableName = nil, specialEncoding = nil)
    @fullViewableName = fullViewableName
    @specialEncoding = specialEncoding
  end
end
