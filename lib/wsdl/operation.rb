=begin
WSDL4R - WSDL operation definition.
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


class Operation < Info
  attr_reader :name		# required
  attr_reader :parameterOrder	# optional
  attr_reader :input
  attr_reader :output
  attr_reader :fault
  attr_reader :type		# required

  def initialize
    super
    @name = nil
    @type = nil
    @parameterOrder = nil
    @input = nil
    @output = nil
    @fault = nil
  end

  def targetNamespace
    parent.targetNamespace
  end

  InputName = XSD::QName.new( Namespace, 'input' )
  OutputName = XSD::QName.new( Namespace, 'output' )
  FaultName = XSD::QName.new( Namespace, 'fault' )
  def parseElement( element )
    case element
    when InputName
      o = Param.new
      @input = o
      o
    when OutputName
      o = Param.new
      @output = o
      o
    when FaultName
      o = Param.new
      @fault = o
      o
    else
      nil
    end
  end

  NameAttrName = XSD::QName.new( nil, 'name' )
  TypeAttrName = XSD::QName.new( nil, 'type' )
  ParameterOrderName = XSD::QName.new( nil, 'parameterOrder' )
  def parseAttr( attr, value )
    case attr
    when NameAttrName
      @name = XSD::QName.new( targetNamespace, value )
    when TypeAttrName
      @type = value
    when ParameterOrderName
      @parameterOrder = value.split( /\s+/ )
    else
      raise WSDLParser::UnknownAttributeError.new( "Unknown attr #{ attr }." )
    end
  end
end


end
