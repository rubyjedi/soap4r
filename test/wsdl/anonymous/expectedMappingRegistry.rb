require 'lp.rb'
require 'soap/mapping'

module WSDL; module Anonymous

module LpMappingRegistry
  EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
  LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new
  NsLp = "urn:lp"

  EncodedRegistry.register(
    :class => WSDL::Anonymous::LoginResponse,
    :schema_ns => NsLp,
    :schema_type => "loginResponse",
    :schema_element => [
      ["loginResult", ["WSDL::Anonymous::LoginResponse::LoginResult", XSD::QName.new(nil, "loginResult")]]
    ]
  )

  EncodedRegistry.register(
    :class => WSDL::Anonymous::LoginResponse::LoginResult,
    :schema_ns => nil,
    :schema_name => "loginResult",
    :schema_element => [
      ["sessionID", "SOAP::SOAPString"]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::LoginResponse,
    :schema_ns => NsLp,
    :schema_type => "loginResponse",
    :schema_qualified => false,
    :schema_element => [
      ["loginResult", ["WSDL::Anonymous::LoginResponse::LoginResult", XSD::QName.new(nil, "loginResult")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::LoginResponse::LoginResult,
    :schema_ns => nil,
    :schema_name => "loginResult",
    :schema_qualified => false,
    :schema_element => [
      ["sessionID", "SOAP::SOAPString"]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::Login,
    :schema_ns => NsLp,
    :schema_name => "login",
    :schema_qualified => true,
    :schema_element => [
      ["loginRequest", ["WSDL::Anonymous::Login::LoginRequest", XSD::QName.new(nil, "loginRequest")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::Login::LoginRequest,
    :schema_ns => nil,
    :schema_name => "loginRequest",
    :schema_qualified => true,
    :schema_element => [
      ["username", "SOAP::SOAPString"],
      ["password", "SOAP::SOAPString"],
      ["timezone", "SOAP::SOAPString", [0, 1]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::LoginResponse,
    :schema_ns => NsLp,
    :schema_name => "loginResponse",
    :schema_qualified => true,
    :schema_element => [
      ["loginResult", ["WSDL::Anonymous::LoginResponse::LoginResult", XSD::QName.new(nil, "loginResult")]]
    ]
  )

  LiteralRegistry.register(
    :class => WSDL::Anonymous::LoginResponse::LoginResult,
    :schema_ns => nil,
    :schema_name => "loginResult",
    :schema_qualified => true,
    :schema_element => [
      ["sessionID", "SOAP::SOAPString"]
    ]
  )
end

end; end
