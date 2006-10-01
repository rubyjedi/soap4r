#!/usr/bin/env ruby
require 'echo_versionServant.rb'
require 'echo_versionMappingRegistry.rb'
require 'soap/rpc/cgistub'

class Echo_version_port_type
  Methods = [
    [ XSD::QName.new("urn:example.com:simpletype-rpc", "echo_version"),
      "urn:example.com:simpletype-rpc",
      "echo_version",
      [ ["in", "version", ["::SOAP::SOAPString"]],
        ["retval", "version_struct", ["Version_struct", "urn:example.com:simpletype-rpc-type", "version_struct"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded }
    ],
    [ XSD::QName.new("urn:example.com:simpletype-rpc", "echo_version_r"),
      "urn:example.com:simpletype-rpc",
      "echo_version_r",
      [ ["in", "version_struct", ["Version_struct", "urn:example.com:simpletype-rpc-type", "version_struct"]],
        ["retval", "version", ["::SOAP::SOAPString"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded }
    ]
  ]
end

class Echo_version_port_typeApp < ::SOAP::RPC::CGIStub
  def initialize(*arg)
    super(*arg)
    servant = Echo_version_port_type.new
    Echo_version_port_type::Methods.each do |definitions|
      opt = definitions.last
      if opt[:request_style] == :document
        @router.add_document_operation(servant, *definitions)
      else
        @router.add_rpc_operation(servant, *definitions)
      end
    end
    self.mapping_registry = Echo_versionMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = Echo_versionMappingRegistry::LiteralRegistry
    self.level = Logger::Severity::ERROR
  end
end
Echo_version_port_typeApp.new('app', nil).start
