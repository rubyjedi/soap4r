#!/usr/bin/env ruby
# encoding: ASCII-8BIT

$serverName = 'Oracle'

$server = 'http://ws-interop.oracle.com/soapbuilder/r2/InteropTest'
$noEchoMap = true

require 'clientBase'

drv = SOAP::RPC::Driver.new($server, InterfaceNS)
methodDef(drv)

doTestBase(drv)
#doTestGroupB(drv)
submitTestResult
