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
require 'soap/rpcUtils'


module SOAP


class SOAPProxy
  include SOAP
  include Processor
  include RPCUtils

  public

  attr_reader :namespace
  attr_accessor :soapAction, :allowUnqualifiedElement

  def initialize( namespace, streamHandler, soapAction = nil )
    @namespace = namespace
    @handler = streamHandler
    @soapAction = soapAction
    @method = {}
    @allowUnqualifiedElement = false
    initParser
  end

  class Request
    include RPCUtils

    public

    attr_reader :method
    attr_reader :namespace
    attr_reader :name

    def initialize( modelMethod, values )
      @method = SOAPMethod.new( modelMethod.namespace, modelMethod.name, modelMethod.paramDef, modelMethod.soapAction )
      @namespace = @method.namespace
      @name = @method.name

      params = {}
    
      if (( values.size == 1 ) and ( values[ 0 ].is_a?( Hash )))
	params = values[ 0 ]
      else
	i = 0
	@method.eachParamName( 'in', 'inout' ) do | paramName |
	  params[ paramName ] = values[ i ] || SOAPNil.new
	  i += 1
	end
      end
      @method.setParams( params )
    end
  end

  # Method definition.
  def addMethod( methodName, paramDef, soapAction = nil )
    @method[ methodName ] = SOAPMethod.new( @namespace, methodName, paramDef, soapAction )
  end

  # Create new request.
  def createRequest( methodName, *values )
    if ( @method.has_key?( methodName ))
      method = @method[ methodName ]
    else
      raise SOAP::RPCUtils::MethodDefinitionError.new( 'Method: ' << methodName << ' not defined.' )
    end

    Request.new( method, values )
  end

  # Method calling.
  def call( ns, headers, methodName, *values )

    # Create new request
    req = createRequest( methodName, *values )

    # Get sending string.
    sendString = marshalRequest( ns, headers, req )

    # Send request.
    receiveString, receiveCharset = sendRequest( req, sendString )

    # StreamHandler returns receiveCharset to use.
    if receiveCharset
      receiveString.sub!( /^([^>]*)\s+encoding=(['"])[^'"]*\2/ ) { $1 }

      # For NQXML Parser.
      if SOAP.const_defined?( "SOAPNQXMLLightWeightParser" )
	charsetStr = Charset.getCharsetStr( receiveCharset )
	charsetStrBackup = $KCODE.to_s.dup
	$KCODE = charsetStr
	Charset.setXMLInstanceEncoding( charsetStr )
      end
    end

    receiveString.gsub!( "\r\n", "\n" )
    receiveString.gsub!( "\r", "\n" )

    # SOAP tree parsing.
    header, body = unmarshal( receiveString )

    if receiveCharset
      # For NQXML Parser.
      if SOAP.const_defined?( "SOAPNQXMLLightWeightParser" )
       	$KCODE = charsetStrBackup
	Charset.setXMLInstanceEncoding( $KCODE )
      end
    end

    return header, body
  end

  # SOAP marshalling
  def marshalRequest( ns, headers, request )
    # Preparing headers.
    header = SOAPHeader.new()
    if headers
      headers.each do | namespace, elem, content, mustUnderstand, encodingStyle |
        header.add( SOAPHeaderItem.new( namespace, elem, content, mustUnderstand, encodingStyle ))
      end
    end

    # Preparing body.
    body = SOAPBody.new( request.method )

    # Marshal.
    marshalledString = marshal( ns, header, body )

    return marshalledString
  end

  # Send the request.
  def sendRequest( request, sendString )
    # Send request.
    @handler.send( sendString, request.method.soapAction || soapAction )
  end

  # SOAP Fault checking.
  def checkFault( body )
    if ( body.fault )
      raise SOAP::FaultError.new( body.fault )
    end
  end

private

  def initParser
    opt = {}
    opt[ 'allowUnqualifiedElement' ] = true if @allowUnqualifiedElement
    opt[ 'defaultEncodingStyleHandler' ] = EncodingStyleHandler.getHandler(
      SOAPEncodingStyleHandlerLiteral::LiteralEncodingNamespace )
    Processor.setDefaultParser( opt )
  end
end


end
