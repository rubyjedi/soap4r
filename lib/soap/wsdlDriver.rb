=begin
SOAP4R - SOAP WSDL driver
Copyright (C) 2002, 2003 NAKAMURA Hiroshi.

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


require 'wsdl/parser'
require 'soap/qname'
require 'soap/element'
require 'soap/baseData'
require 'soap/streamHandler'
require 'soap/rpcUtils'
require 'soap/mappingRegistry'
require 'soap/processor'
require 'devel/logger'


module SOAP


class WSDLDriverFactory
  attr_reader :wsdl

  def initialize( wsdl, logDev = nil )
    @logDev = logDev
    @wsdl = parse( wsdl )
  end

  def createDriver( serviceName = nil, portName = nil, opt = {} )
    service = if serviceName
	@wsdl.getService( XSD::QName.new( @wsdl.targetNamespace, serviceName ))
      else
	@wsdl.services[ 0 ]
      end
    if service.nil?
      raise RuntimeError.new( "Service #{ serviceName } not found in WSDL." )
    end
    port = if portName
	service.ports[ XSD::QName.new( @wsdl.targetNamespace, portName ) ]
      else
	service.ports[ 0 ]
      end
    if port.nil?
      raise RuntimeError.new( "Port #{ portName } not found in WSDL." )
    end
    drv = WSDLDriver.new( @wsdl, port, @logDev, opt )
    drv.wsdlMappingRegistry = RPCUtils::WSDLMappingRegistry.new( @wsdl,
      port.getPortType )
    drv
  end

private
  
  def parse( wsdl )
    str = nil
    if /^http/i =~ wsdl
      begin
	c = HTTPAccess2::Client.new(
	  ENV[ 'http_proxy' ] || ENV[ 'HTTP_PROXY' ] )
	str = c.getContent( wsdl )
      rescue
	str = nil
      end
    end
    if str.nil?
      str = File.open( wsdl )
    end
    WSDL::WSDLParser.createParser.parse( str )
  end
end


class WSDLDriver
  include Devel::Logger::Severity
  include SOAP

public
  attr_accessor :logDev
  attr_accessor :mappingRegistry
  attr_accessor :wsdlMappingRegistry
  attr_reader :opt
  attr_reader :endpointUrl
  attr_reader :wireDumpDev
  attr_reader :wireDumpFileBase
  attr_reader :httpProxy

  attr_accessor :defaultEncodingStyle
  attr_accessor :allowUnqualifiedElement
  attr_accessor :generateEncodeType

  def initialize( wsdl, port, logDev, opt )
    @wsdl = wsdl
    @port = port
    @logDev = logDev
    @mappingRegistry = nil	# for unmarshal
    @wsdlMappingRegistry = nil	# for marshal
    @endpointUrl = nil
    @wireDumpDev = nil
    @dumpFileBase = nil
    @httpProxy = ENV[ 'http_proxy' ] || ENV[ 'HTTP_PROXY' ]

    @opt = opt.dup
    @decodeComplexTypes = @wsdl.getComplexTypesWithMessages( port.getPortType )
    @defaultEncodingStyle = EncodingNamespace
    @allowUnqualifiedElement = true
    @generateEncodeType = false

    createHandler
    @operationMap = {}
    # Convert Map which key is QName, to aHash which key is String.
    @port.createInputOperationMap.each do | operationName, value |
      @operationMap[ operationName.name ] = value.dup.unshift( operationName )
      operation, paramNames, = value
      addMethodInterface( operationName.name, paramNames )
    end
  end

  def setEndpointUrl( endpointUrl )
    @endpointUrl = endpointUrl
    if @handler
      @handler.endpointUrl = @endpointUrl
      @handler.reset
    end
  end

  def setWireDumpDev( dumpDev )
    @wireDumpDev = dumpDev
    if @handler
      @handler.dumpDev = @wireDumpDev
      @handler.reset
    end
  end

  def setWireDumpFileBase( base )
    @dumpFileBase = base
  end

  def setHttpProxy( httpProxy )
    @httpProxy = httpProxy
    if @handler
      @handler.proxy = @httpProxy
      @handler.resetStream
    end
  end

  def resetStream
    @handler.reset
  end

