=begin
WSDL4R - WSDL bound operation definition.
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


require 'wsdl/info'


module WSDL


class OperationBinding < Info
  attr_reader :name		# required
  attr_reader :input
  attr_reader :output
  attr_reader :fault
  attr_reader :soap_operation

  def initialize
    super
    @name = nil
    @input = nil
    @output = nil
    @fault = nil
    @soap_operation = nil
  end

  def targetnamespace
    parent.targetnamespace
  end

  def porttype
    root.porttype(parent.type)
  end

  def find_operation
    porttype.operations[@name]
  end

  def inputoperation_sig
    operation = find_operation
    soap_body = input.soap_body

    if soap_body.use != "encoded"
      raise NotImplementedError.new("Use '#{ soap_body.use }' not supported.")
    end
    if soap_body.encodingstyle != ::SOAP::EncodingNamespace
      raise NotImplementedError.new(
	"EncodingStyle '#{ soap_body.encodingstyle }' not supported.")
    end

    op_name = operation.name.dup
    op_name.namespace = soap_body.namespace if soap_body.namespace
    msg_name = operation.inputname
    param_names = operation.inputparts.collect { |part| part.name }
    soapaction = soap_operation.soapaction
    return op_name, msg_name, param_names, soapaction
  end

  def outputoperation_sig
    operation = find_operation
    soap_body = output.soap_body

    if soap_body.use != "encoded"
      raise NotImplementedError.new("Use '#{ soap_body.use }' not supported.")
    end
    if soap_body.encodingstyle != ::SOAP::EncodingNamespace
      raise NotImplementedError.new(
	"EncodingStyle '#{ soap_body.encodingstyle }' not supported.")
    end

    op_name = operation.name.dup
    op_name.namespace = soap_body.namespace if soap_body.namespace
    msg_name = operation.outputname
    param_names = operation.outputparts.collect { |part| part.name }
    return op_name, msg_name, param_names
  end

  def parse_element(element)
    case element
    when InputName
      o = Param.new
      @input = o
      o
    when OutputName
      o = Param.new
      @output = o
      o
    when FaultName
      o = Param.new
      @fault = o
      o
    when SOAPOperationName
      o = WSDL::SOAP::Operation.new
      @soap_operation = o
      o
    when DocumentationName
      o = Documentation.new
      o
    else
      nil
    end
  end

  def parse_attr(attr, value)
    case attr
    when NameAttrName
      @name = XSD::QName.new(targetnamespace, value)
    else
      raise WSDLParser::UnknownAttributeError.new("Unknown attr #{ attr }.")
    end
  end
end


end
