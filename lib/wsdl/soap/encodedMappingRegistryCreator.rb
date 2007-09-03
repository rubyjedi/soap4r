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

  def initialize(definitions, modulepath, defined_const)
    @definitions = definitions
    @modulepath = modulepath
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
      dump_encoded_array_typemap(qname, typedef)
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

  def dump_encoded_array_typemap(qname, typedef)
    arytype = typedef.find_arytype || XSD::AnyTypeName
    type = XSD::QName.new(arytype.namespace, arytype.name.sub(/\[(?:,)*\]$/, ''))
    assign_const(type.namespace, 'Ns')
    return <<__EOD__
#{@varname}.set(
  #{create_class_name(qname, @modulepath)},
  ::SOAP::SOAPArray,
  ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
  { :type => #{dqname(type)} }
)
__EOD__
  end
end


end
end
