#!/usr/bin/env ruby

require 'soap/driver'

server = 'http://www.jin.gr.jp/~nahi/yarpc/soapServer.cgi'
proxy = ARGV.shift || nil

NS = 'http://www.ruby-lang.org/xmlns/soap/interface/RWiki/0.0.1'

def getWireDumpLogFile
  logFilename = File.basename( $0 ) + '.log'
  f = File.open( logFilename, 'w' )
  f << "File: #{ logFilename } - Wiredumps for SOAP4R client / #{ $serverName } server.\n"
  f << "Date: #{ Time.now }\n\n"
end


drv = SOAP::Driver.new( nil, 'rwikiClientApp', NS, server, proxy )
drv.setWireDumpDev( getWireDumpLogFile )
drv.addMethod( 'find', 'keyword' )
drv.addMethod( 'src', 'name' )
drv.addMethod( 'view', 'name', 'env' )
drv.addMethod( 'setSrcAndView', 'name', 'src', 'env' )

from = "nahi"
to = "hina"

env = { 'base' => 'mailto:nahi@keynauts.com' }

drv.find( from ).each do | name |
  p name
  src = drv.src( name )
  src.gsub!( /#{ from }/i, to )
#  drv.setSrcAndView( name, src, env )
end

drv.find( from ).each do | name |
  puts drv.view( name, env )
end
