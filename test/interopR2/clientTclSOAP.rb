#!/usr/bin/env ruby

$serverName = 'TclSOAP 1.6'

$server = 'http://tclsoap.sourceforge.net/cgi-bin/rpc'

require 'clientBase'
$soapAction = 'urn:soapinterop'
require 'soap/XMLSchemaDatatypes1999'

log = Log.new( STDERR )
log.sevThreshold = Log::SEV_INFO        # Log::SEV_WARN, Log::SEV_DEBUG

drv = SOAP::Driver.new( log, 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )
methodDef( drv )

doTestBase( drv )
#doTestGroupB( drv )
#submitTestResult
