=begin
WSDL4R - WSDL port definition.
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


class Port < Info
  attr_reader :name		# required
  attr_reader :binding	# required
  attr_reader :soapAddress

  def initialize
    super
    @name = nil
    @binding = nil
    @soapAddress = nil
  end

  def targetNamespace
    parent.targetNamespace
  end

  def getPortType
    root.getPortType( getBinding.type )
  end

  def getBinding
    root.getBinding( @binding )
  end

  def createInputOperationMap
    result = {}
    getBinding.operations.each do | operationBinding |
      operationName, messageName, parts, soapAction =
	operationBinding.inputOperationInfo
      result[ operationName ] = [ messageName, parts, soapAction ]
    end
    result
  end

  def createOutputOperationMap
    result = {}
    getBinding.operations.each do | operationBinding |
      operationName, messageName, parts = operationBinding.outputOperationInfo
      result[ operationName ] = [ messageName, parts ]
    end
    result
  end

  SOAPAddressName = XSD::QName.new( SOAPBindingNamespace, 'address' )
  def parseElement( element )
    case element
    when SOAPAddressName
      o = WSDL::SOAP::Address.new
      @soapAddress = o
      o
    when DocumentationName
      o = Documentation.new
      o
    else
      nil
    end
  end

  NameAttrName = XSD::QName.new( nil, 'name' )
  BindingAttrName = XSD::QName.new( nil, 'binding' )
  def parseAttr( attr, value )
    case attr
    when NameAttrName
      @name = XSD::QName.new( targetNamespace, value )
    when BindingAttrName
      @binding = value
    else
      raise WSDLParser::UnknownAttributeError.new( "Unknown attr #{ attr }." )
    end
  end
end


end
