#!/usr/bin/env ruby

require "soap/driver"
require 'iExchange'

server = "http://localhost:2000/soapsrv"
proxy = nil
# server = "http://services.xmethods.net/soap"
# namespace = "urn:xmethods-CurrencyExchange"
# proxy = "http://ifront0:8080"

drv = SOAP::Driver.new( nil, nil, ExchangeServiceNamespace, server, proxy )
drv.addMethod( "getRate", "country1", "country2" )

p drv.getRate( "USA", "Japan" )
