=begin
SOAP4R - RPC Routing library
Copyright (C) 2001 NAKAMURA Hiroshi.

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

require 'soap/soap'
require 'soap/processor'
require 'soap/rpcUtils'

# Ruby bundled library

# Redist library


module SOAP


class RPCRouter
  include SOAP
  include Processor
  include RPCUtils

  class RPCRoutingError < Error; end

  attr_reader :actor
  attr_accessor :allowUnqualifiedElement
  attr_accessor :mappingRegistry

  def initialize( actor )
    @actor = actor
    @namespace = {}
    @receiver = {}
    @method = {}
    @allowUnqualifiedElement = false
    @mappingRegistry = nil
    initParser
  end

  # Method definition.
  def addMethod( namespace, receiver, methodName, paramDef, soapAction = nil )
    name = "#{ namespace }:#{ methodName }"
    @receiver[ name ] = receiver
    @method[ name ] = SOAPMethodRequest.new( namespace, methodName, paramDef, soapAction )
  end

  def addHeaderHandler
    raise NotImplementedError.new
  end

  # Routing...
  def route( soapString )
    isFault = false
    begin

      # Is this right?
      soapString = soapString.dup
      soapString.gsub!( "\r\n", "\n" )
      soapString.gsub!( "\r", "\n" )
      header, body = unmarshal( soapString )

      # So far, header is omitted...

      soapRequest = body.request
      unless soapRequest.is_a?( SOAPStruct )
	raise RPCRoutingError.new( "Not an RPC style." )
      end

      soapResponse = nil

      soapResponse = dispatch( soapRequest )

    rescue Exception
      soapResponse = fault( $! )
      isFault = true
    end

    header = SOAPHeader.new
    body = SOAPBody.new( soapResponse )
    responseString = marshal( header, body )

    return responseString, isFault
  end

  # Create fault response string.
  def createFaultResponseString( e )
    soapResponse = fault( e )

    header = SOAPHeader.new
    body = SOAPBody.new( soapResponse )
    responseString = marshal( header, body )

    responseString
  end

private

  def initParser
    opt = {}
    opt[ 'allowUnqualifiedElement' ] = true if @allowUnqualifiedElement
    Processor.setDefaultParser( opt )
  end

  # Create new response.
  def createResponse( namespace, methodName, result )
    name = "#{ namespace }:#{ methodName }"
    if ( @method.has_key?( name ))
      method = @method[ name ]
    else
      raise RPCRoutingError.new( "Method: #{ name } not defined." )
    end

    soapResponse = method.createMethodResponse
    if soapResponse.outParam?
      unless result.is_a?( Array )
	raise RPCRoutingError.new( "Out parameter was not returned." )
      end
      outParams = {}
      i = 1
      soapResponse.eachParamName( 'out', 'inout' ) do | outParam |
	outParams[ outParam ] = RPCUtils.obj2soap( result[ i ], @mappingRegistry )
	i += 1
      end
      soapResponse.setOutParams( outParams )
      soapResponse.setRetVal( RPCUtils.obj2soap( result[ 0 ], @mappingRegistry ))
    else
      soapResponse.setRetVal( RPCUtils.obj2soap( result, @mappingRegistry ))
    end
    soapResponse
  end

  # Create fault response.
  def fault( e )
    detail = RPCUtils::SOAPException.new( e )
    SOAPFault.new(
      SOAPString.new( 'Server' ),
      SOAPString.new( e.to_s ),
      SOAPString.new( @actor ),
      RPCUtils.obj2soap( detail ))
  end

  # Dispatch to defined method.
  def dispatch( soapMethod )
    namespace = soapMethod.namespace
    methodName = soapMethod.typeName || soapMethod.name

    requestStruct = RPCUtils.soap2obj( soapMethod, @mappingRegistry )
    values = requestStruct.members.collect { |member|
      requestStruct[ member ]
    }
    method = lookup( namespace, methodName, values )
    unless method
      raise RPCRoutingError.new( "Method: #{methodName} not supported." )
    end

    result = method.call( *values )
    createResponse( namespace, methodName, result )
  end

  # Method lookup
  def lookup( namespace, methodName, values )
    name = "#{ namespace }:#{ methodName }"
    # It may be necessary to check all part of method signature...
    if @method.member?( name )
      @receiver[ name ].method( @method[ name ].name.intern )
    else
      nil
    end
  end
end


end
