#!/usr/bin/env ruby

require 'RAA'
require 'pp'
require 'soap/marshal'

server = 'http://www.ruby-lang.org/~nahi/soap/raa/'
proxy = ENV[ 'HTTP_PROXY' ] || ENV[ 'http_proxy' ]

raa = RAA::Driver.new( server, proxy )
raa.setLogDev( nil )

p raa.getAllListings().sort

p raa.getProductTree()

p raa.getInfoFromCategory( RAA::Category.new( "Library", "XML" ))

t = Time.at( Time.now.to_i - 24 * 3600 )
p raa.getModifiedInfoSince( t )
p raa.getModifiedInfoSince( DateTime.new( t.year, t.mon, t.mday, t.hour, t.min, t.sec ))

o = raa.getInfoFromName( "SOAP4R" )
p o.type
p o.owner.name
p o
