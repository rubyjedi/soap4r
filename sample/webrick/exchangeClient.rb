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
drv.addMethodWithSOAPAction( "getRate", ExchangeServiceNamespace, "country1", "country2" )
drv.addMethodWithSOAPAction( "called", ExchangeServiceNamespace )
drv.addMethodWithSOAPAction( "startTime", ExchangeServiceNamespace )

p drv.getRate( "USA", "Japan" )
p drv.called
p drv.startTime.to_s
