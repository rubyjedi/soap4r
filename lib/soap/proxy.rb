=begin
SOAP4R - Proxy library.
Copyright (C) 2000 NAKAMURA Hiroshi.

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
require 'soap/streamHandler'
#require 'soap/streamHandler_wo_http-access'
require 'soap/rpcUtils'

class SOAPProxy
  include SOAPProcessor
  include SOAPRPCUtils

  public

  attr_reader :namespace
  attr_accessor :allowUnqualifiedElement

  def initialize( namespace, streamHandler )
    @namespace = namespace
    @handler = streamHandler
    @method = {}
    @allowUnqualifiedElement = false
  end

  class Request
    include SOAPRPCUtils

    public

    attr_reader :method
    attr_reader :namespace
    attr_reader :name

    def initialize( modelMethod, values )
      @method = SOAPMethod.new( modelMethod.namespace, modelMethod.name,
	modelMethod.paramDef )
      @namespace = @method.namespace
      @name = @method.name

      params = {}
    
      if (( values.size == 1 ) and ( values[0].is_a?( Hash )))
	params = values[ 0 ]
      else
	0.upto( values.size - 1 ) do | i |
	  params[ @method.paramNames[ i ]] = values[ i ] || SOAPNull.new()
	end
      end
      @method.setParams( params )
    end
  end

  # Method definition.
  def addMethod( methodName, paramDef )
    @method[ methodName ] = SOAPMethod.new( @namespace, methodName, paramDef )
  end

  # Create new request.
  def createRequest( methodName, *values )
    if ( @method.has_key?( methodName ))
      method = @method[ methodName ]
    else
      raise SOAP::MethodDefinitionError.new( 'Method: ' << methodName << ' not defined.' )
    end

    Request.new( method, values )
  end

  # Method calling.
  def call( ns, headers, methodName, *values )

    # Create new request
    req = createRequest( methodName, *values )

    # SOAP tree construction.
    tree = createTree( ns, headers, req )

    # Send request.
    receiveString = sendRequest( req, tree )

    # SOAP tree parsing.
    opt = {}
    opt[ 'allowUnqualifiedElement' ] = true if @allowUnqualifiedElement
    ns, header, body = unmarshal( receiveString, opt )

    # Used namespaces, header element, and body element.
    return ns, header, body
  end

  # SOAP tree construction.
  def createTree( ns, headers, request )
    # Preparing headers.
    header = SOAPHeader.new()
    if headers
      headers.each do | namespace, elem, content, mustUnderstand, encodingStyle |
        header.add( SOAPHeaderItem.new( namespace, elem, content, mustUnderstand, encodingStyle ))
      end
    end

    # Preparing body.
    body = SOAPBody.new( request.method )

    # Tree construction.
    soapTree = marshal( ns, header, body )

    return soapTree
  end

  # Send the request.
  def sendRequest( request, tree )
    # Serialize.
    sendString = tree.to_s

    # Send request.
    receiveString = @handler.send( sendString )

    receiveString
  end

  # SOAP Fault checking.
  def checkFault( ns, body )
    if ( body.fault )
      raise SOAP::FaultError.new( body.fault )
    end
  end
end
