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
require 'wsdl/soap/methodDefCreatorSupport'


module WSDL
  module SOAP


class DriverCreator
  include MethodDefCreatorSupport

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

  def dumpPortType( portTypeName )
    methodDefCreator = MethodDefCreator.new( @definitions )
    methodDef, types = methodDefCreator.dump( portTypeName )
    mrCreator = MappingRegistryCreator.new( @definitions )
    binding = @definitions.bindings.find { | item | item.type == portTypeName }
    addresses = @definitions.getPortType( portTypeName ).getLocations

    return <<__EOD__
require 'soap/proxy'
require 'soap/rpcUtils'
require 'soap/streamHandler'

class #{ createClassName( portTypeName ) }
  class EmptyResponseError < ::SOAP::Error; end

  MappingRegistry = ::SOAP::RPCUtils::MappingRegistry.new

#{ mrCreator.dump( types ).gsub( /^/, "  " ).chomp }
  Methods = [
#{ methodDef.gsub( /^/, "    " ) }
  ]

  DefaultEndpointUrl = "#{ addresses[ 0 ] }"

  attr_accessor :mappingRegistry
  attr_reader :endPointUrl
  attr_reader :wireDumpDev
  attr_reader :wireDumpFileBase
  attr_reader :httpProxy

  def initialize( endpointUrl = DefaultEndpointUrl, httpProxy = nil )
    @endpointUrl = endpointUrl
    @mappingRegistry = MappingRegistry
    @wireDumpDev = nil
    @dumpFileBase = nil
    @httpProxy = ENV[ 'http_proxy' ] || ENV[ 'HTTP_PROXY' ]
    @handler = ::SOAP::HTTPPostStreamHandler.new( @endpointUrl, @httpProxy,
      ::SOAP::Charset.getEncodingLabel )
    @proxy = ::SOAP::SOAPProxy.new( @namespace, @handler )
    @proxy.allowUnqualifiedElement = true
    addMethod
  end

  def setEndpointUrl( endpointUrl )
    @endpointUrl = endpointUrl
    @handler.endpointUrl = @endpointUrl if @handler
  end

  def setWireDumpDev( dumpDev )
    @wireDumpDev = dumpDev
    @handler.dumpDev = @wireDumpDev if @handler
  end

  def setWireDumpFileBase( base )
    @dumpFileBase = base
  end

  def setHttpProxy( httpProxy )
    @httpProxy = httpProxy
    @handler.proxy = @httpProxy if @handler
  end

  def setDefaultEncodingStyle( encodingStyle )
    @proxy.defaultEncodingStyle = encodingStyle
  end

  def getDefaultEncodingStyle
    @proxy.defaultEncodingStyle
  end

  def call( methodName, *params )
    # Convert parameters: params array => SOAPArray => members array
    params = ::SOAP::RPCUtils.obj2soap( params, @mappingRegistry ).to_a
    header, body = @proxy.call( nil, methodName, *params )
    unless body
      raise EmptyResponseError.new( "Empty response." )
    end

    # Check Fault.
    begin
      @proxy.checkFault( body )
    rescue ::SOAP::FaultError => e
      ::SOAP::RPCUtils.fault2exception( e )
    end

    ret = body.response ?
      ::SOAP::RPCUtils.soap2obj( body.response, @mappingRegistry ) : nil
    if body.outParams
      outParams = body.outParams.collect { | outParam |
	::SOAP::RPCUtils.soap2obj( outParam )
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
      addMethodInterface( methodName, params )
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
end


  end
end
