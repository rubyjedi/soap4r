# urn:GoogleSearch
class GoogleSearchResult
  def documentFiltering
    @documentFiltering
  end

  def documentFiltering=( newdocumentFiltering )
    @documentFiltering = newdocumentFiltering
  end

  def searchComments
    @searchComments
  end

  def searchComments=( newsearchComments )
    @searchComments = newsearchComments
  end

  def estimatedTotalResultsCount
    @estimatedTotalResultsCount
  end

  def estimatedTotalResultsCount=( newestimatedTotalResultsCount )
    @estimatedTotalResultsCount = newestimatedTotalResultsCount
  end

  def estimateIsExact
    @estimateIsExact
  end

  def estimateIsExact=( newestimateIsExact )
    @estimateIsExact = newestimateIsExact
  end

  def resultElements
    @resultElements
  end

  def resultElements=( newresultElements )
    @resultElements = newresultElements
  end

  def searchQuery
    @searchQuery
  end

  def searchQuery=( newsearchQuery )
    @searchQuery = newsearchQuery
  end

  def startIndex
    @startIndex
  end

  def startIndex=( newstartIndex )
    @startIndex = newstartIndex
  end

  def endIndex
    @endIndex
  end

  def endIndex=( newendIndex )
    @endIndex = newendIndex
  end

  def searchTips
    @searchTips
  end

  def searchTips=( newsearchTips )
    @searchTips = newsearchTips
  end

  def directoryCategories
    @directoryCategories
  end

  def directoryCategories=( newdirectoryCategories )
    @directoryCategories = newdirectoryCategories
  end

  def searchTime
    @searchTime
  end

  def searchTime=( newsearchTime )
    @searchTime = newsearchTime
  end


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
  def summary
    @summary
  end

  def summary=( newsummary )
    @summary = newsummary
  end

  def URL
    @uRL
  end

  def URL=( newURL )
    @uRL = newURL
  end

  def snippet
    @snippet
  end

  def snippet=( newsnippet )
    @snippet = newsnippet
  end

  def title
    @title
  end

  def title=( newtitle )
    @title = newtitle
  end

  def cachedSize
    @cachedSize
  end

  def cachedSize=( newcachedSize )
    @cachedSize = newcachedSize
  end

  def relatedInformationPresent
    @relatedInformationPresent
  end

  def relatedInformationPresent=( newrelatedInformationPresent )
    @relatedInformationPresent = newrelatedInformationPresent
  end

  def hostName
    @hostName
  end

  def hostName=( newhostName )
    @hostName = newhostName
  end

  def directoryCategory
    @directoryCategory
  end

  def directoryCategory=( newdirectoryCategory )
    @directoryCategory = newdirectoryCategory
  end

  def directoryTitle
    @directoryTitle
  end

  def directoryTitle=( newdirectoryTitle )
    @directoryTitle = newdirectoryTitle
  end


  def initialize( summary = nil,
      uRL = nil,
      snippet = nil,
      title = nil,
      cachedSize = nil,
      relatedInformationPresent = nil,
      hostName = nil,
      directoryCategory = nil,
      directoryTitle = nil )
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

# urn:GoogleSearch
class ResultElementArray < Array; end

# urn:GoogleSearch
class DirectoryCategoryArray < Array; end

# urn:GoogleSearch
class DirectoryCategory
  def fullViewableName
    @fullViewableName
  end

  def fullViewableName=( newfullViewableName )
    @fullViewableName = newfullViewableName
  end

  def specialEncoding
    @specialEncoding
  end

  def specialEncoding=( newspecialEncoding )
    @specialEncoding = newspecialEncoding
  end


  def initialize( fullViewableName = nil,
      specialEncoding = nil )
    @fullViewableName = fullViewableName
    @specialEncoding = specialEncoding
  end
end

