# SOAP4R - WSDL literal mapping registry.
# Copyright (C) 2004  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/baseData'
require 'soap/mapping/mapping'
require 'soap/mapping/typeMap'


module SOAP
module Mapping


class WSDLLiteralRegistry
  attr_reader :definedelements
  attr_reader :definedtypes

  def initialize(definedelements = nil, definedtypes = nil)
    @definedelements = definedelements
    @definedtypes = definedtypes
    @rubytype_factory = RubytypeFactory.new(
      :allow_original_mapping => false
    )
  end

  #def obj2ele(obj, name)
  def obj2soap(klass, obj, qname)
    if !@definedelements.nil? && ele = @definedelements[qname]
      _obj2soap(obj, ele)
    elsif !@definedtypes.nil? && type = @definedtypes[qname]
      obj2type(obj, type)
    else
      unknownobj2soap(obj, qname)
    end
  end

  def ele2obj(ele, *arg)
    raise RuntimeError.new("#{ self } is for obj2soap only.")
  end

  def soap2obj(klass, node)
    # assert(klass == ::SOAP::SOAPElement)
    obj = _soap2obj(klass, node)
    if @allow_original_mapping
      addextend2obj(obj, node.extraattr[RubyExtendName])
      addiv2obj(obj, node.extraattr[RubyIVarName])
    end
    obj
  end

private

  def _obj2soap(obj, ele)
    o = nil
    if ele.type
      if type = @definedtypes[ele.type]
        o = obj2type(obj, type)
      elsif type = TypeMap[ele.type]
        o = base2soap(obj, type)
      else
        raise MappingError.new("Cannot find type #{ele.type}.")
      end
      o.elename = ele.name
    elsif ele.local_complextype
      o = SOAPElement.new(ele.name)
      ele.local_complextype.each_element do |child_ele|
        o.add(_obj2soap(Mapping.find_attribute(obj, child_ele.name.name),
          child_ele))
      end
    else
      raise MappingError.new("Illegal schema?")
    end
    o
  end

  def obj2type(obj, type)
    if type.is_a?(::WSDL::XMLSchema::SimpleType)
      simple2soap(obj, type)
    else
      complex2soap(obj, type)
    end
  end

  def simple2soap(obj, type)
    o = base2soap(obj, TypeMap[type.base])
    if type.restriction.enumeration.empty?
      STDERR.puts(
        "#{type.name}: simpleType which is not enum type not supported.")
      return o
    end
    type.check_lexical_format(obj)
    o
  end

  def complex2soap(obj, type)
    o = SOAPElement.new(type.name)
    type.each_element do |child_ele|
      o.add(_obj2soap(Mapping.find_attribute(obj, child_ele.name.name),
        child_ele))
    end
    o
  end

  def unknownobj2soap(obj, name)
    if obj.class.class_variables.include?("@@schema_element")
      ele = SOAPElement.new(name)
      add_elements(obj, ele)
      add_attributes(obj, ele)
      ele
    else        # expected to be a basetype.
      o = Mapping.obj2soap(obj)
      o.elename = name
      o
    end
  end

  def add_elements(obj, ele)
    elements = obj.class.class_eval("@@schema_element")
    elements.each do |elename|
      child = Mapping.find_attribute(obj, elename)
      name = ::XSD::QName.new(nil, elename)
      if child.is_a?(::Array)
        child.each do |item|
          ele.add(obj2soap(nil, item, name))
        end
      else
        ele.add(obj2soap(nil, child, name))
      end
    end
  end
  
  def add_attributes(obj, ele)
    attributes = obj.class.class_eval("@@schema_attribute")
    attributes.each do |attrname|
      attr = Mapping.find_attribute(obj, "attr_" + attrname)
      ele.extraattr[attrname] = attr
    end
  end

  def _ele2obj(ele)
    raise NotImplementedError.new
  end

  def base2soap(obj, type)
    soap_obj = nil
    if type <= ::XSD::XSDString
      soap_obj = type.new(::XSD::Charset.is_ces(obj, $KCODE) ?
        ::XSD::Charset.encoding_conv(obj, $KCODE, ::XSD::Charset.encoding) :
        obj)
    else
      soap_obj = type.new(obj)
    end
    soap_obj
  end
end


end
end
