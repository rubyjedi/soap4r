#!/usr/bin/env ruby

$serverName = 'HP SOAP'

require 'clientBase'

$server = 'http://soap.bluestone.com/scripts/SaISAPI.dll/SaServletEngine.class/hp-soap/soap/rpc/interop/EchoService'
$soapAction = 'urn:soapinterop'

class SOAPStruct
  @@typeNamespace = 'http://soapinterop.org/'
end


drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
