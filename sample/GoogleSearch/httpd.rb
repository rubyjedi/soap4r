#!/usr/bin/env ruby
require 'GoogleSearchServant.rb'

require 'webrick'

STDERR.puts "All WEBrick httpd functions are enabled such as ERuby and CGI."
STDERR.puts "Take care before running this server in public network."

require 'devel/logger'
logDev = Devel::Logger.new( 'httpd.log' )
logDev.sevThreshold = Devel::Logger::SEV_INFO

wwwsvr = WEBrick::HTTPServer.new(
  :BindAddress    => "0.0.0.0",
  :Port           => 10080, 
  :Logger         => logDev
)

require 'soaplet'
soapsrv = WEBrick::SOAPlet.new

require 'soap/rpcUtils'
MappingRegistry = SOAP::RPCUtils::MappingRegistry.new
  MappingRegistry.set(
    GoogleSearchResult,
    ::SOAP::SOAPStruct,
    ::SOAP::RPCUtils::MappingRegistry::TypedStructFactory,
    [ "urn:GoogleSearch", "GoogleSearchResult" ]
  )
  

class GoogleSearchPort
  Methods = [
    [ "doGetCachedPage", "doGetCachedPage", [ [ "in", "key" ], [ "in", "url" ], [ "retval", "return" ] ], "urn:GoogleSearchAction", "urn:GoogleSearch" ],
    [ "doSpellingSuggestion", "doSpellingSuggestion", [ [ "in", "key" ], [ "in", "phrase" ], [ "retval", "return" ] ], "urn:GoogleSearchAction", "urn:GoogleSearch" ],
    [ "doGoogleSearch", "doGoogleSearch", [ [ "in", "key" ], [ "in", "q" ], [ "in", "start" ], [ "in", "maxResults" ], [ "in", "filter" ], [ "in", "restrict" ], [ "in", "safeSearch" ], [ "in", "lr" ], [ "in", "ie" ], [ "in", "oe" ], [ "retval", "return" ] ], "urn:GoogleSearchAction", "urn:GoogleSearch" ]
  ]
end

servant = GoogleSearchPort.new
Sm11PortType::Methods.each do | nameAs, name, params, soapAction, ns |
  soapsrv.appScopeRouter.addMethodAs( ns, servant, name, nameAs, params )
end

soapsrv.appScopeRouter.mappingRegistry = Sm11PortType::MappingRegistry
wwwsvr.mount( '/soapsrv', soapsrv )

trap( "INT" ){ wwwsvr.shutdown }
wwwsvr.start
