#!/usr/bin/env ruby

require 'soap/driver'

server = ARGV.shift or raise ArgumentError.new( 'Target URL was not given.' )
proxy = ARGV.shift || nil

require 'soap/XMLSchemaDatatypes1999'

def getWireDumpLogFile
  logFilename = File.basename( $0 ) + '.log'
  f = File.open( logFilename, 'w' )
  f << "File: #{ logFilename } - Wiredumps for SOAP4R client / #{ $serverName } server.\n"
  f << "Date: #{ Time.now }\n\n"
end


=begin
# http://www.hippo2000.net/cgi-bin/soap.cgi

NS = 'urn:Geometry2'

drv = SOAP::Driver.new( Log.new( STDERR ), 'hippoApp', NS, server, proxy )
drv.setWireDumpDev( getWireDumpLogFile )
drv.addMethod( 'calcArea', 'x1', 'y1', 'x2', 'y2' )

puts drv.calcArea( 5, 1000, 10, 20 )
=end

=begin
# http://www.hippo2000.net/cgi-bin/soap.pl?class=Geometry

NS = 'urn:ServerDemo'

class Point
  @@namespace = NS
  def initialize( x, y )
    @x = x
    @y = y
  end
end

origin = Point.new( 10, 10 )
corner = Point.new( 110, 110 )

drv = SOAP::Driver.new( Log.new( STDERR ), 'hippoApp', NS, server, proxy )
drv.setWireDumpDev( getWireDumpLogFile )
drv.addMethod( 'calculateArea', 'origin', 'corner' )

puts drv.calculateArea( origin, corner )
=end

=begin
# http://www.hippo2000.net/cgi-bin/soapEx.cgi

NS = 'urn:SoapEx'

drv = SOAP::Driver.new( Log.new( STDERR ), 'hippoApp', NS, server, proxy )
drv.setWireDumpDev( getWireDumpLogFile )
drv.addMethod( 'calcArea', 'x1', 'y1', 'x2', 'y2' )

# calcArea sample
p drv.calcArea( 5, 10, 10, 15 )
=end


=begin
# http://www.hippo2000.net/cgi-bin/soapEx.cgi

NS = 'urn:SoapEx'

drv = SOAP::Driver.new( Log.new( STDERR ), 'hippoApp', NS, server, proxy )
drv.setWireDumpDev( getWireDumpLogFile )
drv.addMethod( 'parseChasen', 'target' )
drv.addMethod( 'parseChasenArry', 'target' )

require 'uconv'

# ChaSen Sample 1
def putLine( index, kanaName, pos )
  line = "#{ index }\t\t#{ kanaName }\t\t#{ pos }"
  puts Uconv.u8toeuc( line )
end

targetString = Uconv.euctou8( 'SOAPを使うと楽しいですか?' )

result = drv.parseChasen( targetString )

index = Uconv.euctou8( '見出し' )
kanaName = Uconv.euctou8( '読み' )
pos = Uconv.euctou8( '品詞' )

putLine( index, kanaName, pos )

result.each do | ele |
  putLine( ele[ index ], ele[ kanaName ], ele[ pos ] )
end


# ChaSen Sample 2
targetString = Uconv.euctou8( '楽しい技術ですか?' )

drv.parseChasenArry( targetString ).each do | ele |
  puts Uconv.u8toeuc( ele )
end
=end
