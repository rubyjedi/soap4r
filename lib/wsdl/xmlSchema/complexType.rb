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
  attr_accessor :complexContent
  attr_accessor :content
  attr_reader :attributes

  def initialize( name = nil )
    super()
    @name = name
    @complexContent = nil
    @content = nil
    @attributes = NamedElements.new
  end

  def targetNamespace
    parent.targetNamespace
  end

  def eachContent
    if content
      content.each do | item |
	yield( item )
      end
    end
  end

  def eachElement
    if content
      content.elements.each do | name, element |
	yield( name, element )
      end
    end
  end

  def getElement( name )
    @content.elements.each do | key, element |
      return element if name == key
    end
    nil
  end

  def setSequenceElements( elements )
    @content = Content.new
    @content.type = 'sequence'
    elements.each do | element |
      @content << element
    end
  end

  def parseElement( element )
    case element
    when AllName, SequenceName, ChoiceName
      @content = Content.new
      @content.type = element.name
      @content
    when ComplexContentName
      @complexContent = ComplexContent.new
      @complexContent
    when AttributeName
      o = Attribute.new
      @attributes << o
      o
    else
      nil
    end
  end

  def parseAttr( attr, value )
    case attr
    when NameAttrName
      @name = XSD::QName.new( targetNamespace, value )
    else
      raise WSDLParser::UnknownAttributeError.new( "Unknown attr #{ attr }." )
    end
  end
end

  end
end
