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
  attr_reader :name
  attr_reader :targetNamespace
  attr_reader :imports

  # Overrides Info#root
  def root
    @root
  end

  def root=( newRoot )
    @root = newRoot
  end

  def initialize
    super
    @name = nil
    @targetNamespace = nil
    @types = nil
    @imports = []
    @messages = NamedElements.new
    @portTypes = NamedElements.new
    @bindings = NamedElements.new
    @services = NamedElements.new

    @anonymousTypes = NamedElements.new
    @root = self
  end

  def setTargetNamespace( targetNamespace )
    @targetNamespace = targetNamespace
    if @name
      @name = XSD::QName.new( @targetNamespace, @name.name )
    end
  end

  def complexTypes
    result = @anonymousTypes.dup
    if @types
      result.concat( @types.schema.complexTypes )
    end
    @imports.each do | import |
      result.concat( import.content.complexTypes )
    end
    result
  end

  def addType( complexType )
    @anonymousTypes << complexType
  end

  def messages
    result = @messages.dup
    @imports.each do | import |
      result.concat( import.content.messages )
    end
    result
  end

  def portTypes
    result = @portTypes.dup
    @imports.each do | import |
      result.concat( import.content.portTypes )
    end
    result
  end

  def bindings
    result = @bindings.dup
    @imports.each do | import |
      result.concat( import.content.bindings )
    end
    result
  end

  def services
    result = @services.dup
    @imports.each do | import |
      result.concat( import.content.services )
    end
    result
  end

  def getMessage( name )
    message = @messages[ name ]
    return message if message
    @imports.each do | import |
      message = import.content.getMessage( name )
      return message if message
    end
    nil
  end

  def getPortType( name )
    portType = @portTypes[ name ]
    return portType if portType
    @imports.each do | import |
      portType = import.content.getPortType( name )
      return portType if portType
    end
    nil
  end

  def getBinding( name )
    binding = @bindings[ name ]
    return binding if binding
    @imports.each do | import |
      binding = import.content.getBinding( name )
      return binding if binding
    end
    nil
  end

  def getService( name )
    service = @services[ name ]
    return service if service
    @imports.each do | import |
      service = import.content.getService( name )
      return service if service
    end
    nil
  end

  def getPortTypeBinding( portTypeName )
    binding = @bindings.find { | item | item.type == portTypeName }
    return binding if binding
    @imports.each do | import |
      binding = import.content.getPortTypeBinding( portTypeName )
      return binding if binding
    end
    nil
  end

  def getComplexTypesWithMessages
    types = complexTypes
    messages.each do | message |
      type = XMLSchema::ComplexType.new
      type.setAnonymousTypeName( message.name )
      type.content = XMLSchema::Content.new( type )
      message.parts.each do | part |
	ele = XMLSchema::Element.new
	ele.name = part.name
	ele.type = part.type
	type.content.elements[ ele.name ] = ele
      end
      types << type
    end
    types
  end

  TypesName = XSD::QName.new( Namespace, 'types' )
  MessageName = XSD::QName.new( Namespace, 'message' )
  PortTypeName = XSD::QName.new( Namespace, 'portType' )
  BindingName = XSD::QName.new( Namespace, 'binding' )
  ServiceName = XSD::QName.new( Namespace, 'service' )
  ImportName = XSD::QName.new( Namespace, 'import' )
  def parseElement( element )
    case element
    when ImportName
      o = Import.new
      @imports << o
      o
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
    else
      nil
    end
  end

  NameAttrName = XSD::QName.new( nil, 'name' )
  TargetNamespaceAttrName = XSD::QName.new( nil, 'targetNamespace' )
  def parseAttr( attr, value )
    case attr
    when NameAttrName
      @name = XSD::QName.new( @targetNamespace, value )
    when TargetNamespaceAttrName
      setTargetNamespace( value )
    else
      raise UnknownAttributeError.new( "Unknown attr #{ attr }." )
    end
  end

  DefinitionsName = XSD::QName.new( Namespace, 'definitions' )
  def self.parseElement( element )
    if element == DefinitionsName
      Definitions.new
    else
      raise UnknownAttributeError.new( "Unknown attr #{ attr }." )
    end
  end

private

end


end
