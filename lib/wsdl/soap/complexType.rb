=begin
WSDL4R - SOAP complexType definition for WSDL.
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


require 'wsdl/xmlSchema/complexType'


module WSDL
  module XMLSchema


class ComplexType < Info
  def compoundType
    @compoundType ||= checkType
  end

  def checkType
    if content
      :TYPE_STRUCT
    elsif complexContent and complexContent.base == ::SOAP::ValueArrayName
      :TYPE_ARRAY
    else
      raise NotImplementedError.new( "Unknown kind of complexType." )
    end
  end

  def getChildType( name = nil )
    case compoundType
    when :TYPE_STRUCT
      if ( ele = getElement( name ))
        ele.type
      else
        nil
      end
    when :TYPE_ARRAY
      @contentType ||= getContentType
    end
  end

  def getChildLocalTypeDef( name )
    unless compoundType == :TYPE_STRUCT
      raise RuntimeError.new( "Assert: not for struct" )
    end
    getElement( name ).localComplexType
  end

  def getArrayType
    complexContent.attributes.each do | attribute |
      if attribute.ref == ::SOAP::AttrArrayTypeName
	return attribute.arrayType
      end
    end
    nil
  end

private

  def getContentType
    unless compoundType == :TYPE_ARRAY
      raise RuntimeError.new( "Assert: not for array" )
    end
    arrayType = getArrayType
    contentTypeNamespace = arrayType.namespace
    contentTypeName = arrayType.name.sub( /\[(?:,)*\]$/, '' )
    XSD::QName.new( contentTypeNamespace, contentTypeName )
  end
end

  end
end
