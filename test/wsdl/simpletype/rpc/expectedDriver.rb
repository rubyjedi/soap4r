require 'echo_version.rb'

require 'soap/rpc/driver'

class Echo_version_port_type < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://localhost:10080"
  MappingRegistry = ::SOAP::Mapping::Registry.new

  MappingRegistry.set(
    Version_struct,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("urn:example.com:simpletype-rpc-type", "version_struct") }
  )
  
  Methods = [
    ["echo_version", "echo_version",
      [
        ["in", "version", [SOAP::SOAPString]],
        ["retval", "version_struct", [::SOAP::SOAPStruct, "urn:example.com:simpletype-rpc-type", "version_struct"]]
      ],
      "urn:example.com:simpletype-rpc", "urn:example.com:simpletype-rpc"
    ],
    ["echo_version_r", "echo_version_r",
      [
        ["in", "version_struct", [::SOAP::SOAPStruct, "urn:example.com:simpletype-rpc-type", "version_struct"]],
        ["retval", "version", [SOAP::SOAPString]]
      ],
      "urn:example.com:simpletype-rpc", "urn:example.com:simpletype-rpc"
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
    Methods.each do |name_as, name, params, soapaction, namespace|
      qname = XSD::QName.new(namespace, name_as)
      @proxy.add_method(qname, soapaction, name, params)
      add_rpc_method_interface(name, params)
    end
  end
end

