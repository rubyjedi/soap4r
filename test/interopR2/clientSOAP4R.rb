#!/usr/bin/env ruby

$serverName = 'SOAP4R'

$server = 'http://www.jin.gr.jp/~nahi/Ruby/SOAP4R/SOAPBuildersInterop/'
#$server = 'http://www.jin.gr.jp/~nahi/Ruby/SOAP4R/SOAPBuildersInterop/1999/'
#require 'soap/XMLSchemaDatatypes1999'

require 'clientBase'

log = Log.new( STDERR )
log.sevThreshold = Log::SEV_INFO	# Log::SEV_WARN, Log::SEV_DEBUG

drv = SOAP::Driver.new( log, 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )
methodDef( drv )

doTestBase( drv )
doTestGroupB( drv )
submitTestResult
