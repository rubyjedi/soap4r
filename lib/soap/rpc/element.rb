=begin
SOAP4R - RPC element definition.
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


require 'soap/baseData'


module SOAP

# Add method definitions for RPC to common definition in element.rb
class SOAPBody < SOAPStruct
  public

  def request
    rootNode
  end

  def response
    if !@isFault
      if void?
        nil
      else
        # Initial element is [retVal].
        rootNode[0]
      end
    else
      rootNode
    end
  end

  def outParams
    if !@isFault and !void?
      op = rootNode[1..-1]
      op = nil if op && op.empty?
      op
    else
      nil
    end
  end

  def void?
    rootNode.nil? # || rootNode.is_a?(SOAPNil)
  end

  def fault
    if @isFault
      self['fault']
    else
      nil
    end
  end

  def setFault(faultData)
    @isFault = true
    addMember('fault', faultData)
  end
end


module RPC


class RPCError < Error; end
class MethodDefinitionError < RPCError; end
class ParameterError < RPCError; end

class SOAPMethod < SOAPStruct
  RETVAL = 'retval'
  IN = 'in'
  OUT = 'out'
  INOUT = 'inout'

  attr_reader :paramDef
  attr_reader :inParam
  attr_reader :outParam

  def initialize(qname, paramDef = nil)
    super(nil)
    @elementName = qname
    @encodingStyle = nil

    @paramDef = paramDef

    @paramSignature = []
    @inParamNames = []
    @inoutParamNames = []
    @outParamNames = []

    @inParam = {}
    @outParam = {}
    @retName = nil

    setParamDef if @paramDef
  end

  def outParam?
    @outParamNames.size > 0
  end

  def eachParamName(*type)
    @paramSignature.each do |ioType, name, paramType|
      if type.include?(ioType)
        yield(name)
      end
    end
  end

  def setParams(params)
    params.each do |param, data|
      @inParam[param] = data
      data.elementName.name = param
    end
  end

  def setOutParams(params)
    params.each do |param, data|
      @outParam[param] = data
      data.elementName.name = param
    end
  end

# Defined in derived class.
#    def each
#      eachParamName(IN, INOUT) do |name|
#       unless @inParam[name]
#         raise ParameterError.new("Parameter: #{ name } was not given.")
#       end
#       yield(name, @inParam[name])
#      end
#    end

  def SOAPMethod.createParamDef(paramNames)
    paramDef = []
    paramNames.each do |paramName|
      paramDef.push([IN, paramName, nil])
    end
    paramDef.push([RETVAL, 'return', nil])
    paramDef
  end

  def SOAPMethod.getParamNames(paramDef)
    paramDef.collect { |ioType, name, type| name }
  end

private

  def setParamDef
    @paramDef.each do |ioType, name, paramType|
      case ioType
      when IN
        @paramSignature.push([IN, name, paramType])
        @inParamNames.push(name)
      when OUT
        @paramSignature.push([OUT, name, paramType])
        @outParamNames.push(name)
      when INOUT
        @paramSignature.push([INOUT, name, paramType])
        @inoutParamNames.push(name)
      when RETVAL
        if (@retName)
          raise MethodDefinitionError.new('Duplicated retval')
        end
        @retName = name
      else
        raise MethodDefinitionError.new("Unknown type: #{ ioType }")
      end
    end
  end
end


class SOAPMethodRequest < SOAPMethod
  attr_accessor :soapAction

  def SOAPMethodRequest.createRequest(qname, *params)
    paramDef = []
    paramValue = []
    i = 0
    params.each do |param|
      paramName = "p#{ i }"
      i += 1
      paramDef << [IN, nil, paramName]
      paramValue << [paramName, param]
    end
    paramDef << [RETVAL, nil, 'return']
    o = new(qname, paramDef)
    o.setParams(paramValue)
    o
  end

  def initialize(qname, paramDef = nil, soapAction = nil)
    checkElementName(qname)
    super(qname, paramDef)
    @soapAction = soapAction
  end

  def checkElementName(qname)
    # NCName & ruby's method name
    unless /\A[\w_][\w\d_\-]*\z/ =~ qname.name
      raise MethodDefinitionError.new("Element name '#{qname.name}' not allowed")
    end
  end

  def each
    eachParamName(IN, INOUT) do |name|
      unless @inParam[name]
        raise ParameterError.new("Parameter: #{ name } was not given.")
      end
      yield(name, @inParam[name])
    end
  end

  def dup
    req = self.class.new(@elementName.dup, @paramDef, @soapAction)
    req.encodingStyle = @encodingStyle
    req
  end

  def createMethodResponse
    SOAPMethodResponse.new(
      XSD::QName.new(@elementName.namespace, @elementName.name + 'Response'),
      @paramDef)
  end
end


class SOAPMethodResponse < SOAPMethod

  def initialize(qname, paramDef = nil)
    super(qname, paramDef)
    @retVal = nil
  end

  def setRetVal(retVal)
    @retVal = retVal
    @retVal.elementName.name = 'return'
  end

  def each
    if @retName and !@retVal.is_a?(SOAPVoid)
      yield(@retName, @retVal)
    end

    eachParamName(OUT, INOUT) do |paramName|
      unless @outParam[paramName]
        raise ParameterError.new("Parameter: #{ paramName } was not given.")
      end
      yield(paramName, @outParam[paramName])
    end
  end
end


# To return(?) void explicitly.
#  def foo(inputVar)
#    ...
#    return SOAP::RPC::SOAPVoid.new
#  end
class SOAPVoid < XSDAnySimpleType
  include SOAPBasetype
  extend SOAPModuleUtils
  Name = XSD::QName.new(RubyCustomTypeNamespace, nil)

public
  def initialize()
    @elementName = Name
    @id = nil
    @precedents = []
    @parent = nil
  end
end


end
end
