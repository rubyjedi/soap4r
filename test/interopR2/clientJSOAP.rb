#!/usr/bin/env ruby

$serverName = 'Spheon JSOAP'
$server = 'http://soap.fmui.de/RPC'

require 'clientBase'

logger = Devel::Logger.new( STDERR )
logger.sevThreshold = Devel::Logger::SEV_INFO

drv = SOAP::Driver.new( logger, 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
submitTestResult
