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
  def soap_complextypes(porttype)
    types = collect_complextypes
    porttype.operations.each do |operation|
      if operation.input
	message  = messages[operation.input.message]
	type = XMLSchema::ComplexType.new(operation.input.name || operation.name)
	elements = message.parts.collect { |part|
	    XMLSchema::Element.new(part.name, part.type)
	  }
	type.sequence_elements = elements
	types << type
      end
      if operation.output
	message  = messages[operation.output.message]
	type = XMLSchema::ComplexType.new(operation.output.name ||
	  XSD::QName.new(operation.name.namespace, operation.name.name + "Response"))
	elements = message.parts.collect { |part|
	    XMLSchema::Element.new(part.name, part.type)
	  }
	type.sequence_elements = elements
	types << type
      end
    end
=begin
    messages.each do |message|
      type = XMLSchema::ComplexType.new(message.name)
      elements = message.parts.collect { |part|
	  XMLSchema::Element.new(part.name, part.type)
	}
      type.sequence_elements = elements
      types << type
    end
=end
    types << array_complextype
    types << fault_complextype
    types << exception_complextype
    types
  end

private

  def array_complextype
    type = XMLSchema::ComplexType.new(::SOAP::ValueArrayName)
    type.complexcontent = XMLSchema::ComplexContent.new
    type.complexcontent.base = ::SOAP::ValueArrayName
    attr = XMLSchema::Attribute.new
    attr.ref = ::SOAP::AttrArrayTypeName
    anytype = XSD::AnyTypeName.dup
    anytype.name += '[]'
    attr.arytype = anytype
    type.complexcontent.attributes << attr
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
  def fault_complextype
    type = XMLSchema::ComplexType.new(::SOAP::EleFaultName)
    faultcode = XMLSchema::Element.new(::SOAP::EleFaultCodeName.name,
      XSD::XSDQName::Type)
    faultstring = XMLSchema::Element.new(::SOAP::EleFaultStringName.name,
      XSD::XSDString::Type)
    faultactor = XMLSchema::Element.new(::SOAP::EleFaultActorName.name,
      XSD::XSDAnyURI::Type)
    faultactor.minoccurs = 0
    detail = XMLSchema::Element.new(::SOAP::EleFaultDetailName.name,
      XSD::AnyTypeName)
    detail.minoccurs = 0
    type.all_elements = [faultcode, faultstring, faultactor, detail]
    type.content.final = 'extension'
    type
  end

  def exception_complextype
    type = XMLSchema::ComplexType.new(XSD::QName.new(
	::SOAP::RPCUtils::RubyCustomTypeNamespace, 'SOAPException'))
    excn_name = XMLSchema::Element.new('exceptionTypeName', XSD::XSDString::Type)
    cause = XMLSchema::Element.new('cause', XSD::AnyTypeName)
    backtrace = XMLSchema::Element.new('backtrace', ::SOAP::ValueArrayName)
    message = XMLSchema::Element.new('message', XSD::XSDString::Type)
    type.all_elements = [excn_name, cause, backtrace, message]
    type
  end
end


end
