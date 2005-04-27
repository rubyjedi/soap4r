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
    { :type => XSD::QName.new("urn:example.com:echo-type", "foo.bar") }
  )

  Methods = [
    ["echo", "echo",
      [
        ["in", "echoitem", [FooBar, "urn:example.com:echo-type", "foo.bar"]],
        ["retval", "echoitem", [FooBar, "urn:example.com:echo-type", "foo.bar"]]
      ],
      "urn:example.com:echo", "urn:example.com:echo", :rpc
    ]
  ]
end

class Echo_port_typeApp < ::SOAP::RPC::StandaloneServer
  def initialize(*arg)
    super(*arg)
    servant = Echo_port_type.new
    Echo_port_type::Methods.each do |name_as, name, param_def, soapaction, namespace, style|
      if style == :document
        @router.add_document_operation(servant, soapaction, name, param_def)
      else
        qname = XSD::QName.new(namespace, name_as)
        @router.add_rpc_operation(servant, qname, soapaction, name, param_def)
      end
    end
    self.mapping_registry = Echo_port_type::MappingRegistry
  end
end

if $0 == __FILE__
  # Change listen port.
  server = Echo_port_typeApp.new('app', nil, '0.0.0.0', 10080)
  trap(:INT) do
    server.shutdown
  end
  server.start
end
