#!/usr/bin/env ruby

proxy = ARGV.shift || nil

require 'soap/driver'

require 'iRAA'
include RAA
server = 'http://www.ruby-lang.org/~nahi/soap/raa/'


###
## Create Proxy
#
def getWireDumpLogFile
  logFilename = File.basename( $0 ) + '.log'
  f = File.open( logFilename, 'w' )
  f << "File: #{ logFilename } - Wiredumps for SOAP4R client.\n"
  f << "Date: #{ Time.now }\n\n"
end

raa = SOAP::Driver.new( Log.new( STDERR ), 'SampleApp', RAA::InterfaceNS, server, proxy )
raa.setWireDumpDev( getWireDumpLogFile )

RAA::Methods.each do | method, params |
  raa.addMethod( method, *( params[1..-1] ))
end


###
## Invoke methods.
#
p raa.getAllListings().sort

p raa.getProductTree()

p raa.getInfoFromCategory( Category.new( "Library", "XML" ))

cat = Struct.new( "CCC", "major", "minor" )
p raa.getInfoFromCategory( cat.new( "Library", "XML" ))

t = Time.at( Time.now.to_i - 24 * 3600 )
p raa.getModifiedInfoSince( t )
p raa.getModifiedInfoSince( Date.new3( t.year, t.mon, t.mday, t.hour, t.min, t.sec ))

p raa.getInfoFromName( "SOAP4R" )
