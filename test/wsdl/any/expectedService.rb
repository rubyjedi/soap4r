#!/usr/bin/env ruby
require 'echoServant.rb'

require 'soap/rpc/standaloneServer'
require 'soap/mapping/registry'

class Echo_port_type
  MappingRegistry = ::SOAP::Mapping::Registry.new

  MappingRegistry.set(
    FooBar,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => ::XSD::QName.new("urn:example.com:echo-type", "foo.bar") }
  )
  
  Methods = [
    ["echo", "echo",
      [
        ["in", "echoitem", [::SOAP::SOAPStruct, "urn:example.com:echo-type", "foo.bar"]],
        ["retval", "echoitem", [::SOAP::SOAPStruct, "urn:example.com:echo-type", "foo.bar"]]
      ],
      "urn:example.com:echo", "urn:example.com:echo"
    ]
  ]
end

class Echo_port_typeApp < ::SOAP::RPC::StandaloneServer
  def initialize(*arg)
    super(*arg)
    servant = Echo_port_type.new
    Echo_port_type::Methods.each do |name_as, name, params, soapaction, ns|
      qname = XSD::QName.new(ns, name_as)
      @soaplet.app_scope_router.add_method(servant, qname, soapaction, name, params)
    end
    self.mapping_registry = Echo_port_type::MappingRegistry
  end
end

if $0 == __FILE__
  # Change listen port.
  Echo_port_typeApp.new('app', nil, '0.0.0.0', 10080).start
end
