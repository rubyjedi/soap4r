#!/usr/bin/env ruby

require "soap/driver"

server = "http://localhost:2000/soap"
#server = "http://localhost:2002/soap"
namespace = "urn:exchangeService"
proxy = nil
# server = "http://services.xmethods.net/soap"
# namespace = "urn:xmethods-CurrencyExchange"
# proxy = "http://ifront0:8080"

drv = SOAP::Driver.new( nil, nil, namespace, server, proxy )
drv.addMethod( "getRate", "country1", "country2" )

p drv.getRate( "USA", "Japan" )
