require 'GoogleSearch.rb'

require 'soap/proxy'
require 'soap/rpcUtils'
require 'soap/streamHandler'

class GoogleSearchPort
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

  DefaultEndpointUrl = "http://api.google.com/search/beta2"

  attr_reader :endpointUrl
  attr_reader :proxyUrl

  def initialize( endpointUrl = DefaultEndpointUrl, proxyUrl = nil )
    @endpointUrl = endpointUrl
    @proxyUrl = proxyUrl
    @httpStreamHandler = SOAP::HTTPPostStreamHandler.new( @endpointUrl,
      @proxyUrl )
    @proxy = SOAP::SOAPProxy.new( nil, @httpStreamHandler, nil )
    @proxy.allowUnqualifiedElement = true
    @mappingRegistry = MappingRegistry
    addMethod
  end

  def setWireDumpDev( dumpDev )
    @httpStreamHandler.dumpDev = dumpDev
  end

  def setDefaultEncodingStyle( encodingStyle )
    @proxy.defaultEncodingStyle = encodingStyle
  end

  def getDefaultEncodingStyle
    @proxy.defaultEncodingStyle
  end

  def call( methodName, *params )
    # Convert parameters
    params.collect! { | param |
      SOAP::RPCUtils.obj2soap( param, @mappingRegistry )
    }

    # Then, call @proxy.call like the following.
    header, body = @proxy.call( nil, methodName, *params )

    # Check Fault.
    begin
      @proxy.checkFault( body )
    rescue SOAP::FaultError => e
      SOAP::RPCUtils.fault2exception( e, @mappingRegistry )
    end

    ret = body.response ?
      SOAP::RPCUtils.soap2obj( body.response, @mappingRegistry ) : nil
    if body.outParams
      outParams = body.outParams.collect { | outParam |
	SOAP::RPCUtils.soap2obj( outParam )
      }
      return [ ret ].concat( outParams )
    else
      return ret
    end
  end

private 

  def addMethod
    Methods.each do | methodNameAs, methodName, params, soapAction, namespace |
      @proxy.addMethodAs( methodNameAs, methodName, params, soapAction,
	namespace )
      addMethodInterface( methodNameAs, params )
    end
  end

  def addMethodInterface( name, params )
    self.instance_eval <<-EOD
      def #{ name }( *params )
	call( "#{ name }", *params )
      end
    EOD
  end
end

