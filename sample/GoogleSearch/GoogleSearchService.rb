#!/usr/bin/env ruby
require 'GoogleSearchServant.rb'

require 'soap/rpc/standaloneServer'

class GoogleSearchPort
  MappingRegistry = SOAP::Mapping::Registry.new

  MappingRegistry.set(
    GoogleSearchResult,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("urn:GoogleSearch", "GoogleSearchResult") }
  )
  MappingRegistry.set(
    ResultElementArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:GoogleSearch", "ResultElement") }
  )
  MappingRegistry.set(
    DirectoryCategoryArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:GoogleSearch", "DirectoryCategory") }
  )
  MappingRegistry.set(
    ResultElement,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("urn:GoogleSearch", "ResultElement") }
  )
  MappingRegistry.set(
    DirectoryCategory,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("urn:GoogleSearch", "DirectoryCategory") }
  )
  
  Methods = [
    ["doGetCachedPage", "doGetCachedPage", [
      ["in", "key",
       [SOAP::SOAPString]],
      ["in", "url",
       [SOAP::SOAPString]],
      ["retval", "return",
       [SOAP::SOAPBase64]]],
     "urn:GoogleSearchAction", "urn:GoogleSearch"],
    ["doSpellingSuggestion", "doSpellingSuggestion", [
      ["in", "key",
       [SOAP::SOAPString]],
      ["in", "phrase",
       [SOAP::SOAPString]],
      ["retval", "return",
       [SOAP::SOAPString]]],
     "urn:GoogleSearchAction", "urn:GoogleSearch"],
    ["doGoogleSearch", "doGoogleSearch", [
      ["in", "key",
       [SOAP::SOAPString]],
      ["in", "q",
       [SOAP::SOAPString]],
      ["in", "start",
       [SOAP::SOAPInt]],
      ["in", "maxResults",
       [SOAP::SOAPInt]],
      ["in", "filter",
       [SOAP::SOAPBoolean]],
      ["in", "restrict",
       [SOAP::SOAPString]],
      ["in", "safeSearch",
       [SOAP::SOAPBoolean]],
      ["in", "lr",
       [SOAP::SOAPString]],
      ["in", "ie",
       [SOAP::SOAPString]],
      ["in", "oe",
       [SOAP::SOAPString]],
      ["retval", "return",
       [::SOAP::SOAPStruct, "urn:GoogleSearch", "GoogleSearchResult"]]],
     "urn:GoogleSearchAction", "urn:GoogleSearch"]
  ]
end

class App < SOAP::RPC::StandaloneServer
  def initialize(*arg)
    super

    servant = GoogleSearchPort.new
    GoogleSearchPort::Methods.each do |name_as, name, params, soapaction, namespace|
      qname = XSD::QName.new(namespace, name_as)
      @soaplet.app_scope_router.add_method(servant, qname, soapaction,
	name, params)
    end

    self.mapping_registry = GoogleSearchPort::MappingRegistry
  end
end

# Change listen port.
App.new('app', nil, '0.0.0.0', 10080).start
