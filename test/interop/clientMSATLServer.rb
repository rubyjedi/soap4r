#!/usr/bin/env ruby

$serverName = 'MS ATL Server'

require 'clientBase'

$server = 'http://www.mssoapinterop.org/asmx/simple.asmx'
$soapAction = 'http://soapinterop.org/'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDefWithSOAPAction( drv, $soapAction )

doTest( drv )
