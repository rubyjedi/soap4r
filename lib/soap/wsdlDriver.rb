=begin
SOAP4R - SOAP WSDL driver
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

  def initialize( wsdlFile, logDev = nil )
    @wsdlFile = wsdlFile
    @logDev = logDev
    @wsdl = WSDL::WSDLParser.createParser.parse( File.open( @wsdlFile ))
    @wsdlMappingRegistry = RPCUtils::WSDLMappingRegistry.new( @wsdl )
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
    drv.wsdlMappingRegistry = @wsdlMappingRegistry
    drv
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

  def initialize( wsdl, port, logDev, opt )
    @wsdl = wsdl
    @port = port
    @logDev = logDev
    @mappingRegistry = nil	# for unmarshal
    @wsdlMappingRegistry = nil	# for marshal
    @opt = opt.dup
    unless @opt.has_key? 'noEncodeType'
      @opt[ 'noEncodeType' ] = true
    end
    @opt[ 'decodeComplexTypes' ] = @wsdl.getComplexTypesWithMessages
    createHandler
    @operationMap = {}
    # Convert Map which key is QName, to aHash which key is String.
    @port.createInputOperationMap.each do | name, value |
      @operationMap[ name.name ] = value
      operation, parts, = value
      paramNames = parts.collect { | part | part.name }
      addMethodInterface( name.name, paramNames )
    end
  end

  def setWireDumpDev( dumpDev )
    @wireDumpDev = dumpDev
    @handler.dumpDev = @wireDumpDev if @handler
  end

  def setWireDumpFileBase( base )
    @dumpFileBase = base
    @handler.dumpFileBase = @dumpFileBase if @handler
  end

  def setHttpProxy( httpProxy )
    @httpProxy = httpProxy
    @handler.proxy = @httpProxy if @handler
  end

private

  def createHandler
    unless @port.soapAddress
      raise RuntimeError.new( "soap:address element not found in WSDL." )
    end
    endpointUrl = @port.soapAddress.location
    @handler = HTTPPostStreamHandler.new( endpointUrl )
    @handler.dumpDev = @wireDumpDev
    @handler.dumpFileBase = @dumpFileBase
    @handler.proxy = @httpProxy
  end

  def call( methodName, *params )
    log( SEV_INFO ) { "call: calling method '#{ methodName }'." }
    log( SEV_DEBUG ) { "call: parameters '#{ params.inspect }'." }

    name, parts, soapAction = @operationMap[ methodName ]
    method = SOAPStruct.new
    method.elementName = name
    for idx in 0 ... params.length
      method.add( parts[ idx ].name, RPCUtils.obj2soap( params[ idx ],
	@wsdlMappingRegistry, parts[ idx ].type ))
    end

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
      header, body = Processor.unmarshal( data.receiveString, @opt )
    ensure
      if kcodeAdjusted
        $KCODE = charsetStrBackup
      end
    end

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
    marshalledString = Processor.marshal( header, body, @opt )
    return marshalledString
  end

  def addMethodInterface( name, paramNames )
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
  end

  def log( sev )
    @logDev.add( sev, nil, self.type ) { yield } if @logDev
  end
end


end


