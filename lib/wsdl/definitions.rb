=begin
WSDL4R - WSDL definitions.
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


class Definitions < Info
  attr_reader :name		# optional
  attr_reader :targetNamespace	# optional
  attr_reader :types
  attr_reader :messages
  attr_reader :portTypes
  attr_reader :bindings
  attr_reader :services

  def initialize
    super
    @name = nil
    @targetNamespace = nil
    @types = nil
    @messages = NamedElements.new
    @portTypes = NamedElements.new
    @bindings = NamedElements.new
    @services = NamedElements.new
  end

  def getPortTypeBinding( portTypeName )
    @bindings.each do | binding |
      if ( binding.type == portTypeName )
	return binding
      end
    end
    nil
  end

  TypesName = Name.new( Namespace, 'types' )
  MessageName = Name.new( Namespace, 'message' )
  PortTypeName = Name.new( Namespace, 'portType' )
  BindingName = Name.new( Namespace, 'binding' )
  ServiceName = Name.new( Namespace, 'service' )
  def parseElement( element )
    case element
    when TypesName
      o = Types.new
      @types = o
      o
    when MessageName
      o = Message.new
      @messages << o
      o
    when PortTypeName
      o = PortType.new
      @portTypes << o
      o
    when BindingName
      o = Binding.new
      @bindings << o
      o
    when ServiceName
      o = Service.new
      @services << o
      o
    end
  end

  NameAttrName = Name.new( nil, 'name' )
  TargetNamespaceAttrName = Name.new( nil, 'targetNamespace' )
  def parseAttr( attr, value )
    case attr
    when NameAttrName
      @name = Name.new( @targetNamespace, value )
    when TargetNamespaceAttrName
      @targetNamespace = value
      if @name
	@name = Name.new( @targetNamespace, @name.name )
      end
    else
      raise UnknownElementError.new( "Unknown element #{ element }." )
    end
  end

  DefinitionsName = Name.new( Namespace, 'definitions' )
  def self.parseElement( element )
    if element == DefinitionsName
      Definitions.new
    else
      raise UnknownAttributeError.new( "Unknown attr #{ attr }." )
    end
  end
end


end
