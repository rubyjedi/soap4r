#!/usr/bin/env ruby

$serverName = 'White Mesa SOAP RPC'

require 'clientBase'
require 'soap/XMLSchemaDatatypes1999'

$server = 'http://www.whitemesa.net/interop'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
