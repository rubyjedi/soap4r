#!/usr/bin/env ruby

$serverName = '4S4C'
$server = 'http://soap.4s4c.com/ilab/soap.asp'

require 'clientBase'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
submitTestResult
