#!/usr/bin/env ruby

require "soap/driver"
require 'iExchange'

server = "http://localhost:2000/soapsrv"

logger = nil
wireDumpDev = nil
# logger = Devel::Logger.new( STDERR )
# wireDumpDev = STDERR

drv = SOAP::Driver.new( logger, $0, ExchangeServiceNamespace, server )
drv.setWireDumpDev( wireDumpDev )
drv.addMethod( "getRate", "country1", "country2" )

p drv.getRate( "USA", "Japan" )
