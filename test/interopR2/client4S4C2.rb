#!/usr/bin/env ruby

$serverName = '4S4C2'
$server = 'http://soap.4s4c.com/ilab2/soap.asp'

require 'clientBase'

logger = Devel::Logger.new( STDERR )
logger.sevThreshold = Devel::Logger::SEV_INFO

drv = SOAP::Driver.new( logger, 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
submitTestResult
