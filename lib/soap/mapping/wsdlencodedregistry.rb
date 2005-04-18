# SOAP4R - WSDL encoded mapping registry.
# Copyright (C) 2000-2003, 2005  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/baseData'
require 'soap/mapping/mapping'
require 'soap/mapping/typeMap'


module SOAP
module Mapping


class WSDLEncodedRegistry
  include TraverseSupport

  attr_reader :definedelements
  attr_reader :definedtypes
  attr_accessor :excn_handler_obj2soap
  attr_accessor :excn_handler_soap2obj

  def initialize(definedtypes = XSD::NamedElements::Empty)
    @definedtypes = definedtypes
    # @definedelements = definedelements  needed?
    @excn_handler_obj2soap = nil
    @excn_handler_soap2obj = nil
    # For mapping AnyType element.
    @rubytype_factory = RubytypeFactory.new(
      :allow_untyped_struct => true,
      :allow_original_mapping => true
    )
  end

  def obj2soap(obj, type_qname = nil)
    soap_obj = nil
    if type = @definedtypes[type_qname]
      soap_obj = obj2type(obj, type)
    elsif obj.nil?
      soap_obj = SOAPNil.new
    elsif type_qname.nil? or type_qname == XSD::AnyTypeName
      soap_obj = @rubytype_factory.obj2soap(nil, obj, nil, self)
    elsif obj.is_a?(XSD::NSDBase)
      soap_obj = soap2soap(obj, type_qname)
    elsif (type = TypeMap[type_qname])
      soap_obj = base2soap(obj, type)
    end
    return soap_obj if soap_obj
    if @excn_handler_obj2soap
      soap_obj = @excn_handler_obj2soap.call(obj) { |yield_obj|
        Mapping._obj2soap(yield_obj, self)
      }
      return soap_obj if soap_obj
    end
    if type_qname
      raise MappingError.new("cannot map #{obj.class.name} as #{type_qname}")
    else
      raise MappingError.new("cannot map #{obj.class.name} to SOAP/OM")
    end
  end

  # map anything for now: must refer WSDL while mapping.  [ToDo]
  def soap2obj(node, obj_class = nil)
    begin
      return Mapping.soap2obj(node)
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
    raise MappingError.new("cannot map #{node.type.name} to Ruby object")
  end

private

  def soap2soap(obj, type_qname)
    if obj.is_a?(SOAPBasetype)
      obj
    elsif obj.is_a?(SOAPStruct) && (type = @definedtypes[type_qname])
      soap_obj = obj
      mark_marshalled_obj(obj, soap_obj)
      elements2soap(obj, soap_obj, type.content.elements)
      soap_obj
    elsif obj.is_a?(SOAPArray) && (type = @definedtypes[type_qname])
      soap_obj = obj
      contenttype = type.child_type
      mark_marshalled_obj(obj, soap_obj)
      obj.replace do |ele|
	Mapping._obj2soap(ele, self, contenttype)
      end
      soap_obj
    else
      nil
    end
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
    type.check_lexical_format(obj)
    o
  end

  def complex2soap(obj, type)
    case type.compoundtype
    when :TYPE_STRUCT
      struct2soap(obj, type.name, type)
    when :TYPE_ARRAY
      array2soap(obj, type.name, type)
    when :TYPE_MAP
      map2soap(obj, type.name, type)
    when :TYPE_SIMPLE
      simple2soap(obj, type.simplecontent)
    else
      raise MappingError.new("unknown compound type: #{type.compoundtype}")
    end
  end

  def base2soap(obj, type)
    soap_obj = nil
    if type <= XSD::XSDString
      soap_obj = type.new(XSD::Charset.is_ces(obj, $KCODE) ?
        XSD::Charset.encoding_conv(obj, $KCODE, XSD::Charset.encoding) : obj)
      mark_marshalled_obj(obj, soap_obj)
    else
      soap_obj = type.new(obj)
    end
    soap_obj
  end

  def struct2soap(obj, type_qname, type)
    soap_obj = SOAPStruct.new(type_qname)
    mark_marshalled_obj(obj, soap_obj)
    elements2soap(obj, soap_obj, type.content.elements)
    soap_obj
  end

  def array2soap(obj, type_qname, type)
    arytype = type.child_type
    soap_obj = SOAPArray.new(ValueArrayName, 1, arytype)
    mark_marshalled_obj(obj, soap_obj)
    obj.each do |item|
      soap_obj.add(Mapping._obj2soap(item, self, arytype))
    end
    soap_obj
  end

  MapKeyName = XSD::QName.new(nil, "key")
  MapValueName = XSD::QName.new(nil, "value")
  def map2soap(obj, type_qname, type)
    keytype = type.child_type(MapKeyName) || XSD::AnyTypeName
    valuetype = type.child_type(MapValueName) || XSD::AnyTypeName
    soap_obj = SOAPStruct.new(MapQName)
    mark_marshalled_obj(obj, soap_obj)
    obj.each do |key, value|
      elem = SOAPStruct.new
      elem.add("key", Mapping._obj2soap(key, self, keytype))
      elem.add("value", Mapping._obj2soap(value, self, valuetype))
      # ApacheAxis allows only 'item' here.
      soap_obj.add("item", elem)
    end
    soap_obj
  end

  def elements2soap(obj, soap_obj, elements)
    elements.each do |element|
      name = element.name.name
      child_obj = Mapping.get_attribute(obj, name)
      soap_obj.add(name,
        Mapping._obj2soap(child_obj, self, element.type || element.name))
    end
  end
end


end
end
