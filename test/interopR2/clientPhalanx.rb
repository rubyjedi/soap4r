#!/usr/bin/env ruby

$serverName = 'Phalanx'

$serverBase =   'http://www.phalanxsys.com/ilabA/typed/target.asp'
$serverGroupB = 'http://www.phalanxsys.com/ilabB/typed/target.asp'

require 'clientBase'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDef( drvBase )

drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
methodDefGroupB( drvGroupB )

doTestBase( drvBase )
doTestGroupB( drvGroupB )
submitTestResult
