=begin
WSDL4R - XMLSchema complexContent definition for WSDL.
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


class ComplexContent < Info
  DeriveTypeRestriction = Object.new
  DeriveTypeExtension = Object.new

  attr_accessor :base
  attr_reader :deriveType
  attr_reader :content

  def initialize
    super
    @base = nil
    @deriveType = nil
    @content = Content.new( self )
  end

  def getRefAttribute( ref )
    content.attributes.each do | attribute |
      if attribute.ref == ref
	return attribute
      end
    end
    nil
  end

  RestrictionName = XSD::QName.new( XSD::Namespace, 'restriction' )
  ExtensionName = XSD::QName.new( XSD::Namespace, 'extension' )
  def parseElement( element )
    case element
    when RestrictionName
      @deriveType = DeriveTypeRestriction
      self
    when ExtensionName
      @deriveType = DeriveTypeExtension
      self
    else
      if @deriveType.nil?
	raise WSDLParser::ElementConstraintError.new( "base attr not found." )
      end
      @content.parseElement( element )
    end
  end

  BaseAttrName = XSD::QName.new( nil, 'base' )
  def parseAttr( attr, value )
    if @deriveType.nil?
      raise WSDLParser::UnknownAttributeError.new( "Unknown attr #{ attr }." )
    end
    case attr
    when BaseAttrName
      @base = value
    else
      @content.parseAttr( attr, value )
    end
  end
end

  end
end
