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
  # Trying xsd:dateTime data to be recovered as aTime.  aDateTime if it fails.
  MarshalMappingRegistry = RPCUtils::MappingRegistry.new(
    :allowOriginalMapping => true
  )
  MarshalMappingRegistry.add(
    Time,
    ::SOAP::SOAPDateTime,
    ::SOAP::RPCUtils::MappingRegistry::DateTimeFactory
  )

  class << self
  public
    def dump( obj, io = nil )
      marshal( obj, MarshalMappingRegistry, io )
    end

    def load( stream )
      unmarshal( stream, MarshalMappingRegistry )
    end

    def marshal( obj, mappingRegistry = MarshalMappingRegistry, io = nil )
      elementName = RPCUtils.getElementNameFromName( obj.class.to_s )
      soapObj = RPCUtils.obj2soap( obj, mappingRegistry )
      body = SOAPBody.new
      body.add( elementName, soapObj )
      SOAP::Processor.marshal( nil, body, {}, io )
    end

    def unmarshal( stream, mappingRegistry = MarshalMappingRegistry )
      header, body = SOAP::Processor.unmarshal( stream )
      RPCUtils.soap2obj( body.rootNode, mappingRegistry )
    end
  end

end


end


SOAPMarshal = SOAP::Marshal
