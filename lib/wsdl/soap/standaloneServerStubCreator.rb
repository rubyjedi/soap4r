# WSDL4R - Creating standalone server stub code from WSDL.
# Copyright (C) 2002, 2003  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


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
    mr = mr_creator.dump(types)
    if mr.empty?
      mr = "# No mapping definition"
    end
    mr.gsub!(/^/, "  ")

    return <<__EOD__
require 'soap/rpc/standaloneServer'

class #{ name }
  MappingRegistry = SOAP::Mapping::Registry.new

#{ mr }

  Methods = [
#{ methoddef.gsub(/^/, "    ").chomp }
  ]
end

class #{name}App < SOAP::RPC::StandaloneServer
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
if $0 == __FILE__
  #{name}App.new('app', nil, '0.0.0.0', 10080).start
end
__EOD__
  end
end


end
end
