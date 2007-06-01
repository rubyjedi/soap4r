# WSDL4R - Creating EncodedMappingRegistry code from WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/soap/mappingRegistryCreatorSupport'


module WSDL
module SOAP


class EncodedMappingRegistryCreator
  include MappingRegistryCreatorSupport

  attr_reader :definitions

  def initialize(definitions, modulepath)
    @definitions = definitions
    @modulepath = modulepath
    @simpletypes = definitions.collect_simpletypes
    @simpletypes.uniq!
    @complextypes = definitions.collect_complextypes
    @complextypes.uniq!
    @varname = nil
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
    result
  end

private

  def dump_complextype
    @complextypes.collect { |type|
      dump_complextypedef(type.name, type) unless type.abstract
    }.compact.join("\n")
  end

  def dump_simpletype
    @simpletypes.collect { |type|
      dump_simpletypedef(type.name, type)
    }.compact.join("\n")
  end

  def dump_complextypedef(qname, typedef)
    case typedef.compoundtype
    when :TYPE_STRUCT, :TYPE_EMPTY
      dump_struct_typemap(qname, typedef)
    when :TYPE_ARRAY
      dump_array_typemap(qname, typedef)
    when :TYPE_SIMPLE
      dump_simple_typemap(qname, typedef)
    when :TYPE_MAP
      nil
    else
      raise NotImplementedError.new("must not reach here: #{typedef.compoundtype}")
    end
  end

  def dump_struct_typemap(qname, typedef)
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
    parsed_element = parse_elements(typedef.elements, qname.namespace)
    var[:schema_element] = dump_schema_element_definition(parsed_element, 2)
    dump_entry(@varname, var)
  end

  def dump_array_typemap(qname, typedef)
    arytype = typedef.find_arytype || XSD::AnyTypeName
    type = XSD::QName.new(arytype.namespace, arytype.name.sub(/\[(?:,)*\]$/, ''))
    return <<__EOD__
#{@varname}.set(
  #{create_class_name(qname, @modulepath)},
  ::SOAP::SOAPArray,
  ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
  { :type => #{dqname(type)} }
)
__EOD__
  end

  def dump_simple_typemap(qname, typedef)
    var = {}
    var[:class] = create_class_name(qname, @modulepath)
    var[:schema_ns] = qname.namespace
    var[:schema_type] = qname.name
    dump_entry(@varname, var)
  end
end


end
end
