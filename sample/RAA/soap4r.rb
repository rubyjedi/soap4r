#!/usr/bin/env ruby

require 'RAA'
require 'pp'
require 'soap/marshal'

server = 'http://www.ruby-lang.org/~nahi/soap/raa/'
proxy = ARGV.shift || nil

raa = RAA::Driver.new( server, proxy )

p raa.getAllListings().sort

p raa.getProductTree()

p raa.getInfoFromCategory( RAA::Category.new( "Library", "XML" ))

t = Time.at( Time.now.to_i - 24 * 3600 )
p raa.getModifiedInfoSince( t )
p raa.getModifiedInfoSince( DateTime.new3( t.year, t.mon, t.mday, t.hour, t.min, t.sec ))

p raa.getInfoFromName( "SOAP4R" )
