require 'GoogleSearch.rb'

class GoogleSearchPort
  # SYNOPSIS
  #   doGetCachedPage( key, url )
  #
  # ARGS
  #   key		String - {http://www.w3.org/2001/XMLSchema}string
  #   url		String - {http://www.w3.org/2001/XMLSchema}string
  #
  # RETURNS
  #   return		 - {http://www.w3.org/2001/XMLSchema}base64Binary
  #
  # RAISES
  #    N/A
  #
  def doGetCachedPage( key, url )
    raise NotImplementedError.new
  end
  
  # SYNOPSIS
  #   doSpellingSuggestion( key, phrase )
  #
  # ARGS
  #   key		String - {http://www.w3.org/2001/XMLSchema}string
  #   phrase		String - {http://www.w3.org/2001/XMLSchema}string
  #
  # RETURNS
  #   return		String - {http://www.w3.org/2001/XMLSchema}string
  #
  # RAISES
  #    N/A
  #
  def doSpellingSuggestion( key, phrase )
    raise NotImplementedError.new
  end
  
  # SYNOPSIS
  #   doGoogleSearch( key, q, start, maxResults, filter, restrict, safeSearch, lr, ie, oe )
  #
  # ARGS
  #   key		String - {http://www.w3.org/2001/XMLSchema}string
  #   q		String - {http://www.w3.org/2001/XMLSchema}string
  #   start		Integer - {http://www.w3.org/2001/XMLSchema}int
  #   maxResults		Integer - {http://www.w3.org/2001/XMLSchema}int
  #   filter		TrueClass - {http://www.w3.org/2001/XMLSchema}boolean
  #   restrict		String - {http://www.w3.org/2001/XMLSchema}string
  #   safeSearch		TrueClass - {http://www.w3.org/2001/XMLSchema}boolean
  #   lr		String - {http://www.w3.org/2001/XMLSchema}string
  #   ie		String - {http://www.w3.org/2001/XMLSchema}string
  #   oe		String - {http://www.w3.org/2001/XMLSchema}string
  #
  # RETURNS
  #   return		GoogleSearchResult - {urn:GoogleSearch}GoogleSearchResult
  #
  # RAISES
  #    N/A
  #
  def doGoogleSearch( key, q, start, maxResults, filter, restrict, safeSearch, lr, ie, oe )
    raise NotImplementedError.new
  end
  
end

