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
require 'soap/rpcUtils'


module WSDL


class Definitions < Info
  def getComplexTypesWithMessages( portType )
    types = collectComplexTypes
    portType.operations.each do | operation |
      if operation.input
	message  = messages[ operation.input.message ]
	type = createComplexType( operation.input.name || operation.name )
	elements = message.parts.collect { | part |
	    XMLSchema::Element.new( part.name, part.type )
	  }
	type.setSequenceElements( elements )
	types << type
      end
      if operation.output
	message  = messages[ operation.output.message ]
	type = createComplexType( operation.output.name ||
	  XSD::QName.new( operation.name.namespace, operation.name.name + "Response" ))
	elements = message.parts.collect { | part |
	    XMLSchema::Element.new( part.name, part.type )
	  }
	type.setSequenceElements( elements )
	types << type
      end
    end
=begin
    messages.each do | message |
      type = createComplexType( message.name )
      elements = message.parts.collect { | part |
	  XMLSchema::Element.new( part.name, part.type )
	}
      type.setSequenceElements( elements )
      types << type
    end
=end
    types << arrayComplexType
    types << faultComplexType
    types << exceptionComplexType
    types
  end

private

  def arrayComplexType
    type = createComplexType( ::SOAP::ValueArrayName )
    type.complexContent = XMLSchema::ComplexContent.new
    type.complexContent.base = ::SOAP::ValueArrayName
    attr = XMLSchema::Attribute.new
    attr.ref = ::SOAP::AttrArrayTypeName
    anyTypeArray = XSD::AnyTypeName.dup
    anyTypeArray.name += '[]'
    attr.arrayType = anyTypeArray
    type.complexContent.attributes << attr
    type
  end

=begin
<xs:complexType name="Fault" final="extension">
  <xs:sequence>
    <xs:element name="faultcode" type="xs:QName" /> 
    <xs:element name="faultstring" type="xs:string" /> 
    <xs:element name="faultactor" type="xs:anyURI" minOccurs="0" /> 
    <xs:element name="detail" type="tns:detail" minOccurs="0" /> 
  </xs:sequence>
</xs:complexType>
=end
  def faultComplexType
    type = createComplexType( ::SOAP::EleFaultName )
    faultcode = XMLSchema::Element.new( ::SOAP::EleFaultCodeName.name,
      XSD::XSDQName::Type )
    faultstring = XMLSchema::Element.new( ::SOAP::EleFaultStringName.name,
      XSD::XSDString::Type )
    faultactor = XMLSchema::Element.new( ::SOAP::EleFaultActorName.name,
      XSD::XSDAnyURI::Type )
    faultactor.minOccurs = 0
    detail = XMLSchema::Element.new( ::SOAP::EleFaultDetailName.name,
      XSD::AnyTypeName )
    detail.minOccurs = 0
    type.setAllElements( [ faultcode, faultstring, faultactor, detail ] )
    type.content.final = 'extension'
    type
  end

  def exceptionComplexType
    type = createComplexType( XSD::QName.new(
      ::SOAP::RPCUtils::RubyCustomTypeNamespace, 'SOAPException' ))
    exceptionTypeName = XMLSchema::Element.new( 'exceptionTypeName',
      XSD::XSDString::Type )
    cause = XMLSchema::Element.new( 'cause', XSD::AnyTypeName )
    backtrace = XMLSchema::Element.new( 'backtrace', ::SOAP::ValueArrayName )
    message = XMLSchema::Element.new( 'message', XSD::XSDString::Type )
    type.setAllElements( [ exceptionTypeName, cause, backtrace, message ] )
    type
  end

  def createComplexType( typeQName )
    XMLSchema::ComplexType.new( typeQName )
  end
end


end
