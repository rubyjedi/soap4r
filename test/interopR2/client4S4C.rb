#!/usr/bin/env ruby

$serverName = '4S4C'

require 'clientBase'

$server = 'http://soap.4s4c.com/ilab/soap.asp'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTestBase( drv )
