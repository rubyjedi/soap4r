#!/usr/bin/env ruby

require 'getoptlong'
require 'wsdl/xmlparser'
require 'wsdl/soap/classDefCreator'
require 'wsdl/soap/stubCreator'
require 'wsdl/soap/driverCreator'

def usageExit
  puts "Usage: #{ $0 } --type server|client wsdlfilename"
  exit 1
end
opt = GetoptLong.new (
  ['--type','-t', GetoptLong::REQUIRED_ARGUMENT]
)

server = client = false
begin
  opt.each do | name, arg |
    case name
    when "--type"
      case arg
      when "server"
	server = true
      when "client"
	client = true
      else
	raise ArgumentError.new( "Unknown type #{ arg }" )
      end
    end
  end
rescue
  usageExit
end
usageExit if !server and !client

wsdlFile = ARGV.shift
usageExit unless wsdlFile

wsdl = WSDL::WSDLXMLParser.new.parse( File.open( wsdlFile ))

# Class definition
File.open( "classDef.rb", "w" ) do | f |
  f << WSDL::SOAP::ClassDefCreator.new( wsdl ).dump
end

if server
  File.open( "servant.rb", "w" ) do | f |
    f << "require 'classDef'\n\n"
    f << WSDL::SOAP::StubCreator.new( wsdl ).dump
  end
end

if client
  File.open( "driver.rb", "w" ) do | f |
    f << "require 'classDef'\n\n"
    f << WSDL::SOAP::DriverCreator.new( wsdl ).dump
  end
end
