#!/usr/bin/env ruby
# encoding: ASCII-8BIT

$serverName = 'EasySoap++'

$server = 'http://easysoap.sourceforge.net/cgi-bin/interopserver'

require 'clientBase'

drv = SOAP::RPC::Driver.new($server, InterfaceNS)
methodDef(drv)

doTestBase(drv)
doTestGroupB(drv)
submitTestResult
