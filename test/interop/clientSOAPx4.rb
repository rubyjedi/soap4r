#!/usr/bin/env ruby

$serverName = 'SOAPx4'

# NG: xsd:struct is not supported in SOAP4R.

require 'clientBase'

$server = 'http://dietrich.ganx4.com/soapx4/soap.php'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
