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


class SOAPRPCRouter
  include SOAPProcessor
  include SOAPRPCUtils

  class RPCRoutingError < Error; end

  attr_reader :namespace, :actor

  def initialize( namespace, actor )
    @namespace = namespace
    @actor = actor
    @receiver = {}
    @method = {}
  end

  # Method definition.
  def addMethod( receiver, methodName, paramDef = nil )
    @receiver[ methodName ] = receiver
    @method[ methodName ] = SOAPMethod.new( @namespace, methodName, paramDef )
  end

  def addHeaderHandler
    raise NotImplementedError.new
  end

  # Routing...
  def route( soapString )
    ns, header, body = unmarshal( soapString )

    # So far, header is omitted...

    soapRequest = body.data
    soapResponse = nil

    begin
      soapResponse = dispatch( soapRequest )
    rescue Exception
      soapResponse = fault( $! )
    end

    ns = SOAPNS.new
    header = SOAPHeader.new
    body = SOAPBody.new( soapResponse )
    responseTree = marshal( ns, header, body )
    responseString = responseTree.to_s
  end

  # Create fault response.
  def fault( e )
    detail = SOAPArray.new
    e.backtrace.each do |stack|
      detail.add( SOAPString.new( stack ))
    end
    SOAPFault.new( SOAPString.new( 'Server' ), SOAPString.new( e.to_s ),
      SOAPString.new( @actor ), detail )
  end

private

  # Create new response.
  def createResponse( methodName, *values )
    if ( @method.has_key?( methodName ))
      method = @method[ methodName ]
    else
      raise RPCRoutingError.new( "Method: #{ methodName } not defined." )
    end

    retVal = values[ 0 ]
    if values.length > 1
      raise RPCRoutingError.new( "[out] parameter not supported." )
    end

    soapResponse = method.dup
    soapResponse.retVal = obj2soap( retVal )
    soapResponse
  end

  # Dispatch to defined method.
  def dispatch( soapMethod )
    methodName = soapMethod.typeName
    requestStruct = soap2obj( soapMethod )
    values = requestStruct.members.collect { |member|
      requestStruct[ member ]
    }
    method = lookup( methodName, values )
    unless method
      raise Error.new( "Method: #{methodName} not supported." )
    end

    result = method.call( *values )
    createResponse( methodName, result )
  end

  # Method lookup
  def lookup( name, values )
    # It may be necessary to check all part of method signature...
    if @method.member?( name )
      @receiver[ name ].method( @method[ name ].name.intern )
    else
      nil
    end
  end
end
