#!/usr/bin/env ruby

$serverName = 'Kafka XSLT Interop Service'

require 'clientBase'

module XSD
  Namespace = 'http://www.w3.org/1999/XMLSchema'
  InstanceNamespace = 'http://www.w3.org/1999/XMLSchema-instance'
  NilLiteral = 'null'
end

$server = 'http://www.vbxml.com/soapworkshop/services/kafka10/services/endpoint.asp?service=ilab'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
