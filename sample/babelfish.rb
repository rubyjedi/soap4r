#!/usr/bin/env ruby

text = ARGV.shift || 'Hello world.'
lang = ARGV.shift || 'en_fr'

require 'soap/driver'

server = 'http://services.xmethods.net/perl/soaplite.cgi'
InterfaceNS = 'urn:xmethodsBabelFish'
logger = nil		# Devel::Logger.new( STDERR )
wireDumpDev = nil	# STDERR
proxy = ENV[ 'HTTP_PROXY' ] || ENV[ 'http_proxy' ]

drv = SOAP::Driver.new( logger, $0, InterfaceNS, server, proxy )
drv.setWireDumpDev( wireDumpDev )
drv.addMethodWithSOAPAction( 'BabelFish', InterfaceNS + "#BabelFish", 'translationmode', 'sourcedata' )

p drv.BabelFish( lang, text )
