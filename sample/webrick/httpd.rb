#!/usr/local/bin/ruby

require './webrick'
require 'getopts'

getopts nil, 'p:'

require 'devel/logger'
logDev = Devel::Logger.new( 'httpd.log' )

port = $OPT_p || 2000

wwwsvr = WEBrick::HTTPServer.new(
  :Port           => port,
  :Logger         => logDev
)

require 'soaplet'
soapsrv = WEBrick::SOAPlet.new

require 'exchange'
#soapsrv.addRequestServant( ExchangeServiceNamespace, Exchange )
soapsrv.addServant( ExchangeServiceNamespace, Exchange.new )

require 'sampleStruct'
soapsrv.addServant( SampleStructServiceNamespace, SampleStructService.new )

$:.push( '../../test/sm11' )
require 'servant'
servant = Sm11PortType.new
Sm11PortType::Methods.each do | nameAs, name, params, soapAction, ns |
  soapsrv.appScopeRouter.addMethodAs( ns, servant, name, nameAs, params )
end

wwwsvr.mount( '/soapsrv', soapsrv )
wwwsvr.start

exit( 0 )
