#!/usr/bin/env ruby
require 'GoogleSearchDriver.rb'

endpointUrl = ARGV.shift || GoogleSearchPort::DefaultEndpointUrl
proxyUrl = ENV[ 'http_proxy' ] || ENV[ 'HTTP_PROXY' ]
obj = GoogleSearchPort.new( endpointUrl, proxyUrl )

# Uncomment the below line to see SOAP wiredumps.
# obj.setWireDumpDev( STDERR )


# SYNOPSIS
#   doGetCachedPage( key, url )
#
# ARGS
#   key		String - {http://www.w3.org/2001/XMLSchema}string
#   url		String - {http://www.w3.org/2001/XMLSchema}string
#
# RETURNS
#   return		String - {http://www.w3.org/2001/XMLSchema}base64Binary
#
# RAISES
#    N/A
#
key = url = nil
puts obj.doGetCachedPage( key, url )

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
key = phrase = nil
puts obj.doSpellingSuggestion( key, phrase )

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
key = q = start = maxResults = filter = restrict = safeSearch = lr = ie = oe = nil
puts obj.doGoogleSearch( key, q, start, maxResults, filter, restrict, safeSearch, lr, ie, oe )


