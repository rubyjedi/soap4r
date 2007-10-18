# WSDL4R - WSDL bound operation definition.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'


module WSDL


class OperationBinding < Info
  attr_reader :name		# required
  attr_reader :input
  attr_reader :output
  attr_reader :fault
  attr_reader :soapoperation

  class BoundId
    attr_reader :name
    attr_reader :soapaction

    def initialize(name, soapaction)
      @name = name
      @soapaction = soapaction
    end

    def ==(rhs)
      !rhs.nil? and @name == rhs.name and @soapaction == rhs.soapaction
    end

    def eql?(rhs)
      (self == rhs)
    end

    def hash
      @name.hash ^ @soapaction.hash
    end
  end

  def initialize
    super
    @name = nil
    @input = nil
    @output = nil
    @fault = []
    @soapoperation = nil
  end

  def targetnamespace
    parent.targetnamespace
  end

  def porttype
    root.porttype(parent.type)
  end

  def boundid
    BoundId.new(name, soapaction)
  end

  def find_operation
    porttype.operations.each do |op|
      next if op.name != @name
      next if op.input and @input and op.input.name and @input.name and
        op.input.name != @input.name
      next if op.output and @output and op.output.name and @output.name and
        op.output.name != @output.name
      return op
    end
    raise RuntimeError.new("#{@name} not found")
  end

  def soapoperation_name
    op_name = find_operation.operationname
    if @input and @input.soapbody and @input.soapbody.namespace
      op_name = XSD::QName.new(@input.soapbody.namespace, op_name.name)
    end
    op_name
  end

  def soapoperation_style
    style = nil
    if @soapoperation
      style = @soapoperation.operation_style
    elsif parent.soapbinding
      style = parent.soapbinding.style
    else
      raise TypeError.new("operation style definition not found")
    end
    style || :document
  end

  def soapbody_use_input
    soapbody_use(@input)
  end

  def soapbody_use_output
    soapbody_use(@output)
  end

  def soapaction
    if @soapoperation
      @soapoperation.soapaction
    else
      nil
    end
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
      @fault << o
      o
    when SOAPOperationName
      o = WSDL::SOAP::Operation.new
      @soapoperation = o
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
      @name = value.source
    else
      nil
    end
  end

private

  def soapbody_use(param)
    param ? param.soapbody_use : nil
  end
end


end
