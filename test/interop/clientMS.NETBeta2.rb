#!/usr/bin/env ruby

$serverName = 'MS .NET Beta 2'

require 'clientBase'

$server = 'http://131.107.72.13/test/typed.asmx'
$soapAction = 'http://soapinterop.org/'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDefWithSOAPAction( drv, $soapAction )

doTest( drv )
