#!/usr/bin/env ruby
require 'echo_versionServant.rb'

require 'soap/rpc/cgistub'
require 'soap/mapping/registry'

class Echo_version_port_type
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
        ["in", "version", [::SOAP::SOAPString]],
        ["retval", "version_struct", [Version_struct, "urn:example.com:simpletype-rpc-type", "version_struct"]]
      ],
      "urn:example.com:simpletype-rpc", "urn:example.com:simpletype-rpc", :rpc
    ],
    ["echo_version_r", "echo_version_r",
      [
        ["in", "version_struct", [Version_struct, "urn:example.com:simpletype-rpc-type", "version_struct"]],
        ["retval", "version", [::SOAP::SOAPString]]
      ],
      "urn:example.com:simpletype-rpc", "urn:example.com:simpletype-rpc", :rpc
    ]
  ]
end

class Echo_version_port_typeApp < ::SOAP::RPC::CGIStub
  def initialize(*arg)
    super(*arg)
    servant = Echo_version_port_type.new
    Echo_version_port_type::Methods.each do |name_as, name, param_def, soapaction, namespace, style|
      if style == :document
        @router.add_document_operation(servant, soapaction, name, param_def)
      else
        qname = XSD::QName.new(namespace, name_as)
        @router.add_rpc_operation(servant, qname, soapaction, name, param_def)
      end
    end
    self.mapping_registry = Echo_version_port_type::MappingRegistry
    self.level = Logger::Severity::ERROR
  end
end
Echo_version_port_typeApp.new('app', nil).start
