#!/usr/bin/env ruby
# encoding: UTF-8

$serverName = 'NuWave'

$server = '	http://interop.nuwave-tech.com:7070/interop/base.wsdl'
$noEchoMap = true

require 'clientBase'

drv = SOAP::RPC::Driver.new($server, InterfaceNS)
methodDef(drv)

doTestBase(drv)
#doTestGroupB(drv)
submitTestResult
