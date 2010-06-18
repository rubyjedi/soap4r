#!/usr/bin/env ruby
# encoding: ASCII-8BIT

$serverName = '4S4C2'
$server = 'http://soap.4s4c.com/ilab2/soap.asp'

require 'clientBase'

drv = SOAP::RPC::Driver.new($server, InterfaceNS)

methodDef(drv)

doTestBase(drv)
doTestGroupB(drv)
submitTestResult
