#!/usr/bin/env ruby

$serverName = '4S4C'
$server = 'http://soap.4s4c.com/ilab/soap.asp'
$noEchoMap = true

require 'clientBase'

logger = Devel::Logger.new( STDERR )
logger.sevThreshold = Devel::Logger::SEV_INFO

drv = SOAP::Driver.new( logger, 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
submitTestResult
