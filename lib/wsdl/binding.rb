=begin
WSDL4R - WSDL binding definition.
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


class Binding < Info
  attr_reader :name		# required
  attr_reader :type		# required
  attr_reader :operations
  attr_reader :soapBinding

  def initialize
    super
    @name = nil
    @type = nil
    @operations = NamedElements.new
    @soapBinding = nil
  end

  def targetNamespace
    parent.targetNamespace
  end

  OperationName = Name.new( Namespace, 'operation' )
  SOAPBindingName = Name.new( SOAPBindingNamespace, 'binding' )
  def parseElement( element )
    case element
    when OperationName
      o = OperationBinding.new
      @operations << o
      o
    when SOAPBindingName
      o = WSDL::SOAP::Binding.new
      @soapBinding = o
      o
    else
      raise WSDLParser::UnknownElementError.new(
	"Unknown element #{ element }." )
    end
  end

  NameAttrName = Name.new( nil, 'name' )
  TypeAttrName = Name.new( nil, 'type' )
  def parseAttr( attr, value )
    case attr
    when NameAttrName
      @name = Name.new( targetNamespace, value )
    when TypeAttrName
      @type = value
    else
      raise WSDLParser::UnknownAttributeError.new( "Unknown attr #{ attr }." )
    end
  end
end


end
