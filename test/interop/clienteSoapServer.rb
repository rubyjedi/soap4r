#!/usr/bin/env ruby

$serverName = 'eSoapServer'

require 'clientBase'

module XSD
  Namespace = 'http://www.w3.org/1999/XMLSchema'
  InstanceNamespace = 'http://www.w3.org/1999/XMLSchema-instance'
  NilLiteral = 'null'
end


$server = 'http://www.connecttel.com/cgi-bin/esoapserver.cgi'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
