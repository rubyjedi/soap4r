#!/usr/bin/env ruby
# encoding: ASCII-8BIT

$serverName = 'WingfootSOAPServer'

$server = 'http://www.wingfoot.com/servlet/wserver'
$noEchoMap = true

require 'clientBase'

drv = SOAP::RPC::Driver.new($server, InterfaceNS)
methodDef(drv)

doTestBase(drv)
doTestGroupB(drv)
submitTestResult
