require 'GoogleSearch.rb'

class GoogleSearchPort
  # SYNOPSIS
  #   doGetCachedPage( key, url )
  #
  # ARGS
  #   key		{http://www.w3.org/2001/XMLSchema}string
  #   url		{http://www.w3.org/2001/XMLSchema}string
  #
  # RETURNS
  #   return		{http://www.w3.org/2001/XMLSchema}base64Binary
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
  #   key		{http://www.w3.org/2001/XMLSchema}string
  #   phrase		{http://www.w3.org/2001/XMLSchema}string
  #
  # RETURNS
  #   return		{http://www.w3.org/2001/XMLSchema}string
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
  #   key		{http://www.w3.org/2001/XMLSchema}string
  #   q		{http://www.w3.org/2001/XMLSchema}string
  #   start		{http://www.w3.org/2001/XMLSchema}int
  #   maxResults		{http://www.w3.org/2001/XMLSchema}int
  #   filter		{http://www.w3.org/2001/XMLSchema}boolean
  #   restrict		{http://www.w3.org/2001/XMLSchema}string
  #   safeSearch		{http://www.w3.org/2001/XMLSchema}boolean
  #   lr		{http://www.w3.org/2001/XMLSchema}string
  #   ie		{http://www.w3.org/2001/XMLSchema}string
  #   oe		{http://www.w3.org/2001/XMLSchema}string
  #
  # RETURNS
  #   return		{urn:GoogleSearch}GoogleSearchResult
  #
  # RAISES
  #    N/A
  #
  def doGoogleSearch( key, q, start, maxResults, filter, restrict, safeSearch, lr, ie, oe )
    raise NotImplementedError.new
  end
  
end

