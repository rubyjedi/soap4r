=begin
SOAP4R - SOAP RPC driver
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


module SOAP
module RPC


class Driver
public
  class EmptyResponseError < Error; end

  attr_accessor :mappingRegistry
  attr_reader :endPointUrl
  attr_reader :wireDumpDev
  attr_reader :wireDumpFileBase
  attr_reader :httpProxy
  attr_reader :defaultEncodingStyle

  def initialize(endpointUrl, namespace, soapAction = nil)
    @endpointUrl = endpointUrl
    @namespace = namespace
    @mappingRegistry = nil      # for unmarshal
    @wireDumpDev = nil
    @dumpFileBase = nil
    @httpProxy = ENV['http_proxy'] || ENV['HTTP_PROXY']
    @handler = HTTPPostStreamHandler.new(@endpointUrl, @httpProxy,
      Charset.getEncodingLabel)
    @proxy = Proxy.new(@handler, soapAction)
    @proxy.allowUnqualifiedElement = true
  end

  def setEndpointUrl(endpointUrl)
    @endpointUrl = endpointUrl
    if @handler
      @handler.endpointUrl = @endpointUrl
      @handler.reset
    end
  end

  def setWireDumpDev(dumpDev)
    @wireDumpDev = dumpDev
    if @handler
      @handler.dumpDev = @wireDumpDev
      @handler.reset
    end
  end

  def setWireDumpFileBase(base)
    @dumpFileBase = base
  end

  def setHttpProxy(httpProxy)
    @httpProxy = httpProxy
    if @handler
      @handler.proxy = @httpProxy
      @handler.reset
    end
  end

  def setDefaultEncodingStyle(encodingStyle)
    @proxy.defaultEncodingStyle = encodingStyle
  end


  ###
  ## Method definition interfaces.
  #
  # paramArg: [[paramDef...]] or [paramName, paramName, ...]
  # paramDef: See proxy.rb.  Sorry.

  def addMethod(name, *paramArg)
    addMethodWithSOAPActionAs(name, name, nil, *paramArg)
  end

  def addMethodAs(methodName, elementName, *paramArg)
    addMethodWithSOAPActionAs(methodName, elementName, nil, *paramArg)
  end

  def addMethodWithSOAPAction(name, soapAction, *paramArg)
    addMethodWithSOAPActionAs(name, name, soapAction, *paramArg)
  end

  def addMethodWithSOAPActionAs(methodName, elementName, soapAction, *paramArg)
    paramDef = if paramArg.size == 1 and paramArg[0].is_a?(Array)
        paramArg[0]
      else
        SOAPMethod.createParamDef(paramArg)
      end
    qname = XSD::QName.new(@namespace, elementName)
    @proxy.addMethod(qname, soapAction, methodName, paramDef)
    addMethodInterface(methodName, paramDef)
  end


  ###
  ## Driving interface.
  #
  def invoke(reqHeaders, reqBody)
    if @dumpFileBase
      @handler.dumpFileBase = @dumpFileBase + '_' << reqBody.elementName.name
    end

    data = @proxy.invoke(reqHeaders, reqBody)
    return data
  end

  def call(methodName, *params)
    # Convert parameters: params array => SOAPArray => members array
    params = RPC.obj2soap(params, @mappingRegistry).to_a
    # Set dumpDev if needed.
    if @dumpFileBase
      @handler.dumpFileBase = @dumpFileBase + '_' << methodName
    end

    # Then, call @proxy.call like the following.
    header, body = @proxy.call(nil, methodName, *params)
    unless body
      raise EmptyResponseError.new("Empty response.")
    end

    begin
      @proxy.checkFault(body)
    rescue SOAP::FaultError => e
      RPC.fault2exception(e)
    end

    ret = body.response ?
      RPC.soap2obj(body.response, @mappingRegistry) : nil
    if body.outParams
      outParams = body.outParams.collect { |outParam|
        RPC.soap2obj(outParam)
      }
      return [ret].concat(outParams)
    else
      return ret
    end
  end

  def resetStream
    @handler.reset
  end

private

  def addMethodInterface(name, paramDef)
    paramNames = []
    i = 0
    @proxy.method[name].eachParamName(RPC::SOAPMethod::IN, RPC::SOAPMethod::INOUT) do |paramName|
      i += 1
      paramNames << "arg#{ i }"
    end
    callParamStr = if paramNames.empty?
        ""
      else
        ", " << paramNames.join(", ")
      end
    self.instance_eval <<-EOS
      def #{ name }(#{ paramNames.join(", ") })
        call("#{ name }"#{ callParamStr })
      end
    EOS
  end
end


end
end
