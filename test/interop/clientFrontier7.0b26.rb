#!/usr/bin/env ruby

$serverName = 'Frontier 7.0b26(Userland)'

# NG: returned struct from Frontier is not typed(not bad).

require 'clientBase'

module XSD
  Namespace = 'http://www.w3.org/1999/XMLSchema'
  InstanceNamespace = 'http://www.w3.org/1999/XMLSchema-instance'
  NilLiteral = 'null'
end


$server = 'http://www.soapware.org/xmethodsInterop'
$soapAction = '/xmethodsInterop'

class SOAPStruct
  @@typeNamespace = 'http://www.xmethods.com/service'
end


drv = SOAP::Driver.new( Log.new( STDERR ), 'InteropApp', InterfaceNS, $server, $proxy, $soapAction )

methodDef( drv )

doTest( drv )
