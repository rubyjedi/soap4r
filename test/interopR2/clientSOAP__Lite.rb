#!/usr/bin/env ruby
# encoding: UTF-8

$serverName = 'SOAP::Lite'

$server = 'http://services.soaplite.com/interop.cgi'

require 'clientBase'

drv = SOAP::RPC::Driver.new($server, InterfaceNS)
methodDef(drv)

doTestBase(drv)
doTestGroupB(drv)
submitTestResult
