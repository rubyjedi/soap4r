#!/usr/bin/env ruby

proxy = ARGV.shift || nil

require 'soap/driver'
require 'soap/XMLSchemaDatatypes1999'

Input = Struct.new( 'Input', :text, :language )

InterfaceNS = 'urn:vgx-translate'
server = 'http://services.xmltoday.com/vx_engine/soap-trigger.pperl'


drv = SOAP::Driver.new( nil, nil, InterfaceNS, server, proxy, InterfaceNS )
drv.addMethod( 'getTranslation', 'input' )
drv.setWireDumpDev( STDERR )

anInput = Input.new( 'Hello World.', 'Spanish' )
drv.getTranslation( anInput )
