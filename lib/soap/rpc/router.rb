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
module RPC


class Router
  include SOAP

  attr_reader :actor
  attr_accessor :allowUnqualifiedElement, :defaultEncodingStyle
  attr_accessor :mappingRegistry

  def initialize(actor)
    @actor = actor
    @receiver = {}
    @methodName = {}
    @method = {}
    @allowUnqualifiedElement = false
    @defaultEncodingStyle = nil
    @mappingRegistry = nil
  end

  def addMethod(receiver, qname, soapAction, methodName, paramDef)
    name = fqName(qname)
    @receiver[name] = receiver
    @methodName[name] = methodName
    @method[name] = RPC::SOAPMethodRequest.new(qname, paramDef, soapAction)
  end

  def addHeaderHandler
    raise NotImplementedError.new
  end

  # Routing...
  def route(soapString, charset = nil)
    opt = getOpt
    opt[:charset] = charset
    isFault = false
    begin
      header, body = Processor.unmarshal(soapString, opt)
      # So far, header is omitted...
      soapRequest = body.request
      unless soapRequest.is_a?(SOAPStruct)
	raise RPCRoutingError.new("Not an RPC style.")
      end
      soapResponse = dispatch(soapRequest)
    rescue Exception
      soapResponse = fault($!)
      isFault = true
    end

    header = SOAPHeader.new
    body = SOAPBody.new(soapResponse)
    responseString = Processor.marshal(header, body, opt)

    return responseString, isFault
  end

  # Create fault response string.
  def createFaultResponseString(e, charset = nil)
    opt = getOpt
    opt[:charset] = charset
    soapResponse = fault(e)

    header = SOAPHeader.new
    body = SOAPBody.new(soapResponse)
    responseString = Processor.marshal(header, body, opt)

    responseString
  end

private

  # Create new response.
  def createResponse(qname, result)
    name = fqName(qname)
    if (@method.has_key?(name))
      method = @method[name]
    else
      raise RPCRoutingError.new("Method: #{ name } not defined.")
    end

    soapResponse = method.createMethodResponse
    if soapResponse.outParam?
      unless result.is_a?(Array)
	raise RPCRoutingError.new("Out parameter was not returned.")
      end
      outParams = {}
      i = 1
      soapResponse.eachParamName('out', 'inout') do |outParam|
	outParams[outParam] = RPC.obj2soap(result[i], @mappingRegistry)
	i += 1
      end
      soapResponse.setOutParams(outParams)
      soapResponse.setRetVal(RPC.obj2soap(result[0], @mappingRegistry))
    else
      soapResponse.setRetVal(RPC.obj2soap(result, @mappingRegistry))
    end
    soapResponse
  end

  # Create fault response.
  def fault(e)
    detail = Mapping::SOAPException.new(e)
    SOAPFault.new(
      SOAPString.new('Server'),
      SOAPString.new(e.to_s),
      SOAPString.new(@actor),
      RPC.obj2soap(detail, @mappingRegistry))
  end

  # Dispatch to defined method.
  def dispatch(soapMethod)
    requestStruct = RPC.soap2obj(soapMethod, @mappingRegistry)
    values = soapMethod.collect { |key, value| requestStruct[key] }
    method = lookup(soapMethod.elementName, values)
    unless method
      raise RPCRoutingError.new(
	"Method: #{ soapMethod.elementName } not supported.")
    end

    result = method.call(*values)
    createResponse(soapMethod.elementName, result)
  end

  # Method lookup
  def lookup(qname, values)
    name = fqName(qname)
    # It may be necessary to check all part of method signature...
    if @method.member?(name)
      @receiver[name].method(@methodName[name].intern)
    else
      nil
    end
  end

  def fqName(qname)
    "#{ qname.namespace }:#{ qname.name }"
  end

  def getOpt
    opt = {}
    opt[:defaultEncodingStyle] = @defaultEncodingStyle
    if @allowUnqualifiedElement
      opt[:allowUnqualifiedElement] = true
    end
    opt
  end
end


end
end
