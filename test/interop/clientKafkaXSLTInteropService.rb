#!/usr/bin/env ruby

$serverName = 'Kafka XSLT Interop Service'

require 'clientBase'
require 'soap/XMLSchemaDatatypes1999'


$server = 'http://www.vbxml.com/soapworkshop/services/kafka10/services/endpoint.asp?service=ilab'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
