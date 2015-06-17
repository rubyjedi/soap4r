#!/usr/bin/env ruby
# encoding: UTF-8

$serverName = 'HPSOAP'
$server = 'http://soap.bluestone.com/hpws/soap/EchoService'

require 'clientBase'

drv = SOAP::RPC::Driver.new($server, InterfaceNS)

methodDef(drv)

doTest(drv)
submitTestResult
