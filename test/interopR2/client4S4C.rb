#!/usr/bin/env ruby

$serverName = '4S4C'
$server = 'http://www.4s4c.com/services/4s4c.ashx'

require 'clientBase'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
submitTestResult
