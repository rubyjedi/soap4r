=begin
WSDL4R - Creating WEBrick + SOAPlet stub code from WSDL.
Copyright (C) 2002 NAKAMURA Hiroshi.

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PRATICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 675 Mass
Ave, Cambridge, MA 02139, USA.
=end


require 'wsdl/info'
require 'wsdl/soap/mappingRegistryCreator'
require 'wsdl/soap/methodDefCreator'
require 'wsdl/soap/methodDefCreatorSupport'


module WSDL
  module SOAP


class WEBrickStubCreator
  include MethodDefCreatorSupport

  attr_reader :definitions

  def initialize( definitions )
    @definitions = definitions
  end

  def dump( serviceName )
    STDERR.puts "!!! IMPORTANT !!!"
    STDERR.puts "WEBrick stub ignores port location defined in WSDL.  Location is http://localhost:10080/soapsrv by default.  Generated client from WSDL must be configured to point this endpoint by hand."
    STDERR.puts "!!! IMPORTANT !!!"

    result = ""
    result << <<__EOD__
require 'webrick'

STDERR.puts "All WEBrick httpd functions are enabled such as ERuby and CGI."
STDERR.puts "Take care before running this server in public network."

require 'devel/logger'
logDev = Devel::Logger.new( 'httpd.log' )
logDev.sevThreshold = Devel::Logger::SEV_INFO

wwwsvr = WEBrick::HTTPServer.new(
  :BindAddress    => "0.0.0.0",
  :Port           => 10080, 
  :Logger         => logDev
)

require 'soaplet'
soapsrv = WEBrick::SOAPlet.new

require 'soap/rpcUtils'
MappingRegistry = SOAP::RPCUtils::MappingRegistry.new
__EOD__

    @definitions.getService( serviceName ).ports.each do | port |
      result << dumpPortType( port.getPortType.name )
      result << "\n"
    end

    result << <<__EOD__
soapsrv.appScopeRouter.mappingRegistry = Sm11PortType::MappingRegistry
wwwsvr.mount( '/soapsrv', soapsrv )

trap( "INT" ){ wwwsvr.shutdown }
wwwsvr.start
__EOD__
    result
  end

private

  def dumpPortType( portTypeName )
    className = createClassName( portTypeName )
    methodDefCreator = MethodDefCreator.new( @definitions )
    methodDef, types = methodDefCreator.dump( portTypeName )
    mrCreator = MappingRegistryCreator.new( @definitions )

    return <<__EOD__
#{ mrCreator.dump( types ).gsub( /^/, "  " ).chomp }

class #{ className }
  Methods = [
#{ methodDef.gsub( /^/, "    " ).chomp }
  ]
end

servant = #{ className }.new
Sm11PortType::Methods.each do | nameAs, name, params, soapAction, ns |
  soapsrv.appScopeRouter.addMethodAs( ns, servant, name, nameAs, params )
end
__EOD__
  end
end


  end
end
