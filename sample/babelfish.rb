#!/usr/bin/env ruby

proxy = ARGV.shift || nil

require 'soap/driver'

InterfaceNS = 'urn:xmethodsBabelFish'
server = 'http://services.xmethods.net/perl/soaplite.cgi'

drv = SOAP::Driver.new( nil, nil, InterfaceNS, server, proxy )
drv.addMethodWithSOAPAction( 'BabelFish', InterfaceNS + "#BabelFish", 'translationmode', 'sourcedata' )
drv.setWireDumpDev( STDERR )

p drv.BabelFish( 'en_fr', 'Hello World.' )
