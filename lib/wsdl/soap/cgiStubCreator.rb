=begin
WSDL4R - Creating CGI stub code from WSDL.
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


class CGIStubCreator
  include MethodDefCreatorSupport

  attr_reader :definitions

  def initialize( definitions )
    @definitions = definitions
  end

  def dump( serviceName )
    STDERR.puts "!!! IMPORTANT !!!"
    STDERR.puts "- CGI stub can only 1 port.  Creating stub for the first port...  Rests are ignored."
    STDERR.puts "!!! IMPORTANT !!!"
    port = @definitions.getService( serviceName ).ports[ 0 ]
    dumpPortType( port.getPortType.name )
  end

private

  def dumpPortType( portTypeName )
    className = createClassName( portTypeName.name )
    methodDefCreator = MethodDefCreator.new( @definitions )
    methodDef, types = methodDefCreator.dump( portTypeName )
    mrCreator = MappingRegistryCreator.new( @definitions )

    return <<__EOD__
require 'soap/cgistub'

class #{ className }
  require 'soap/rpcUtils'
  MappingRegistry = SOAP::RPCUtils::MappingRegistry.new

#{ mrCreator.dump( types ).gsub( /^/, "  " ).chomp }
  Methods = [
#{ methodDef.gsub( /^/, "    " ).chomp }
  ]
end

class App < SOAP::CGIStub
  def initialize( *arg )
    super( *arg )
    servant = #{ className }.new
    #{ className }::Methods.each do | methodNameAs, methodName, params, soapAction, namespace |
      addMethodWithNSAs( namespace, servant, methodName, methodNameAs, params, soapAction )
    end

    self.mappingRegistry = #{ className }::MappingRegistry
    setSevThreshold( Devel::Logger::ERROR )
  end
end

# Change listen port.
App.new( 'app', nil ).start
__EOD__
  end
end


  end
end
