=begin
WSDL4R - WSDL part definition.
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


class Part < Info
  attr_reader :name	# required
  attr_reader :element	# optional
  attr_reader :type	# optional

  def initialize
    super
    @name = nil
    @element = nil
    @type = nil
  end

  def parseElement( element )
    nil
  end

  NameAttrName = XSD::QName.new( nil, 'name' )
  ElementAttrName = XSD::QName.new( nil, 'element' )
  TypeAttrName = XSD::QName.new( nil, 'type' )
  def parseAttr( attr, value )
    case attr
    when NameAttrName
      @name = value
    when ElementAttrName
      @element = value
    when TypeAttrName
      @type = value
    else
      raise WSDLParser::UnknownAttributeError.new( "Unknown attr #{ attr }." )
    end
  end
end


end
