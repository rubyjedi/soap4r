#!/usr/local/bin/ruby

require 'webrick'
require 'getopts'

getopts nil, 'p:'

require 'devel/logger'
logDev = Devel::Logger.new( 'httpd.log' )

port = $OPT_p || 2000

wwwsvr = WEBrick::HTTPServer.new(
  :ServerName     => "rrr.jin.gr.jp",
  :Port           => port,
  :Logger         => logDev
)

require 'soaplet'
soapsrv = SOAP::WEBrickSOAPlet.new
require 'exchange'
soapsrv.addServant( ExchangeServiceNamespace, Exchange.new )
require 'sampleStruct'
soapsrv.addServant( SampleStructServiceNamespace, SampleStructService.new )
wwwsvr.mount( '/soapsrv', soapsrv )

wwwsvr.start

exit( 0 )
