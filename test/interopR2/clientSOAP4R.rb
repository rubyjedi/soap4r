#!/usr/bin/env ruby

$serverName = 'SOAP4R'

require 'clientBase'

#$server = 'http://dora/~nakahiro/server.cgi'

$server = 'http://www.jin.gr.jp/~nahi/Ruby/SOAP4R/SOAPBuildersInterop/'
#$server = 'http://www.jin.gr.jp/~nahi/Ruby/SOAP4R/SOAPBuildersInterop/1999/'
#require 'soap/XMLSchemaDatatypes1999'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
