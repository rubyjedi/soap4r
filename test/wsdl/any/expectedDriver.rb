require 'echo.rb'

require 'soap/rpc/driver'

class Echo_port_type < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://localhost:10080"
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
      "urn:example.com:echo", "urn:example.com:echo", :rpc
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = MappingRegistry
    init_methods
  end

private

  def init_methods
    Methods.each do |name_as, name, params, soapaction, namespace, style|
      qname = ::XSD::QName.new(namespace, name_as)
      if style == :document
        @proxy.add_document_method(qname, soapaction, name, params)
        add_document_method_interface(name, name_as)
      else
        @proxy.add_rpc_method(qname, soapaction, name, params)
        add_rpc_method_interface(name, params)
      end
    end
  end
end

