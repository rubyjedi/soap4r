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
  MappingRegistry.set(
    ResultElementArray,
    ::SOAP::SOAPArray,
    ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
    [ "urn:GoogleSearch", "ResultElement" ]
  )
  MappingRegistry.set(
    DirectoryCategoryArray,
    ::SOAP::SOAPArray,
    ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
    [ "urn:GoogleSearch", "DirectoryCategory" ]
  )
  MappingRegistry.set(
    ResultElement,
    ::SOAP::SOAPStruct,
    ::SOAP::RPCUtils::MappingRegistry::TypedStructFactory,
    [ "urn:GoogleSearch", "ResultElement" ]
  )
  MappingRegistry.set(
    DirectoryCategory,
    ::SOAP::SOAPStruct,
    ::SOAP::RPCUtils::MappingRegistry::TypedStructFactory,
    [ "urn:GoogleSearch", "DirectoryCategory" ]
  )
  
  Methods = [
    [ "doGetCachedPage", "doGetCachedPage", [
      [ "in", "key",
        [ SOAP::SOAPString ] ],
      [ "in", "url",
        [ SOAP::SOAPString ] ],
      [ "retval", "return",
        [ XSDBase64Binary ] ] ],
      "urn:GoogleSearchAction", "urn:GoogleSearch" ],
    [ "doSpellingSuggestion", "doSpellingSuggestion", [
      [ "in", "key",
        [ SOAP::SOAPString ] ],
      [ "in", "phrase",
        [ SOAP::SOAPString ] ],
      [ "retval", "return",
        [ SOAP::SOAPString ] ] ],
      "urn:GoogleSearchAction", "urn:GoogleSearch" ],
    [ "doGoogleSearch", "doGoogleSearch", [
      [ "in", "key",
        [ SOAP::SOAPString ] ],
      [ "in", "q",
        [ SOAP::SOAPString ] ],
      [ "in", "start",
        [ SOAP::SOAPInt ] ],
      [ "in", "maxResults",
        [ SOAP::SOAPInt ] ],
      [ "in", "filter",
        [ SOAP::SOAPBoolean ] ],
      [ "in", "restrict",
        [ SOAP::SOAPString ] ],
      [ "in", "safeSearch",
        [ SOAP::SOAPBoolean ] ],
      [ "in", "lr",
        [ SOAP::SOAPString ] ],
      [ "in", "ie",
        [ SOAP::SOAPString ] ],
      [ "in", "oe",
        [ SOAP::SOAPString ] ],
      [ "retval", "return",
        [ ::SOAP::SOAPStruct, "urn:GoogleSearch", "GoogleSearchResult" ] ] ],
      "urn:GoogleSearchAction", "urn:GoogleSearch" ]
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
