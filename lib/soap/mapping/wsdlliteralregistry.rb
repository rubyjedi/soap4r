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


class WSDLLiteralRegistry < Factory
  attr_reader :definedelements
  attr_reader :definedtypes
  attr_accessor :excn_handler_obj2soap
  attr_accessor :excn_handler_soap2obj

  def initialize(definedelements = nil, definedtypes = nil)
    @definedelements = definedelements
    @definedtypes = definedtypes
  end

  def obj2soap(obj, qname)
    ret = nil
    if !@definedelements.nil? && ele = @definedelements[qname]
      ret = _obj2soap(obj, ele)
    elsif !@definedtypes.nil? && type = @definedtypes[qname]
      ret = obj2type(obj, type)
    else
      ret = unknownobj2soap(obj, qname)
    end
    return ret if ret
    if @excn_handler_obj2soap
      ret = @excn_handler_obj2soap.call(obj) { |yield_obj|
        Mapping._obj2soap(yield_obj, self)
      }
      return ret if ret
    end
    raise MappingError.new("Cannot map #{ obj.class.name } to SOAP/OM.")
  end

  # node should be a SOAPElement
  def soap2obj(node)
    typestr = Mapping.elename2name(node.elename.name)
    klass = Mapping.class_from_name(typestr)
    begin
      return soapele2obj(node, klass)
    rescue MappingError
    end
    if @excn_handler_soap2obj
      begin
        return @excn_handler_soap2obj.call(node) { |yield_node|
	    Mapping._soap2obj(yield_node, self)
	  }
      rescue Exception
      end
    end
    raise MappingError.new("Cannot map #{ node.type.name } to Ruby object.")
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
      raise MappingError.new('Illegal schema?')
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
    if obj.class.class_variables.include?('@@schema_element')
      ele = SOAPElement.new(name)
      add_elements2soap(obj, ele)
      add_attributes2soap(obj, ele)
      ele
    else        # expected to be a basetype.
      o = Mapping.obj2soap(obj)
      o.elename = name
      o
    end
  end

  def add_elements2soap(obj, ele)
    elements = obj.class.class_eval('@@schema_element')
    elements.each do |elename, type|
      child = Mapping.find_attribute(obj, elename)
      name = ::XSD::QName.new(nil, elename)
      if child.is_a?(::Array)
        child.each do |item|
          ele.add(obj2soap(item, name))
        end
      else
        ele.add(obj2soap(child, name))
      end
    end
  end
  
  def add_attributes2soap(obj, ele)
    attributes = obj.class.class_eval('@@schema_attribute')
    attributes.each do |attrname, param|
      attr = Mapping.find_attribute(obj, 'attr_' + attrname)
      ele.extraattr[attrname] = attr
    end
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

  def soapele2obj(node, obj_class)
    obj = create_empty_object(obj_class)
    mark_unmarshalled_obj(node, obj)
    if obj_class.class_variables.include?('@@schema_element')
      add_elements2obj(node, obj)
      add_attributes2obj(node, obj)
    else
      vars = {}
      node.each do |name, value|
        vars[Mapping.elename2name(name)] = Mapping._soap2obj(value, self)
      end
      Mapping.set_instance_vars(obj, vars)
    end
    obj
  end

  def add_elements2obj(node, obj)
    elements = {}
    as_array = []
    obj.class.class_eval('@@schema_element').each do |name, class_name|
      if class_name and class_name.sub!(/\[\]$/, '')
        as_array << class_name
      end
      elements[name] = class_name
    end
    vars = {}
    node.each do |name, value|
      class_name = elements[name]
      klass = Mapping.class_from_name(class_name)
      if klass and klass.ancestors.include?(::SOAP::SOAPBasetype)
        child = klass.new(value.data).data
      else
        child = soapele2obj(value, klass)
      end
      if as_array.include?(class_name)
        (vars[name] ||= []) << child
      else
        vars[name] = child
      end
    end
    Mapping.set_instance_vars(obj, vars)
  end

  def add_attributes2obj(node, obj)
    Mapping.set_instance_vars(obj, {'__soap_attribute' => {}})
    vars = {}
    attributes = obj.class.class_eval('@@schema_attribute')
    attributes.each do |attrname, class_name|
      attr = node.extraattr[::XSD::QName.new(nil, attrname)]
      next if attr.nil? or attr.empty?
      klass = Mapping.class_from_name(class_name)
      if klass.ancestors.include?(::SOAP::SOAPBasetype)
        child = klass.new(attr).data
      else
        child = attr
      end
      vars['attr_' + attrname] = child
    end
    Mapping.set_instance_vars(obj, vars)
  end
end


end
end