private

  def createHandler
    unless @port.soapAddress
      raise RuntimeError.new( "soap:address element not found in WSDL." )
    end
    endpointUrl = @endpointUrl || @port.soapAddress.location
    @handler = HTTPPostStreamHandler.new( endpointUrl, @httpProxy,
      Charset.getEncodingLabel )
    @handler.dumpDev = @wireDumpDev
  end

  def createMethodObject( names, params )
    o = Object.new
    for idx in 0 ... params.length
      o.instance_eval( "@#{ names[ idx ] } = params[ idx ]" )
    end
    o
  end

  def call( methodName, *params )
    log( SEV_INFO ) { "call: calling method '#{ methodName }'." }
    log( SEV_DEBUG ) { "call: parameters '#{ params.inspect }'." }

    operationName, messageName, paramNames, soapAction =
      @operationMap[ methodName ]
    obj = createMethodObject( paramNames, params )
    method = RPCUtils.obj2soap( obj, @wsdlMappingRegistry, messageName )
    method.elementName = operationName
    method.type = XSD::QName.new	# Request should not be typed.

    if @dumpFileBase
      @handler.dumpFileBase = @dumpFileBase + '_' << methodName
    end

    begin
      header, body = invoke( nil, method, soapAction )
      unless body
	raise EmptyResponseError.new( "Empty response." )
      end
    rescue SOAP::FaultError => e
      RPCUtils.fault2exception( e )
    end

    ret = body.response ?
      RPCUtils.soap2obj( body.response, @mappingRegistry ) : nil

    if body.outParams
      outParams = body.outParams.collect { | outParam |
	RPCUtils.soap2obj( outParam )
      }
      return [ ret ].concat( outParams )
    else
      return ret
    end
  end

  def invoke( headers, body, soapAction )
    sendString = marshal( headers, body )
    data = @handler.send( sendString, soapAction )
    return nil, nil if data.receiveString.empty?

    # Received charset might be different from request.
    receiveCharset = StreamHandler.parseMediaType( data.receiveContentType )
    opt = getOpt
    opt[ :charset ] = receiveCharset

    header, body = Processor.unmarshal( data.receiveString, opt )
    if body.fault
      raise SOAP::FaultError.new( body.fault )
    end

    return header, body
  end

  def marshal( headers, body )
    header = SOAPHeader.new()
    if headers
      headers.each do | content, mustUnderstand, encodingStyle |
        header.add( SOAPHeaderItem.new( content, mustUnderstand,
          encodingStyle ))
      end
    end
    body = SOAPBody.new( body )
    marshalledString = Processor.marshal( header, body, getOpt )
    return marshalledString
  end

  def addMethodInterface( name, paramNames )
    i = 0
    paramNames = paramNames.collect { | paramName |
      i += 1
      "arg#{ i }"
    }
    callParamStr = if paramNames.empty?
	""
      else
	", " << paramNames.join( ", " )
      end
    self.instance_eval <<-EOS
      def #{ name }( #{ paramNames.join( ", " ) } )
	call( "#{ name }"#{ callParamStr } )
      end
    EOS
=begin
    To use default argument value.

    self.instance_eval <<-EOS
      def #{ name }( *arg )
	call( "#{ name }", *arg )
      end
    EOS
=end
  end

  def getOpt
    opt = @opt.dup
    opt[ :decodeComplexTypes ] = @decodeComplexTypes
    opt[ :defaultEncodingStyle ] = @defaultEncodingStyle
    opt[ :allowUnqualifiedElement ] = @allowUnqualifiedElement
    opt[ :generateEncodeType ] = @generateEncodeType
    opt
  end

  def log( sev )
    @logDev.add( sev, nil, self.type ) { yield } if @logDev
  end
end


end


