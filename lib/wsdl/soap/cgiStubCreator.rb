=begin
WSDL4R - Creating CGI stub code from WSDL.
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


class CGIStubCreator
  include MethodDefCreatorSupport

  attr_reader :definitions

  def initialize(definitions)
    @definitions = definitions
  end

  def dump(service_name)
    STDERR.puts "!!! IMPORTANT !!!"
    STDERR.puts "- CGI stub can only 1 port.  Creating stub for the first port...  Rests are ignored."
    STDERR.puts "!!! IMPORTANT !!!"
    port = @definitions.service(service_name).ports[0]
    dump_porttype(port.porttype.name)
  end

private

  def dump_porttype(name)
    class_name = create_class_name(name)
    method_def, types = MethodDefCreator.new(@definitions).dump(name)
    mr_creator = MappingRegistryCreator.new(@definitions)

    return <<__EOD__
require 'soap/rpc/cgistub'

class #{ class_name }
  require 'soap/rpcUtils'
  MappingRegistry = SOAP::Mapping::Registry.new

#{ mr_creator.dump(types).gsub(/^/, "  ").chomp }
  Methods = [
#{ method_def.gsub(/^/, "    ").chomp }
  ]
end

class App < SOAP::RPC::CGIStub
  def initialize(*arg)
    super(*arg)
    servant = #{ class_name }.new
    #{ class_name }::Methods.each do |name_as, name, params, soapaction, namespace|
      add_method_with_namespace_as(namespace, servant, name, name_as, params, soapaction)
    end

    self.mapping_registry = #{ class_name }::MappingRegistry
    self.sev_threshold = Devel::Logger::ERROR
  end
end

# Change listen port.
App.new('app', nil).start
__EOD__
  end
end


end
end
