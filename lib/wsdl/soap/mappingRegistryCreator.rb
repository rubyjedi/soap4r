=begin
WSDL4R - Creating MappingRegistry code from WSDL.
Copyright (C) 2002, 2003  NAKAMURA, Hiroshi.

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PRATICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 675 Mass
Ave, Cambridge, MA 02139, USA.
=end


require 'wsdl/info'


module WSDL
  module SOAP


class MappingRegistryCreator
  attr_reader :definitions

  def initialize(definitions)
    @definitions = definitions
    @complextypes = @definitions.collect_complextypes
    @types = nil
  end

  def dump(types)
    @types = types
    map_cache = []
    map = ""
    @types.each do |type|
      if map_cache.index(type).nil?
	map_cache << type
	if type.namespace != XSD::Namespace
	  map << dump_typemap(type)
	end
      end
    end

    return <<__EOD__
#{ map }
__EOD__
  end

private

  def dump_typemap(type)
    definedtype = @complextypes[type]
    case definedtype.compoundtype
    when :TYPE_STRUCT
      dump_struct_typemap(definedtype)
    when :TYPE_ARRAY
      dump_array_typemap(definedtype)
    else
      raise NotImplementedError.new("Must not reach here.")
    end
  end

  def dump_struct_typemap(definedtype)
    ele = definedtype.name
    return <<__EOD__
MappingRegistry.set(
  #{ ele.name },
  ::SOAP::SOAPStruct,
  ::SOAP::RPCUtils::MappingRegistry::TypedStructFactory,
  { :type => XSD::QName.new("#{ ele.namespace }", "#{ ele.name }") }
)
__EOD__
  end

  def dump_array_typemap(definedtype)
    ele = definedtype.name
    arytype = definedtype.find_arytype
    type = XSD::QName.new(arytype.namespace, arytype.name.sub(/\[(?:,)*\]$/, ''))
    @types << type
    return <<__EOD__
MappingRegistry.set(
  #{ ele.name },
  ::SOAP::SOAPArray,
  ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
  { :type => XSD::QName.new("#{ type.namespace }", "#{ type.name }") }
)
__EOD__
  end
end


  end
end
