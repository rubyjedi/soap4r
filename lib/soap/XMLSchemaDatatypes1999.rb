=begin
SOAP4R - XML Schema Datatype 1999 support
Copyright (C) 2001 NAKAMURA Hiroshi.

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


require 'soap/XMLSchemaDatatypes'

module XSD
  Namespace = 'http://www.w3.org/1999/XMLSchema'
  InstanceNamespace = 'http://www.w3.org/1999/XMLSchema-instance'
  AnyTypeLiteral = 'ur-type'
  NilLiteral = 'null'
  NilValue = '1'
  DateTimeLiteral = 'timeInstant'
end

module SOAP
  class SOAPEncodingStyleHandlerDynamic < EncodingStyleHandler
    XSDBaseTypeMap = {
      XSD::DecimalLiteral => SOAPDecimal,
      XSD::IntegerLiteral => SOAPInteger,
      XSD::LongLiteral => SOAPLong,
      XSD::IntLiteral => SOAPInt,
      XSD::FloatLiteral => SOAPFloat,
      XSD::DoubleLiteral => SOAPDouble,
      XSD::BooleanLiteral => SOAPBoolean,
      XSD::StringLiteral => SOAPString,
      XSD::DateTimeLiteral => SOAPDateTime,
      XSD::Base64BinaryLiteral => SOAPBase64,
    }
  end
end
