#!/usr/bin/env ruby

$serverName = 'Frontier 7.0b26(Userland)'

# NG: returned struct from Frontier is not typed(not bad).

require 'clientBase'
require 'soap/XMLSchemaDatatypes1999'


$server = 'http://www.soapware.org/xmethodsInterop'
$soapAction = '/xmethodsInterop'

class SOAPStruct
  @@typeNamespace = 'http://www.xmethods.com/service'
end


drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
