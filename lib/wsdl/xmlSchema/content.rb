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


module WSDL
  module XMLSchema


class Content < Info
  TypeAll = Object.new
  TypeSequence = Object.new

  attr_reader :final
  attr_reader :mixed
  attr_reader :type
  attr_reader :attributes
  attr_reader :elements

  def initialize( container )
    super()
    @container = container
    @final = nil
    @mixed = false
    @type = nil
    @attributes = []
    @elements = []
  end

  def targetNamespace
    parent.targetNamespace
  end

  AllName = Name.new( XSD::Namespace, 'all' )
  SequenceName = Name.new( XSD::Namespace, 'sequence' )
  AttributeName = Name.new( XSD::Namespace, 'attribute' )
  ElementName = Name.new( XSD::Namespace, 'element' )
  def parseElement( element )
    case element
    when AllName
      @type = TypeAll
      self
    when SequenceName
      @type = TypeSequence
      self
    when AttributeName
      o = Attribute.new
      @attributes << o
      o
    when ElementName
      if @type.nil?
	raise WSDLParser::UnexpectedElementError.new(
	  "Unexpected element #{ element }." )
      end
      o = Element.new
      @elements << o
      o
    else
      nil
    end
  end

  FinalAttrName = Name.new( nil, 'final' )
  MixedAttrName = Name.new( nil, 'mixed' )
  def parseAttr( attr, value )
    case attr
    when FinalAttrName
      @final = value
    when MixedAttrName
      @mixed = ( value == 'true' )
    else
      raise WSDLParser::UnknownAttributeError.new( "Unknown attr #{ attr }." )
    end
  end
end

  end
end
