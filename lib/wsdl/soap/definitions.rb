=begin
WSDL4R - WSDL additional definitions for SOAP.
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
  def getComplexTypesWithMessages
    types = complexTypes
    messages.each do | message |
      type = createComplexType( message.name )
      message.parts.each do | part |
	type.addElement( part.name, part.type )
      end
      types << type
    end
    types << arrayComplexType
    types << faultComplexType
    types
  end

private

  def arrayComplexType
    type = createComplexType( ::SOAP::ValueArrayName )
    type.complexContent = XMLSchema::ComplexContent.new
    type.complexContent.base = ::SOAP::ValueArrayName
    attr = XMLSchema::Attribute.new
    attr.ref = ::SOAP::AttrArrayTypeName
    anyTypeArray = XSD::XSDAnyType::Type.dup
    anyTypeArray.name += '[]'
    attr.arrayType = anyTypeArray
    type.complexContent.content.attributes << attr
    type
  end

  def faultComplexType
    type = createComplexType( ::SOAP::EleFaultName )
    type.addElement( ::SOAP::EleFaultCodeName.name, XSD::XSDString::Type )
    type.addElement( ::SOAP::EleFaultStringName.name, XSD::XSDString::Type )
    type.addElement( ::SOAP::EleFaultActorName.name, XSD::XSDString::Type )
    type.addElement( ::SOAP::EleFaultDetailName.name, XSD::XSDAnyType::Type )
    type
  end

  def createComplexType( typeQName )
    type = XMLSchema::ComplexType.new
    type.setAnonymousTypeName( typeQName )
    type
  end
end


end
