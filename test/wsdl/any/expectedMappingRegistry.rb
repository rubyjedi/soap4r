require 'echo.rb'
require 'soap/mapping'

module WSDL; module Any

module EchoMappingRegistry
  EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
  LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new
  NsEchoType = "urn:example.com:echo-type"
  NsXMLSchema = "http://www.w3.org/2001/XMLSchema"

  EncodedRegistry.register(
    :class => WSDL::Any::FooBar,
    :schema_ns => NsEchoType,
    :schema_type => "foo.bar",
    :schema_element => [
      ["before", ["SOAP::SOAPString", XSD::QName.new(nil, "before")]],
      ["any", [nil, XSD::QName.new(NsXMLSchema, "anyType")]],
      ["after", ["SOAP::SOAPString", XSD::QName.new(nil, "after")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Any::FooBar,
    :schema_ns => NsEchoType,
    :schema_type => "foo.bar",
    :schema_qualified => false,
    :schema_element => [
      ["before", ["SOAP::SOAPString", XSD::QName.new(nil, "before")]],
      ["any", [nil, XSD::QName.new(NsXMLSchema, "anyType")]],
      ["after", ["SOAP::SOAPString", XSD::QName.new(nil, "after")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Any::FooBar,
    :schema_ns => NsEchoType,
    :schema_name => "foo.bar",
    :schema_qualified => true,
    :schema_element => [
      ["before", ["SOAP::SOAPString", XSD::QName.new(nil, "before")]],
      ["any", [nil, XSD::QName.new(NsXMLSchema, "anyType")]],
      ["after", ["SOAP::SOAPString", XSD::QName.new(nil, "after")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Any::SetOutputAndCompleteRequest,
    :schema_ns => NsEchoType,
    :schema_name => "setOutputAndCompleteRequest",
    :schema_qualified => true,
    :schema_element => [
      ["taskId", ["SOAP::SOAPString", XSD::QName.new(nil, "taskId")]],
      ["data", [nil, XSD::QName.new(nil, "data")]],
      ["participantToken", ["SOAP::SOAPString", XSD::QName.new(nil, "participantToken")]]
    ]
  )
end

end; end
