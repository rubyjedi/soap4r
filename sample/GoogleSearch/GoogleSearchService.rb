#!/usr/bin/env ruby
require 'GoogleSearchServant.rb'

require 'soap/standaloneServer'

class GoogleSearchPort
  require 'soap/rpcUtils'
  MappingRegistry = SOAP::RPCUtils::MappingRegistry.new

  MappingRegistry.set(
    GoogleSearchResult,
    ::SOAP::SOAPStruct,
    ::SOAP::RPCUtils::MappingRegistry::TypedStructFactory,
    [ "urn:GoogleSearch", "GoogleSearchResult" ]
  )
  
  Methods = [
    [ "doGetCachedPage", "doGetCachedPage", [ [ "in", "key" ], [ "in", "url" ], [ "retval", "return" ] ], "urn:GoogleSearchAction", "urn:GoogleSearch" ],
    [ "doSpellingSuggestion", "doSpellingSuggestion", [ [ "in", "key" ], [ "in", "phrase" ], [ "retval", "return" ] ], "urn:GoogleSearchAction", "urn:GoogleSearch" ],
    [ "doGoogleSearch", "doGoogleSearch", [ [ "in", "key" ], [ "in", "q" ], [ "in", "start" ], [ "in", "maxResults" ], [ "in", "filter" ], [ "in", "restrict" ], [ "in", "safeSearch" ], [ "in", "lr" ], [ "in", "ie" ], [ "in", "oe" ], [ "retval", "return" ] ], "urn:GoogleSearchAction", "urn:GoogleSearch" ]
  ]
end

class App < SOAP::StandaloneServer
  def initialize( *arg )
    super( *arg )

    servant = GoogleSearchPort.new
    GoogleSearchPort::Methods.each do | methodNameAs, methodName, params, soapAction, namespace |
      addMethodWithNSAs( namespace, servant, methodName, methodNameAs, params, soapAction )
    end

    self.mappingRegistry = GoogleSearchPort::MappingRegistry
    setSevThreshold( Devel::Logger::ERROR )
  end
end

# Change listen port.
App.new( 'app', nil, '0.0.0.0', 10080 ).start
