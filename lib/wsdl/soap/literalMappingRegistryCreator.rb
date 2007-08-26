# WSDL4R - Creating LiteralMappingRegistry code from WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/soap/mappingRegistryCreatorSupport'


module WSDL
module SOAP


class LiteralMappingRegistryCreator
  include MappingRegistryCreatorSupport

  def initialize(definitions, modulepath, defined_const)
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
    @defined_const = defined_const
  end

  def dump(varname)
    @varname = varname
    result = ''
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
    result
  end

private

  def dump_element
    @elements.collect { |ele|
      qualified = (ele.elementform == 'qualified')
      if ele.local_complextype
        dump_complextypedef(ele.name, ele.local_complextype, nil, qualified)
      elsif ele.local_simpletype
        dump_simpletypedef(ele.name, ele.local_simpletype, nil, qualified)
      elsif ele.type
        if typedef = @complextypes[ele.type]
          dump_complextypedef(ele.type, typedef, ele.name, qualified)
        elsif typedef = @simpletypes[ele.type]
          dump_simpletypedef(ele.type, typedef, ele.name, qualified)
        else
          nil
        end
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

  def dump_complextypedef(qname, typedef, as_element = nil, qualified = false)
    case typedef.compoundtype
    when :TYPE_STRUCT, :TYPE_EMPTY
      dump_struct_typemap(qname, typedef, as_element, qualified)
    when :TYPE_ARRAY
      dump_array_typemap(qname, typedef)
    when :TYPE_SIMPLE
      dump_simple_typemap(qname, typedef, as_element, qualified)
    when :TYPE_MAP
      # mapped as a general Hash
      nil
    else
      raise RuntimeError.new(
        "unknown kind of complexContent: #{typedef.compoundtype}")
    end
  end

  DEFAULT_ITEM_NAME = XSD::QName.new(nil, 'item')

  def dump_array_typemap(qname, typedef)
    var = {}
    var[:class] = create_class_name(qname, @modulepath)
    schema_ns = qname.namespace
    if typedef.name.nil?
      # local complextype of a element
      var[:schema_name] = qname
    else
      # named complextype
      var[:schema_type] = qname
    end
    child_type = typedef.child_type
    child_element = typedef.find_aryelement
    if child_type == XSD::AnyTypeName
      type = nil
    elsif child_element
      if klass = element_basetype(child_element)
        type = klass.name
      else
        typename = child_element.type || child_element.name
        type = create_class_name(typename, @modulepath)
      end
    elsif child_type
      type = create_class_name(child_type, @modulepath)
    else
      type = nil
    end
    occurrence = [0, nil]
    if child_element and child_element.name
      if child_element.map_as_array?
        type << '[]' if type
        occurrence = [child_element.minoccurs, child_element.maxoccurs]
      end
      child_element_name = child_element.name
    else
      child_element_name = DEFAULT_ITEM_NAME
    end
    parsed_element = []
    parsed_element << [child_element_name.name, child_element_name, type, occurrence]
    var[:schema_element] = dump_schema_element_definition(parsed_element, 2)
    assign_const(schema_ns, 'Ns')
    dump_entry(@varname, var)
  end
end


end
end
