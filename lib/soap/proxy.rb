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
require 'soap/streamHandler'


module SOAP


class SOAPProxy
  include SOAP
  include RPCUtils

  public

  attr_reader :namespace
  attr_accessor :soapAction
  attr_accessor :allowUnqualifiedElement, :defaultEncodingStyle
  attr_reader :method

  def initialize( namespace, streamHandler, soapAction = nil )
    @namespace = namespace
    @handler = streamHandler
    @soapAction = soapAction
    @method = {}
    @allowUnqualifiedElement = false
    @defaultEncodingStyle = nil
  end

  class Request
    include RPCUtils

    public

    attr_reader :method
    attr_reader :namespace
    attr_reader :name

    def initialize( modelMethod, values )
      @method = modelMethod.dup
      @namespace = @method.elementName.namespace
      @name = @method.elementName.name

      params = {}
    
      if (( values.size == 1 ) and ( values[ 0 ].is_a?( Hash )))
	params = values[ 0 ]
      else
	i = 0
	@method.eachParamName( SOAPMethod::IN, SOAPMethod::INOUT ) do | paramName |
	  params[ paramName ] = values[ i ] || SOAPNil.new
	  i += 1
	end
      end
      @method.setParams( params )
    end
  end

  def addMethod( methodName, paramDef, soapAction = nil, namespace = nil )
    addMethodAs( methodName, methodName, paramDef, soapAction, namespace )
  end

  def addMethodAs( methodNameAs, methodName, paramDef, soapAction = nil,
      namespace = nil )
    @method[ methodName ] = SOAPMethodRequest.new( namespace || @namespace,
      methodNameAs, paramDef, soapAction )
  end

  def createRequest( methodName, *values )
    if ( @method.has_key?( methodName ))
      method = @method[ methodName ]
      method.encodingStyle = @defaultEncodingStyle if @defaultEncodingStyle
    else
      raise SOAP::RPCUtils::MethodDefinitionError.new( 'Method: ' <<
	methodName << ' not defined.' )
    end

    Request.new( method, values )
  end

  def invoke( headers, body, soapAction = nil )
    # Get sending string.
    sendString = marshal( headers, body )

    # Send request.
    data = @handler.send( sendString, soapAction )
    return data
  end

  def call( headers, methodName, *values )
    req = createRequest( methodName, *values )
    data = invoke( headers, req.method, req.method.soapAction || @soapAction )
    return nil, nil if data.receiveString.empty?

    receiveCharset = StreamHandler.parseMediaType( data.receiveContentType )
    kcodeAdjusted = false
    charsetStrBackup = nil
    if receiveCharset
      charsetStr = Charset.getCharsetStr( receiveCharset )
      Charset.setXMLInstanceEncoding( charsetStr )

      if SOAPParser.factory.adjustKCode
	charsetStrBackup = $KCODE.to_s.dup
	$KCODE = charsetStr
	kcodeAdjusted = true
      end
    end

    header = body = nil
    begin
      # SOAP tree parsing.
      header, body = Processor.unmarshal( data.receiveString, getOpt )
    ensure
      if kcodeAdjusted
       	$KCODE = charsetStrBackup
      end
    end

    return header, body
  end

  def marshal( headers, body )
    # Preparing headers.
    header = SOAPHeader.new()
    if headers
      headers.each do | content, mustUnderstand, encodingStyle |
        header.add( SOAPHeaderItem.new( content, mustUnderstand,
	  encodingStyle ))
      end
    end

    # Preparing body.
    body = SOAPBody.new( body )

    # Marshal.
    marshalledString = Processor.marshal( header, body, getOpt )

    return marshalledString
  end

  def checkFault( body )
    if ( body.fault )
      raise SOAP::FaultError.new( body.fault )
    end
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
