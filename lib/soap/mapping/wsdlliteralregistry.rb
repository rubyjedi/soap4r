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

  def obj2ele(obj, name)
    if !@definedelements.nil? && ele = @definedelements[name]
      _obj2ele(obj, ele)
    elsif !@definedtypes.nil? && type = @definedtypes[name]
      obj2type(obj, type)
    else
      unknownobj2ele(obj, name)
    end
  end

  def ele2obj(ele, *arg)
    raise RuntimeError.new("#{ self } is for obj2ele only.")
  end

private

  def _obj2ele(obj, ele)
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
        o.add(_obj2ele(Mapping.find_attribute(obj, child_ele.name.name),
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
      o.add(_obj2ele(Mapping.find_attribute(obj, child_ele.name.name),
        child_ele))
    end
    o
  end

  def unknownobj2ele(obj, name)
    if obj.class.class_variables.include?("@@schema_element")
      o = SOAPElement.new(name)
      elements = obj.class.class_eval("@@schema_element")
      elements.each do |elename|
        o.add(obj2ele(Mapping.find_attribute(obj, elename), elename))
      end
      attributes = obj.class.class_eval("@@schema_attribute")
      attributes.each do |attrname|
        attr = Mapping.find_attribute(obj, "attr_" + attrname)
        o.extraattr[attrname] = attr
      end
      o
    else
      o = Mapping.obj2soap(obj)
      o.elename = name
      o
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
