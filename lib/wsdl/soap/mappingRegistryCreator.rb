=begin
WSDL4R - Creating MappingRegistry code from WSDL.
Copyright (C) 2002 NAKAMURA Hiroshi.

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

  def initialize( definitions )
    @definitions = definitions
    @complexTypes = @definitions.collectComplexTypes
    @types = nil
  end

  def dump( types )
    @types = types
    typeMapCache = []
    typeMap = ""
    @types.each do | type |
      if typeMapCache.index( type ).nil?
	typeMapCache << type
	if type.namespace != XSD::Namespace
	  typeMap << dumpTypeMap( type )
	end
      end
    end

    return <<__EOD__
#{ typeMap }
__EOD__
  end

private

  def dumpTypeMap( type )
    typeDef = @complexTypes[ type ]
    case typeDef.compoundType
    when :TYPE_STRUCT
      dumpTypeMapStruct( typeDef )
    when :TYPE_ARRAY
      dumpTypeMapArray( typeDef )
    else
      raise NotImplementedError.new( "Must not reach here." )
    end
  end

  def dumpTypeMapStruct( typeDef )
    ele = typeDef.name
    return <<__EOD__
MappingRegistry.set(
  #{ ele.name },
  ::SOAP::SOAPStruct,
  ::SOAP::RPCUtils::MappingRegistry::TypedStructFactory,
  { :type => XSD::QName.new( "#{ ele.namespace }", "#{ ele.name }" ) }
)
__EOD__
  end

  def dumpTypeMapArray( typeDef )
    ele = typeDef.name
    arrayType = typeDef.getArrayType
    contentType = XSD::QName.new( arrayType.namespace,
      arrayType.name.sub( /\[(?:,)*\]$/, '' ))
    @types << contentType
    return <<__EOD__
MappingRegistry.set(
  #{ ele.name },
  ::SOAP::SOAPArray,
  ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
  { :type => XSD::QName.new( "#{ contentType.namespace }", "#{ contentType.name }" ) }
)
__EOD__
  end
end


  end
end
