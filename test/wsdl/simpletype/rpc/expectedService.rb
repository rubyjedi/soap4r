#!/usr/bin/env ruby
require 'echo_versionServant.rb'

require 'soap/rpc/standaloneServer'

class Echo_version_port_type
  MappingRegistry = SOAP::Mapping::Registry.new

  MappingRegistry.set(
    Version_struct,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("urn:example.com:simpletype-rpc-type", "version_struct") }
  )


  Methods = [
    ["echo_version", "echo_version", [
      ["in", "version",
       [SOAP::SOAPString]],
      ["retval", "version_struct",
       [::SOAP::SOAPStruct, "urn:example.com:simpletype-rpc-type", "version_struct"]]], "urn:example.com:simpletype-rpc", "urn:example.com:simpletype-rpc"]
  ]
end

class Echo_version_port_typeApp < SOAP::RPC::StandaloneServer
  def initialize(*arg)
    super

    servant = Echo_version_port_type.new
    Echo_version_port_type::Methods.each do |name_as, name, params, soapaction, namespace|
      qname = XSD::QName.new(namespace, name_as)
      @soaplet.app_scope_router.add_method(servant, qname, soapaction,
	name, params)
    end

    self.mapping_registry = Echo_version_port_type::MappingRegistry
  end
end

# Change listen port.
if $0 == __FILE__
  Echo_version_port_typeApp.new('app', nil, '0.0.0.0', 10080).start
end
