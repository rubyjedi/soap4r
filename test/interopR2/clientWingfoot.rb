#!/usr/bin/env ruby

$serverName = 'Wingfoot SOAP Server'

$server = 'http://www.wingfoot.com/servlet/wserver'
$noEchoMap = true

require 'clientBase'

drv = SOAP::RPC::Driver.new($server, InterfaceNS)
methodDef(drv)

doTestBase(drv)
doTestGroupB(drv)
submitTestResult
