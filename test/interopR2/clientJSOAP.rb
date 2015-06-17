#!/usr/bin/env ruby
# encoding: UTF-8

$serverName = 'SpheonJSOAP'
$server = 'http://soap.fmui.de/RPC'

require 'clientBase'

drv = SOAP::RPC::Driver.new($server, InterfaceNS)

methodDef(drv)

doTestBase(drv)
doTestGroupB(drv)
submitTestResult
