#!/usr/bin/env ruby

$serverName = 'SOAP4R'

require 'clientBase'

$server = 'http://dora/~nakahiro/server.cgi'

#$server = 'http://www.jin.gr.jp/~nahi/Ruby/SOAP4R/SOAPBuildersInterop/'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
