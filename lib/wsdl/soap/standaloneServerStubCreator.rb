=begin
WSDL4R - Creating standalone server stub code from WSDL.
Copyright (C) 2002, 2003  NAKAMURA, Hiroshi.

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
require 'wsdl/soap/mappingRegistryCreator'
require 'wsdl/soap/methodDefCreator'
require 'wsdl/soap/methodDefCreatorSupport'


module WSDL
module SOAP


class StandaloneServerStubCreator
  include MethodDefCreatorSupport

  attr_reader :definitions

  def initialize(definitions)
    @definitions = definitions
  end

  def dump(service_name)
    STDERR.puts "!!! IMPORTANT !!!"
    STDERR.puts "- Standalone stub can have only 1 port for now.  So creating stub for the first port and rests are ignored."
    STDERR.puts "- Standalone server stub ignores port location defined in WSDL.  Location is http://localhost:10080/ by default.  Generated client from WSDL must be configured to point this endpoint by hand."
    STDERR.puts "!!! IMPORTANT !!!"
    port = @definitions.service(service_name).ports[0]
    dump_porttype(port.porttype.name)
  end

private

  def dump_porttype(porttype)
    name = create_class_name(porttype)
    methoddef, types = MethodDefCreator.new(@definitions).dump(porttype)
    mr_creator = MappingRegistryCreator.new(@definitions)

    return <<__EOD__
require 'soap/rpc/standaloneServer'

class #{ name }
  MappingRegistry = SOAP::Mapping::Registry.new

#{ mr_creator.dump(types).gsub(/^/, "  ").chomp }
  Methods = [
#{ methoddef.gsub(/^/, "    ").chomp }
  ]
end

class App < SOAP::RPC::StandaloneServer
  def initialize(*arg)
    super

    servant = #{ name }.new
    #{ name }::Methods.each do |name_as, name, params, soapaction, namespace|
      qname = XSD::QName.new(namespace, name_as)
      @soaplet.app_scope_router.add_method(servant, qname, soapaction,
	name, params)
    end

    self.mapping_registry = #{ name }::MappingRegistry
  end
end

# Change listen port.
App.new('app', nil, '0.0.0.0', 10080).start
__EOD__
  end
end


end
end
