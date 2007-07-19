require 'echo_version.rb'
require 'soap/mapping'

module Echo_versionMappingRegistry
  EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
  LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new
  NsSimpletypeRpcType = "urn:example.com:simpletype-rpc-type"

  EncodedRegistry.register(
    :class => Version_struct,
    :schema_ns => "urn:example.com:simpletype-rpc-type",
    :schema_type => "version_struct",
    :schema_element => [
      ["version", ["Version", XSD::QName.new(nil, "version")]],
      ["msg", ["SOAP::SOAPString", XSD::QName.new(nil, "msg")]]
    ]
  )

  EncodedRegistry.register(
    :class => Version,
    :schema_ns => NsSimpletypeRpcType,
    :schema_type => "version"
  )

  EncodedRegistry.register(
    :class => StateType,
    :schema_ns => NsSimpletypeRpcType,
    :schema_type => "stateType"
  )

  EncodedRegistry.register(
    :class => ZipIntType,
    :schema_ns => NsSimpletypeRpcType,
    :schema_type => "zipIntType"
  )

  LiteralRegistry.register(
    :class => Version_struct,
    :schema_ns => NsSimpletypeRpcType,
    :schema_type => "version_struct",
    :schema_qualified => false,
    :schema_element => [
      ["version", ["Version", XSD::QName.new(nil, "version")]],
      ["msg", ["SOAP::SOAPString", XSD::QName.new(nil, "msg")]]
    ]
  )

  LiteralRegistry.register(
    :class => Version,
    :schema_ns => NsSimpletypeRpcType,
    :schema_type => "version"
  )

  LiteralRegistry.register(
    :class => StateType,
    :schema_ns => NsSimpletypeRpcType,
    :schema_type => "stateType"
  )

  LiteralRegistry.register(
    :class => ZipIntType,
    :schema_ns => NsSimpletypeRpcType,
    :schema_type => "zipIntType"
  )
end
