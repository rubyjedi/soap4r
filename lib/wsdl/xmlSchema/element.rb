=begin
WSDL4R - XMLSchema element definition for WSDL.
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


class Element < Info
  attr_accessor :name	# required
  attr_accessor :type
  attr_accessor :localComplexType
  attr_accessor :maxOccurs
  attr_accessor :minOccurs
  attr_accessor :nillable

  def initialize( name = nil, type = XSD::AnyTypeName )
    super()
    @name = name
    @type = type
    @localComplexType = nil
    @maxOccurs = 1
    @minOccurs = 1
    @nillable = nil
  end

  def targetNamespace
    parent.targetNamespace
  end

  def parseElement( element )
    case element
    when ComplexTypeName
      @type = nil
      @localComplexType = ComplexType.new
      @localComplexType
    else
      nil
    end
  end

  def parseAttr( attr, value )
    case attr
    when NameAttrName
      @name = value
    when TypeAttrName
      @type = if value.is_a?( XSD::QName )
	  value
	else
	  XSD::QName.new( XSD::Namespace, value )
	end
    when MaxOccursAttrName
      if parent.type == 'all'
	if value != '1'
	  raise WSDLParser::AttrConstraintError.new(
	    "Cannot parse #{ value } for #{ attr }." )
	end
	@maxOccurs = value
      elsif parent.type == 'sequence'
	@maxOccurs = value
      else
	raise NotImplementedError.new
      end
    when MinOccursAttrName
      if parent.type == 'all'
	if [ '0', '1' ].includes?( value )
	  @minOccurs = value
	else
	  raise WSDLParser::AttrConstraintError.new(
	    "Cannot parse #{ value } for #{ attr }." )
	end
      elsif parent.type == 'sequence'
	@maxOccurs = value
      else
	raise NotImplementedError.new
      end
    when NillableAttrName
      @nillable = ( value == 'true' )
    else
      raise WSDLParser::UnknownAttributeError.new( "Unknown attr #{ attr }." )
    end
  end

=begin
private

  def getParentComplexType
    parent.parent
  end
  
  def createAnonymousTypeName
    base = capitalize( @name )
    begin
      if getParentComplexType.isAnonymousType
	base = capitalize( getParentComplexType.parent.name.name ) + base
      else
	base = capitalize( getParentComplexType.name.name ) + base
      end
    end while getParentComplexType.isAnonymousType
    base + 'Type'
  end

  def capitalize( target )
    target.gsub( /^([a-z])/ ) { $1.tr!( '[a-z]', '[A-Z]' ) }
  end
=end
end

  end
end
