#!/usr/bin/env ruby

$serverName = 'HP SOAP'
$server = 'http://soap.bluestone.com/hpws/soap/EchoService'

require 'clientBase'

logger = Devel::Logger.new( STDERR )
logger.sevThreshold = Devel::Logger::SEV_INFO

drv = SOAP::Driver.new( logger, 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
submitTestResult
