#!/usr/bin/env ruby

$serverName = 'Phalanx'

# NG: Struct which is not a member of array is not typed.

require 'clientBase'

$server = 'http://www.phalanxsys.com/interop/listener.asp'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
