=begin
WSDL4R - Creating driver code from WSDL.
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


module WSDL
  module SOAP


class DriverCreator
  attr_reader :definitions

  def initialize( definitions )
    @definitions = definitions
  end

  def dump( portType = nil )
    if portType.nil?
      result = ""
      @definitions.portTypes.each do | portType |
	result << dumpPortType( portType.name )
	result << "\n"
      end
    else
      result = dumpPortType( portType )
    end
    result
  end

private

  def dumpPortType( portType )
    methodDefCreator = MethodDefCreator.new( @definitions )
    methodDef, types = methodDefCreator.dump( portType )
    mrCreator = MappingRegistryCreator.new( @definitions )

    return <<__EOD__
require 'soap/proxy'
require 'soap/rpcUtils'
require 'soap/streamHandler'

class #{ createClassName( portType.name ) }
#{ mrCreator.dump( types ).gsub( /^/, "  " ).chomp }
  Methods = [
#{ methodDef.gsub( /^/, "    " ) }
  ]

  attr_reader :endpointUrl
  attr_reader :proxyUrl

  def initialize( endpointUrl, proxyUrl = nil )
    @endpointUrl = endpointUrl
    @proxyUrl = proxyUrl
    @httpStreamHandler = SOAP::HTTPPostStreamHandler.new( @endpointUrl,
      @proxyUrl )
    @proxy = SOAP::SOAPProxy.new( nil, @httpStreamHandler, nil )
    @proxy.allowUnqualifiedElement = true
    @mappingRegistry = MappingRegistry
    addMethod
  end

  def setWireDumpDev( dumpDev )
    @httpStreamHandler.dumpDev = dumpDev
  end

  def setDefaultEncodingStyle( encodingStyle )
    @proxy.defaultEncodingStyle = encodingStyle
  end

  def getDefaultEncodingStyle
    @proxy.defaultEncodingStyle
  end

  def call( methodName, *params )
    # Convert parameters
    params.collect! { | param |
      SOAP::RPCUtils.obj2soap( param, @mappingRegistry )
    }

    # Then, call @proxy.call like the following.
    header, body = @proxy.call( nil, methodName, *params )

    # Check Fault.
    begin
      @proxy.checkFault( body )
    rescue SOAP::FaultError => e
      SOAP::RPCUtils.fault2exception( e, @mappingRegistry )
    end

    ret = body.response ?
      SOAP::RPCUtils.soap2obj( body.response, @mappingRegistry ) : nil
    if body.outParams
      outParams = body.outParams.collect { | outParam |
	SOAP::RPCUtils.soap2obj( outParam )
      }
      return [ ret ].concat( outParams )
    else
      return ret
    end
  end

private 

  def addMethod
    Methods.each do | methodNameAs, methodName, params, soapAction, namespace |
      @proxy.addMethodAs( methodNameAs, methodName, params, soapAction,
	namespace )
      addMethodInterface( methodNameAs, params )
    end
  end

  def addMethodInterface( name, params )
    self.instance_eval <<-EOD
      def \#{ name }( *params )
	call( "\#{ name }", *params )
      end
    EOD
  end
end
__EOD__
  end

  def capitalize( target )
    target.gsub( /^([a-z])/ ) { $1.tr!( '[a-z]', '[A-Z]' ) }
  end

  def createClassName( name )
    result = capitalize( name )
    unless /^[A-Z]/ =~ result
      result = "C_#{ name }"
    end
    result
  end
end


  end
end
