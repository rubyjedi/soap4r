# WSDL4R - Creating LiteralMappingRegistry code from WSDL.
# Copyright (C) 2006  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/soap/mappingRegistryCreatorSupport'


module WSDL
module SOAP


class LiteralMappingRegistryCreator
  include MappingRegistryCreatorSupport

  def initialize(definitions, modulepath)
    @definitions = definitions
    @modulepath = modulepath
    @elements = definitions.collect_elements
    @elements.uniq!
    @attributes = definitions.collect_attributes
    @attributes.uniq!
    @simpletypes = definitions.collect_simpletypes
    @simpletypes.uniq!
    @complextypes = definitions.collect_complextypes
    @complextypes.uniq!
    @varname = nil
  end

  def dump(varname)
    @varname = varname
    result = ''
    str = dump_element
    unless str.empty?
      result << "\n" unless result.empty?
      result << str
    end
    str = dump_attribute
    unless str.empty?
      result << "\n" unless result.empty?
      result << str
    end
    str = dump_complextype
    unless str.empty?
      result << "\n" unless result.empty?
      result << str
    end
    str = dump_simpletype
    unless str.empty?
      result << "\n" unless result.empty?
      result << str
    end
    result
  end

private

  def dump_element
    @elements.collect { |ele|
      if ele.local_complextype
        qualified = (ele.elementform == 'qualified')
        dump_complextypedef(ele.name, ele.local_complextype, qualified)
      elsif ele.local_simpletype
        dump_simpletypedef(ele.name, ele.local_simpletype)
      else
        nil
      end
    }.compact.join("\n")
  end

  def dump_attribute
    @attributes.collect { |attr|
      if attr.local_simpletype
        dump_simpletypedef(attr.name, attr.local_simpletype)
      end
    }.compact.join("\n")
  end

  def dump_simpletype
    @simpletypes.collect { |type|
      dump_simpletypedef(type.name, type)
    }.compact.join("\n")
  end

  def dump_complextype
    @complextypes.collect { |type|
      dump_complextypedef(type.name, type) unless type.abstract
    }.compact.join("\n")
  end

  def dump_complextypedef(qname, typedef, qualified = false)
    case typedef.compoundtype
    when :TYPE_STRUCT, :TYPE_EMPTY
      dump_struct_typemap(qname, typedef, qualified)
    when :TYPE_ARRAY
      dump_array_typemap(qname, typedef)
    when :TYPE_SIMPLE
      dump_simple_typemap(qname, typedef)
    when :TYPE_MAP
      # mapped as a general Hash
      nil
    else
      raise RuntimeError.new(
        "unknown kind of complexContent: #{typedef.compoundtype}")
    end
  end

  def dump_struct_typemap(qname, typedef, qualified = false)
    var = {}
    var[:class] = create_class_name(qname, @modulepath)
    if typedef.name.nil?
      # local complextype of a element
      var[:schema_name] = qname.name
    else
      # named complextype
      var[:schema_type] = qname.name
    end
    var[:schema_ns] = qname.namespace
    var[:schema_qualified] = qualified.to_s

    parsed_element = parse_elements(typedef.elements, qname.namespace)
    if typedef.choice?
      parsed_element.unshift(:choice)
    end
    var[:schema_element] = dump_schema_element_definition(parsed_element, 2)
    unless typedef.attributes.empty?
      var[:schema_attribute] = define_attribute(typedef.attributes)
    end
    dump_entry(@varname, var)
  end

  DEFAULT_ITEM_NAME = XSD::QName.new(nil, 'item')

  def dump_array_typemap(qname, typedef)
    var = {}
    var[:class] = create_class_name(qname, @modulepath)
    var[:schema_ns] = qname.namespace
    if typedef.name.nil?
      # local complextype of a element
      var[:schema_name] = qname.name
    else
      # named complextype
      var[:schema_type] = qname.name
    end
    child_type = typedef.child_type
    child_element = typedef.find_aryelement
    if child_type == XSD::AnyTypeName
      type = nil
    elsif child_element and (klass = element_basetype(child_element))
      type = klass.name
    elsif child_type
      type = create_class_name(child_type, @modulepath)
    else
      type = nil
    end
    if child_element and child_element.name
      if child_element.map_as_array?
        type << '[]' if type
      end
      child_element_name = child_element.name
    else
      child_element_name = DEFAULT_ITEM_NAME
    end
    parsed_element = []
    parsed_element << [child_element_name.name, child_element_name, type]
    var[:schema_element] = dump_schema_element_definition(parsed_element, 2)
    dump_entry(@varname, var)
  end

  def dump_simple_typemap(qname, type_or_element)
    var = {}
    var[:class] = create_class_name(qname, @modulepath)
    var[:schema_ns] = qname.namespace
    var[:schema_type] = qname.name
    unless type_or_element.attributes.empty?
      var[:schema_attribute] = define_attribute(type_or_element.attributes)
    end
    dump_entry(@varname, var)
  end
end


end
end
