=begin
WSDL4R - XMLSchema schema definition for WSDL.
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
require 'wsdl/namedElements'


module WSDL
  module XMLSchema


class Schema < Info
  attr_reader :targetNamespace	# required
  attr_reader :complexTypes
  attr_reader :elements
  attr_reader :attributes
  attr_reader :imports
  attr_accessor :elementFormDefault

  def initialize
    super
    @targetNamespace = nil
    @complexTypes = NamedElements.new
    @elements = NamedElements.new
    @attributes = NamedElements.new
    @imports = []
    @elementFormDefault = nil
  end

  def addAttribute( attribute )
    @attributes << attribute
  end

  ImportName = XSD::QName.new( XSD::Namespace, 'import' )
  ComplexTypeName = XSD::QName.new( XSD::Namespace, 'complexType' )
  ElementName = XSD::QName.new( XSD::Namespace, 'element' )
  AttributeName = XSD::QName.new( XSD::Namespace, 'attribute' )
  def parseElement( element )
    case element
    when ImportName
      o = Import.new
      @imports << o
      o
    when ComplexTypeName
      o = ComplexType.new
      @complexTypes << o
      o
    when ElementName
      o = Element.new
      o
    when AttributeName
      o = Attribute.new
      o
    else
      nil
    end
  end

  TargetNamespaceAttrName = XSD::QName.new( nil, 'targetNamespace' )
  ElementFormDefaultAttrName = XSD::QName.new( nil, 'elementFormDefault' )
  def parseAttr( attr, value )
    case attr
    when TargetNamespaceAttrName
      @targetNamespace = value
    when ElementFormDefaultAttrName
      @elementFormDefault = value
    else
      raise WSDLParser::UnknownAttributeError.new( "Unknown attr #{ attr }." )
    end
  end
end

  end
end
