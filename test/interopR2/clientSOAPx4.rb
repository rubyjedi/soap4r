#!/usr/bin/env ruby

$serverName = 'SOAPx4 (PHP) .5'

$serverBase = 'http://dietrich.ganx4.com/soapx4/soap.php'
#$serverGroupB = ''

require 'clientBase'
require 'soap/XMLSchemaDatatypes1999'

drvBase = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverBase, $proxy, $soapAction )
methodDef( drvBase )

#drvGroupB = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $serverGroupB, $proxy, $soapAction )
#methodDefGroupB( drvGroupB )

doTestBase( drvBase )
#doTestGroupB( drvGroupB )
submitTestResult
