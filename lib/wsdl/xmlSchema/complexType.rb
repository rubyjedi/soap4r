=begin
WSDL4R - XMLSchema complexType definition for WSDL.
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
require 'wsdl/xmlSchema/content'


module WSDL
  module XMLSchema


class ComplexType < Info
  attr_reader :name
  attr_reader :complexContent
  attr_reader :content

  def initialize
    super
    @name = nil
    @complexContent = nil
    @content = nil
    @anonymousType = false
  end

  def setAnonymousTypeName( name )
    @name = name
    @anonymousType = true
  end

  def isAnonymousType
    @anonymousType
  end

  def targetNamespace
    parent.targetNamespace
  end

  ComplexContentName = Name.new( XSD::Namespace, 'complexContent' )
  def parseElement( element )
    case element
    when ComplexContentName
      o = ComplexContent.new
      @complexContent = o
      o
    else
      @content = Content.new( self )
      @content.parseElement( element )
    end
  end

  NameAttrName = Name.new( nil, 'name' )
  def parseAttr( attr, value )
    case attr
    when NameAttrName
      @name = Name.new( targetNamespace, value )
    else
      raise WSDLParser::UnknownAttributeError.new( "Unknown attr #{ attr }." )
    end
  end
end

  end
end
