#!/usr/bin/env ruby

$serverName = 'SOAP4R'

require 'clientBase'

$server = 'http://www.jin.gr.jp/~nahi/Ruby/SOAP4R/SOAPBuildersInterop/'

#require 'soap/XMLSchemaDatatypes1999'
#$server = 'http://www.jin.gr.jp/~nahi/Ruby/SOAP4R/SOAPBuildersInterop/1999/'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
