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

  def initialize(definitions, name_creator, modulepath, defined_const)
    @definitions = definitions
    @name_creator = name_creator
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
      next if @complextypes[ele.name]
      qualified = (ele.elementform == 'qualified')
      if ele.local_complextype
        dump_complextypedef(@modulepath, ele.name, ele.local_complextype, nil, qualified)
      elsif ele.local_simpletype
        dump_simpletypedef(@modulepath, ele.name, ele.local_simpletype, nil, qualified)
      elsif ele.type
        if typedef = @complextypes[ele.type]
          dump_complextypedef(@modulepath, ele.type, typedef, ele.name, qualified)
        elsif typedef = @simpletypes[ele.type]
          dump_simpletypedef(@modulepath, ele.type, typedef, ele.name, qualified)
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
        dump_simpletypedef(@modulepath, attr.name, attr.local_simpletype)
      end
    }.compact.join("\n")
  end

  def dump_simpletype
    @simpletypes.collect { |type|
      dump_simpletypedef(@modulepath, type.name, type)
    }.compact.join("\n")
  end

  def dump_complextype
    @complextypes.collect { |type|
      dump_complextypedef(@modulepath, type.name, type) unless type.abstract
    }.compact.join("\n")
  end

  def dump_complextypedef(mpath, qname, typedef, as_element = nil, qualified = false)
    case typedef.compoundtype
    when :TYPE_STRUCT, :TYPE_EMPTY
      dump_struct_typemap(mpath, qname, typedef, as_element, qualified)
    when :TYPE_ARRAY
      dump_array_typemap(mpath, qname, typedef)
    when :TYPE_SIMPLE
      dump_simple_typemap(mpath, qname, typedef, as_element, qualified)
    when :TYPE_MAP
      # mapped as a general Hash
      nil
    else
      raise RuntimeError.new(
        "unknown kind of complexContent: #{typedef.compoundtype}")
    end
  end
end


end
end
