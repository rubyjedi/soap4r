=begin
WSDL4R - XMLSchema element definition for WSDL.
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
  module XMLSchema


class Element < Info
  attr_accessor :name	# required
  attr_accessor :type
  attr_accessor :local_complextype
  attr_accessor :maxoccurs
  attr_accessor :minoccurs
  attr_accessor :nillable

  def initialize(name = nil, type = XSD::AnyTypeName)
    super()
    @name = name
    @type = type
    @local_complextype = nil
    @maxoccurs = 1
    @minoccurs = 1
    @nillable = nil
  end

  def targetnamespace
    parent.targetnamespace
  end

  def parse_element(element)
    case element
    when ComplexTypeName
      @type = nil
      @local_complextype = ComplexType.new
      @local_complextype
    else
      nil
    end
  end

  def parse_attr(attr, value)
    case attr
    when NameAttrName
      @name = value
    when TypeAttrName
      @type = if value.is_a?(XSD::QName)
	  value
	else
	  XSD::QName.new(XSD::Namespace, value)
	end
    when MaxOccursAttrName
      if parent.type == 'all'
	if value != '1'
	  raise WSDLParser::AttrConstraintError.new(
	    "Cannot parse #{ value } for #{ attr }.")
	end
	@maxoccurs = value
      elsif parent.type == 'sequence'
	@maxoccurs = value
      else
	raise NotImplementedError.new
      end
    when MinOccursAttrName
      if parent.type == 'all'
	if ['0', '1'].include?(value)
	  @minoccurs = value
	else
	  raise WSDLParser::AttrConstraintError.new(
	    "Cannot parse #{ value } for #{ attr }.")
	end
      elsif parent.type == 'sequence'
	@maxoccurs = value
      else
	raise NotImplementedError.new
      end
    when NillableAttrName
      @nillable = (value == 'true')
    else
      raise WSDLParser::UnknownAttributeError.new("Unknown attr #{ attr }.")
    end
  end
end

  end
end
