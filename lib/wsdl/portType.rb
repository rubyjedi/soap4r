=begin
WSDL4R - WSDL portType definition.
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


class PortType < Info
  attr_reader :name		# required
  attr_reader :operations

  def targetNamespace
    parent.targetNamespace
  end

  def initialize
    super
    @name = nil
    @operations = NamedElements.new
  end

  def getBinding
    root.bindings.find { | item | item.type == @name }
  end

  def getLocations
    bindingName = getBinding.name
    result = []
    root.services.each do | service |
      service.ports.each do | port |
        if port.binding == bindingName
          result << port.soapAddress.location if port.soapAddress
        end
      end
    end
    result
  end

  OperationName = XSD::QName.new( Namespace, 'operation' )
  def parseElement( element )
    case element
    when OperationName
      o = Operation.new
      @operations << o
      o
    when DocumentationName
      o = Documentation.new
      o
    else
      nil
    end
  end

  NameAttrName = XSD::QName.new( nil, 'name' )
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
