#!/usr/bin/env ruby
# encoding: ASCII-8BIT

$serverName = 'MSASPdotNETWebServices'
$serverBase = 'http://www.mssoapinterop.org/asmx/simple.asmx'
$serverGroupB = 'http://www.mssoapinterop.org/asmx/simpleB.asmx'

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDefBase(drvBase)

drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
