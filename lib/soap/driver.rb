=begin
SOAP4R - SOAP driver
Copyright (C) 2000, 2001, 2003 NAKAMURA Hiroshi.

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

require 'soap/proxy'
require 'soap/rpcUtils'
require 'soap/streamHandler'
require 'soap/charset'

require 'devel/logger'
Log = Devel::Logger	# for backward compatibility of Devel::Logger.


module SOAP


class Driver
  include Devel::Logger::Severity
  include RPCUtils

public
  class EmptyResponseError < Error; end

  attr_accessor :logDev
  attr_accessor :mappingRegistry
  attr_reader :opt
  attr_reader :endPointUrl
  attr_reader :wireDumpDev
  attr_reader :wireDumpFileBase
  attr_reader :httpProxy

  def initialize( log, logId, namespace, endpointUrl, httpProxy = nil, soapAction = nil )
    @logDev = log
    @logId = logId
    @logIdPrefix = "<#{ @logId }> "
    log( SEV_INFO ) { 'initialize: initializing SOAP driver...' }
    @namespace = namespace
    @endpointUrl = endpointUrl
    @mappingRegistry = nil	# for unmarshal
    @wireDumpDev = nil
    @dumpFileBase = nil
    @httpProxy = ENV[ 'http_proxy' ] || ENV[ 'HTTP_PROXY' ]
    @handler = HTTPPostStreamHandler.new( @endpointUrl, @httpProxy,
      Charset.getEncodingLabel )
    @proxy = SOAPProxy.new( @namespace, @handler, soapAction )
    @proxy.allowUnqualifiedElement = true
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


  ###
  ## Method definition interfaces.
  #
  # paramArg: [ [ paramDef... ] ] or [ paramName, paramName, ... ]
  # paramDef: See proxy.rb.  Sorry.

  def addMethod( name, *paramArg )
    addMethodWithSOAPActionAs( name, name, nil, *paramArg )
  end

  def addMethodAs( nameAs, name, *paramArg )
    addMethodWithSOAPActionAs( nameAs, name, nil, *paramArg )
  end

  def addMethodWithSOAPAction( name, soapAction, *paramArg )
    addMethodWithSOAPActionAs( name, name, soapAction, *paramArg )
  end

  def addMethodWithSOAPActionAs( nameAs, name, soapAction, *paramArg )
    paramDef = if paramArg.size == 1 and paramArg[ 0 ].is_a?( Array )
	paramArg[ 0 ]
      else
	SOAPMethod.createParamDef( paramArg )
      end
    @proxy.addMethodAs( nameAs, name, paramDef, soapAction )
    addMethodInterface( name, paramDef )
  end


  ###
  ## Encoding style inteface.
  #
  def setDefaultEncodingStyle( encodingStyle )
    @proxy.defaultEncodingStyle = encodingStyle
  end

  def getDefaultEncodingStyle
    @proxy.defaultEncodingStyle
  end


  ###
  ## Driving interface.
  #
#  def method_missing( msg_id, *params )
#    log( SEV_INFO ) { "method_missing: invoked '#{ msg_id.id2name }'." }
#    call( msg_id.id2name, *params )
#  end

  def invoke( reqHeaders, reqBody )
    log( SEV_INFO ) { "invoke: invoking message '#{ reqBody.type }'." }

    if @dumpFileBase
      @handler.dumpFileBase = @dumpFileBase + '_' << reqBody.elementName.name
    end

    data = @proxy.invoke( reqHeaders, reqBody )
    return data
  end

  def call( methodName, *params )
    log( SEV_INFO ) { "call: calling method '#{ methodName }'." }
    log( SEV_DEBUG ) { "call: parameters '#{ params.inspect }'." }

    # Convert parameters: params array => SOAPArray => members array
    params = RPCUtils.obj2soap( params, @mappingRegistry ).to_a
    log( SEV_DEBUG ) { "call: parameters '#{ params.inspect }'." }

    # Set dumpDev if needed.
    if @dumpFileBase
      @handler.dumpFileBase = @dumpFileBase + '_' << methodName
    end

    # Then, call @proxy.call like the following.
    header, body = @proxy.call( nil, methodName, *params )
    unless body
      raise EmptyResponseError.new( "Empty response." )
    end

    log( SEV_INFO ) { "call: checking SOAP-Fault..." }
    begin
      @proxy.checkFault( body )
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

private

  def addMethodInterface( name, paramDef )
    paramNames = []
    @proxy.method[ name ].eachParamName( RPCUtils::SOAPMethod::IN, RPCUtils::SOAPMethod::INOUT ) do | paramName |
      paramNames << paramName
    end
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
    @logDev.add( sev, nil, self.class ) { @logIdPrefix + yield } if @logDev
  end
end


end
