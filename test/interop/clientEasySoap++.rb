#!/usr/bin/env ruby

$serverName = 'EasySoap++'

require 'clientBase'
require 'soap/XMLSchemaDatatypes1999'


$server = 'http://www.xmethods.net/c/easysoap.cgi'
$soapAction = 'urn:soapinterop'

drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
