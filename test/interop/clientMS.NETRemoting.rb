#!/usr/bin/env ruby

$serverName = 'MS .NET Remoting'

# NG: Struct which is not a member of array is not typed.

require 'clientBase'

$server = 'http://131.107.72.13/DotNetRemoting2001Typed/InteropService.soap'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
