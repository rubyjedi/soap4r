#!/usr/local/bin/ruby

require 'webrick'

STDERR.puts "All WEBrick httpd functions are enabled such as ERuby and CGI."
STDERR.puts "Take care before running this server in public network."

require 'devel/logger'
logDev = Devel::Logger.new( 'httpd.log' )

wwwsvr = WEBrick::HTTPServer.new(
  :BindAddress    => "0.0.0.0",
  :Port           => 10080, 
  :Logger         => logDev
)

require 'soaplet'
soapsrv = WEBrick::SOAPlet.new

$:.push( '../../test/sm11' )
require 'servant'
servant = Sm11PortType.new
Sm11PortType::Methods.each do | nameAs, name, params, soapAction, ns |
  soapsrv.appScopeRouter.addMethodAs( ns, servant, name, nameAs, params )
end
soapsrv.appScopeRouter.mappingRegistry = Sm11PortType::MappingRegistry
wwwsvr.mount( '/soapsrv', soapsrv )

trap( "INT" ){ wwwsvr.shutdown }
wwwsvr.start
