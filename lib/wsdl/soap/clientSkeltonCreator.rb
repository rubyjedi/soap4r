=begin
WSDL4R - Creating client skelton code from WSDL.
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
require 'wsdl/soap/methodDefCreatorSupport'


module WSDL
  module SOAP


class ClientSkeltonCreator
  include MethodDefCreatorSupport

  attr_reader :definitions

  def initialize( definitions )
    @definitions = definitions
  end

  def dump( serviceName )
    result = ""
    @definitions.getService( serviceName ).ports.each do | port |
      result << dumpPortType( port.getPortType.name )
      result << "\n"
    end
    result
  end

private

  def dumpPortType( portTypeName )
    driverName = createClassName( portTypeName )

    result = ""
    result << <<__EOD__
endpointUrl = ARGV.shift || #{ driverName }::DefaultEndpointUrl
proxyUrl = ENV[ 'http_proxy' ] || ENV[ 'HTTP_PROXY' ]
obj = #{ driverName }.new( endpointUrl, proxyUrl )

# Uncomment the below line to see SOAP wiredumps.
# obj.setWireDumpDev( STDERR )


__EOD__
    @definitions.getPortType( portTypeName ).operations.each do | operation |
      result << dumpSignature( operation )
      result << dumpInputInitialize( operation.input ) << "\n"
      result << dumpOperation( operation ) << "\n\n"
    end
    result
  end

  def dumpOperation( operation )
    name = operation.name.name
    input = operation.input
    "puts obj.#{ name }#{ dumpInputParam( input ) }"
  end

  def dumpInputInitialize( input )
    result = input.getMessage.parts.collect { | part |
      "#{ part.name }"
    }.join( " = " )
    if result.empty?
      ""
    else
      result << " = nil"
    end
    result
  end
end


  end
end
