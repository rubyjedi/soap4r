#!/usr/bin/env ruby
require 'echoServant.rb'

require 'soap/rpc/standaloneServer'
require 'soap/mapping/registry'

class Echo_port_type
  MappingRegistry = ::SOAP::Mapping::EncodedRegistry.new

  Methods = [
    [ "urn:example.com:echo",
      "echo",
      [ ["in", "parameters", ["::SOAP::SOAPElement", "urn:example.com:echo-type", "foo.bar"]],
        ["out", "parameters", ["::SOAP::SOAPElement", "urn:example.com:echo-type", "foo.bar"]] ],
      { :request_style =>  :document, :request_use =>  :literal,
        :response_style => :document, :response_use => :literal }
    ]
  ]
end

class Echo_port_typeApp < ::SOAP::RPC::StandaloneServer
  def initialize(*arg)
    super(*arg)
    servant = Echo_port_type.new
    Echo_port_type::Methods.each do |definitions|
      opt = definitions.last
      if opt[:request_style] == :document
        @router.add_document_operation(servant, *definitions)
      else
        @router.add_rpc_operation(servant, *definitions)
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
