=begin
SOAP4R - RPC Routing library
Copyright (C) 2001, 2002 NAKAMURA Hiroshi.

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


module SOAP


class RPCRouter
  include SOAP
  include RPCUtils

  class RPCRoutingError < Error; end

  attr_reader :actor
  attr_accessor :allowUnqualifiedElement, :defaultEncodingStyle
  attr_accessor :mappingRegistry

  def initialize( actor )
    @actor = actor
    @receiver = {}
    @methodName = {}
    @method = {}
    @allowUnqualifiedElement = false
    @defaultEncodingStyle = nil
    @mappingRegistry = nil
  end

  # Method definition.
  def addMethod( namespace, receiver, methodName, paramDef, soapAction = nil )
    addMethodAs( namespace, receiver, methodName, methodName, paramDef,
      soapAction )
  end

  def addMethodAs( namespace, receiver, methodName, methodNameAs, paramDef,
      soapAction = nil )
    name = fqName( namespace, methodNameAs )
    @receiver[ name ] = receiver
    @methodName[ name ] = methodName
    @method[ name ] = SOAPMethodRequest.new( namespace, methodNameAs, paramDef,
      soapAction )
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
      header, body = Processor.unmarshal( soapString, getOpt )

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
    responseString = Processor.marshal( header, body, getOpt )

    return responseString, isFault
  end

  # Create fault response string.
  def createFaultResponseString( e )
    soapResponse = fault( e )

    header = SOAPHeader.new
    body = SOAPBody.new( soapResponse )
    responseString = Processor.marshal( header, body, getOpt )

    responseString
  end

private

  # Create new response.
  def createResponse( namespace, methodName, result )
    name = fqName( namespace, methodName )
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
      RPCUtils.obj2soap( detail, @mappingRegistry ))
  end

  # Dispatch to defined method.
  def dispatch( soapMethod )
    namespace = soapMethod.elementName.namespace
    methodName = soapMethod.elementName.name

    requestStruct = RPCUtils.soap2obj( soapMethod, @mappingRegistry )
    values = soapMethod.collect { | key, value | requestStruct[ key ] }
    method = lookup( namespace, methodName, values )
    unless method
      raise RPCRoutingError.new(
	"Method: #{ soapMethod.elementName } not supported." )
    end

    result = method.call( *values )
    createResponse( namespace, methodName, result )
  end

  # Method lookup
  def lookup( namespace, methodName, values )
    name = fqName( namespace, methodName )
    # It may be necessary to check all part of method signature...
    if @method.member?( name )
      @receiver[ name ].method( @methodName[ name ].intern )
    else
      nil
    end
  end

  def fqName( namespace, methodName )
    "#{ namespace }:#{ methodName }"
  end

  def getOpt
    opt = {}
    if @defaultEncodingStyle
      opt[ 'defaultEncodingStyle' ] = @defaultEncodingStyle
    end
    if @allowUnqualifiedElement
      opt[ 'allowUnqualifiedElement' ] = true
    end
    opt
  end
end


end
