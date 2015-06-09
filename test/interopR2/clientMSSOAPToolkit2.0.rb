#!/usr/bin/env ruby
# encoding: UTF-8

$serverName = 'MicrosoftSoapToolkitV2'
$serverBase = 'http://mssoapinterop.org/stk/InteropB.wsdl'
$serverGroupB = 'http://mssoapinterop.org/stk/InteropBtyped.wsdl'

require 'clientBase'

drvBase = SOAP::RPC::Driver.new($serverBase, InterfaceNS)
methodDefBase(drvBase)

drvGroupB = SOAP::RPC::Driver.new($serverGroupB, InterfaceNS)
methodDefGroupB(drvGroupB)

doTestBase(drvBase)
doTestGroupB(drvGroupB)
submitTestResult
