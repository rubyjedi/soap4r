require 'echo_version.rb'

require 'soap/rpc/driver'

class Echo_version_port_type < SOAP::RPC::Driver
  MappingRegistry = ::SOAP::Mapping::Registry.new

  
  Methods = [
    ["echo_version", "echo_version", [
      ["in", "version",
       [SOAP::SOAPString]],
      ["retval", "version",
       [SOAP::SOAPString]]], "urn:example.com:simpletype-rpc", "urn:example.com:simpletype-rpc"]
  ]

  DefaultEndpointUrl = "http://localhost"

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

