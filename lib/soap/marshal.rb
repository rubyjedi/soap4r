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

  def Marshal.marshal( obj, mappingRegistry = RPCUtils::MappingRegistry.new )
    elementName = RPCUtils.getElementNameFromName( obj.type.to_s )
    soapObj = RPCUtils.obj2soap( obj, mappingRegistry )
    soapObj.name = elementName
    generator = SOAPGenerator.new
    Processor.xmlDecl + generator.generate( soapObj )
  end

  def Marshal.unmarshal( str, mappingRegistry = RPCUtils::MappingRegistry.new, parser = Processor.loadParser )
    RPCUtils.soap2obj( parser.parse( str ), mappingRegistry )
  end

end


end
