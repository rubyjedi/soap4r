=begin
SOAP4R - Marshalling/Unmarshalling Ruby's object using SOAP Encoding.
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

# The original version of the marshal.rb to marshal/unmarshal Ruby's object
# using SOAP Encoding was written by Michael Neumann.  His valuable comments
# and his program inspired me to write this.  Thanks.

require "soap/rpcUtils"
require "soap/processor"


module SOAP


module Marshal
  MarshalMappingRegistry = RPCUtils::MappingRegistry.new
  MarshalMappingRegistry.set(
    Time,
    ::SOAP::SOAPDateTime,
    ::SOAP::RPCUtils::MappingRegistry::DateTimeFactory
  )

  def Marshal.marshal( obj, mappingRegistry = MarshalMappingRegistry )
    elementName = RPCUtils.getElementNameFromName( obj.type.to_s )
    soapObj = RPCUtils.obj2soap( obj, mappingRegistry )
    body = SOAPBody.new
    body.add( elementName, soapObj )
    SOAP::Processor.marshal( nil, body )
  end

  def Marshal.unmarshal( str, mappingRegistry = MarshalMappingRegistry )
    header, body = SOAP::Processor.unmarshal( str )
    RPCUtils.soap2obj( body.rootNode, mappingRegistry )
  end

end


end
