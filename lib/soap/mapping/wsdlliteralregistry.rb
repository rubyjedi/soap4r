# SOAP4R - WSDL literal mapping registry.
# Copyright (C) 2004, 2005  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/baseData'
require 'soap/mapping/mapping'
require 'soap/mapping/typeMap'
require 'xsd/codegen/gensupport'
require 'xsd/namedelements'


module SOAP
module Mapping


class WSDLLiteralRegistry < Registry
  attr_reader :definedelements
  attr_reader :definedtypes
  attr_accessor :excn_handler_obj2soap
  attr_accessor :excn_handler_soap2obj

  def initialize(definedtypes = XSD::NamedElements::Empty,
      definedelements = XSD::NamedElements::Empty)
    @definedtypes = definedtypes
    @definedelements = definedelements
    @excn_handler_obj2soap = nil
    @excn_handler_soap2obj = nil
    @rubytype_factory = RubytypeFactory.new(:allow_original_mapping => false)
    @schema_element_cache = {}
    @schema_attribute_cache = {}
  end

  def obj2soap(obj, qname)
    ret = nil
    if ele = @definedelements[qname]
      ret = _obj2soap(obj, ele)
    elsif type = @definedtypes[qname]
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
    raise MappingError.new("cannot map #{obj.class.name} to SOAP/OM")
  end

  # node should be a SOAPElement
  def soap2obj(node, obj_class = nil)
    unless obj_class.nil?
      raise MappingError.new("must not reach here")
    end
    begin
      return soapele2obj(node)
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

  def _obj2soap(obj, ele)
    o = nil
    if ele.type
      if type = @definedtypes[ele.type]
        o = obj2type(obj, type)
      elsif type = TypeMap[ele.type]
        o = base2soap(obj, type)
      else
        raise MappingError.new("cannot find type #{ele.type}")
      end
      o.elename = ele.name
    elsif ele.local_complextype
      o = obj2type(obj, ele.local_complextype)
      o.elename = ele.name
      add_attributes2soap(obj, o)
    elsif ele.local_simpletype
      o = obj2type(obj, ele.local_simpletype)
      o.elename = ele.name
    else
      raise MappingError.new('illegal schema?')
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
    type.check_lexical_format(obj)
    o
  end

  def complex2soap(obj, type)
    o = SOAPElement.new(type.name)
    type.each_element do |child_ele|
      child = Mapping.get_attribute(obj, child_ele.name.name)
      if child.nil?
        if child_ele.nillable
          # ToDo: test
          # add empty element
          o.add(_obj2soap(nil))
        elsif Integer(child_ele.minoccurs) == 0
          # nothing to do
        else
          raise MappingError.new("nil not allowed: #{child_ele.name.name}")
        end
      elsif child_ele.map_as_array?
        child.each do |item|
          o.add(_obj2soap(item, child_ele))
        end
      else
        o.add(_obj2soap(child, child_ele))
      end
    end
    o
  end

  def unknownobj2soap(obj, name)
    if obj.is_a?(SOAPElement)
      obj
    elsif obj.class.class_variables.include?('@@schema_element')
      unknownobj2definedsoap(obj, name)
    elsif obj.is_a?(SOAP::Mapping::Object)
      mappingobj2soap(obj, name)
    elsif obj.is_a?(Hash)
      ele = SOAPElement.from_obj(obj)
      ele.elename = name
      ele
    else
      # expected to be a basetype or an anyType.
      # SOAPStruct, etc. is used instead of SOAPElement.
      begin
        ele = Mapping.obj2soap(obj)
        ele.elename = name
        ele
      rescue MappingError
        ele = SOAPElement.new(name, obj.to_s)
      end
      if obj.respond_to?(:__xmlattr)
        obj.__xmlattr.each do |key, value|
          ele.extraattr[key] = value
        end
      end
      ele
    end
  end

  def unknownobj2definedsoap(obj, name)
    ele = SOAPElement.new(name)
    add_elements2soap(obj, ele)
    add_attributes2soap(obj, ele)
    ele
  end

  def mappingobj2soap(obj, name)
    ele = SOAPElement.new(name)
    obj.__xmlele.each do |key, value|
      if value.is_a?(::Array)
        value.each do |item|
          ele.add(obj2soap(item, key))
        end
      else
        ele.add(obj2soap(value, key))
      end
    end
    obj.__xmlattr.each do |key, value|
      ele.extraattr[key] = value
    end
    ele
  end

  def add_elements2soap(obj, ele)
    elements, as_array = schema_element_definition(obj.class)
    if elements
      elements.each do |elename, type|
        child = Mapping.get_attribute(obj, elename)
        unless child.nil?
          name = XSD::QName.new(nil, elename)
          if as_array.include?(type)
            child.each do |item|
              ele.add(obj2soap(item, name))
            end
          else
            ele.add(obj2soap(child, name))
          end
        end
      end
    end
  end
  
  def add_attributes2soap(obj, ele)
    attributes = schema_attribute_definition(obj.class)
    if attributes
      attributes.each do |qname, param|
        attr = obj.__send__('xmlattr_' +
          XSD::CodeGen::GenSupport.safevarname(qname.name))
        ele.extraattr[qname] = attr
      end
    end
  end

  def base2soap(obj, type)
    soap_obj = nil
    if type <= XSD::XSDString
      soap_obj = type.new(XSD::Charset.is_ces(obj, $KCODE) ?
        XSD::Charset.encoding_conv(obj, $KCODE, XSD::Charset.encoding) :
        obj)
    else
      soap_obj = type.new(obj)
    end
    soap_obj
  end

  def anytype2obj(node)
    if node.is_a?(::SOAP::SOAPBasetype)
      return node.data
    end
    klass = ::SOAP::Mapping::Object
    obj = klass.new
    obj
  end

  def soapele2obj(node, obj_class = nil)
    unless obj_class
      typestr = XSD::CodeGen::GenSupport.safeconstname(node.elename.name)
      obj_class = Mapping.class_from_name(typestr)
    end
    if obj_class and obj_class.class_variables.include?('@@schema_element')
      soapele2definedobj(node, obj_class)
    elsif node.is_a?(SOAPElement) or node.is_a?(SOAPStruct)
        # SOAPArray for literal?
      soapele2undefinedobj(node)
    else
      result, obj = @rubytype_factory.soap2obj(nil, node, nil, self)
      if result
        add_attributes2undefinedobj(node, obj)
      end
      obj
    end
  end

  def soapele2definedobj(node, obj_class)
    obj = Mapping.create_empty_object(obj_class)
    add_elements2obj(node, obj)
    add_attributes2obj(node, obj)
    obj
  end

  def soapele2undefinedobj(node)
    obj = anytype2obj(node)
    add_elements2undefinedobj(node, obj)
    add_attributes2undefinedobj(node, obj)
    obj
  end

  def add_elements2obj(node, obj)
    elements, as_array = schema_element_definition(obj.class)
    vars = {}
    node.each do |name, value|
      if class_name = elements[name]
        if klass = Mapping.class_from_name(class_name)
          if klass.ancestors.include?(::SOAP::SOAPBasetype)
            if value.respond_to?(:data)
              child = klass.new(value.data).data
            else
              child = klass.new(nil).data
            end
          else
            child = soapele2obj(value, klass)
          end
        else
          raise MappingError.new("unknown class: #{class_name}")
        end
      else      # untyped element is treated as anyType.
        child = soapele2obj(value)
      end
      if as_array.include?(class_name)
        (vars[name] ||= []) << child
      else
        vars[name] = child
      end
    end
    Mapping.set_attributes(obj, vars)
  end

  def add_attributes2obj(node, obj)
    if attributes = schema_attribute_definition(obj.class)
      define_xmlattr(obj)
      attributes.each do |qname, class_name|
        attr = node.extraattr[qname]
        next if attr.nil? or attr.empty?
        klass = Mapping.class_from_name(class_name)
        if klass.ancestors.include?(::SOAP::SOAPBasetype)
          child = klass.new(attr).data
        else
          child = attr
        end
        obj.__xmlattr[qname] = child
        define_xmlattr_accessor(obj, qname)
      end
    end
  end

  def add_elements2undefinedobj(node, obj)
    node.each do |name, value|
      obj.__add_xmlele_value(XSD::QName.new(nil, name), soapele2obj(value))
    end
  end

  def add_attributes2undefinedobj(node, obj)
    return if node.extraattr.empty?
    define_xmlattr(obj)
    node.extraattr.each do |qname, value|
      obj.__xmlattr[qname] = value
      define_xmlattr_accessor(obj, qname)
    end
  end

  if RUBY_VERSION > "1.7.0"
    def define_xmlattr_accessor(obj, qname)
      name = XSD::CodeGen::GenSupport.safemethodname(qname.name)
      Mapping.define_attr_accessor(obj, 'xmlattr_' + name,
        proc { @__xmlattr[qname] },
        proc { |value| @__xmlattr[qname] = value })
    end
  else
    def define_xmlattr_accessor(obj, qname)
      name = XSD::CodeGen::GenSupport.safemethodname(qname.name)
      obj.instance_eval <<-EOS
        def #{name}
          @__xmlattr[#{qname.dump}]
        end

        def #{name}=(value)
          @__xmlattr[#{qname.dump}] = value
        end
      EOS
    end
  end

  if RUBY_VERSION > "1.7.0"
    def define_xmlattr(obj)
      obj.instance_variable_set('@__xmlattr', {})
      unless obj.respond_to?(:__xmlattr)
        Mapping.define_attr_accessor(obj, :__xmlattr, proc { @__xmlattr })
      end
    end
  else
    def define_xmlattr(obj)
      obj.instance_variable_set('@__xmlattr', {})
      unless obj.respond_to?(:__xmlattr)
        obj.instance_eval <<-EOS
          def __xmlattr
            @__xmlattr
          end
        EOS
      end
    end
  end

  # it caches @@schema_element.  this means that @@schema_element must not be
  # changed while a lifetime of a WSDLLiteralRegistry.
  def schema_element_definition(klass)
    @schema_element_cache[klass] ||= Mapping.schema_element_definition(klass)
  end

  def schema_attribute_definition(klass)
    @schema_attribute_cache[klass] ||= Mapping.schema_attribute_definition(klass)
  end
end


end
end
