# encoding: UTF-8
require 'helper'
require 'soap/processor'
require 'soap/rpc/driver'
require 'soap/rpc/router'


module SOAP


# Phase 0 of SOAP 1.2 support: SOAPVersion plumbing only, no visible
# behavior change yet. This is the regression pin for that guarantee --
# with soap_version left untouched anywhere, marshal/unmarshal must behave
# exactly as it did before SOAPVersion existed, since SOAPVersion1_1's
# envelope_namespace is built from the very same EnvelopeNamespace constant
# Parser/Proxy/Router already defaulted to.
class TestSoapVersionDefault < Test::Unit::TestCase
  def build_envelope
    header = SOAP::SOAPHeader.new
    body = SOAP::SOAPBody.new(SOAP::SOAPElement.new(XSD::QName.new("my:foo", "bodyitem"), 'bi'))
    SOAP::SOAPEnvelope.new(header, body)
  end

  def test_marshal_identical_with_or_without_explicit_soap_version_1_1
    implicit = SOAP::Processor.marshal(build_envelope, {})
    explicit = SOAP::Processor.marshal(build_envelope, :soap_version => SOAP::SOAPVersion1_1)
    assert_equal(implicit, explicit)
    assert_match(/xmlns:env="#{Regexp.escape(SOAP::EnvelopeNamespace)}"/, implicit)
  end

  def test_unmarshal_identical_with_or_without_explicit_soap_version_1_1
    xml = SOAP::Processor.marshal(build_envelope, {})
    implicit = SOAP::Processor.unmarshal(xml, {})
    explicit = SOAP::Processor.unmarshal(xml, :soap_version => SOAP::SOAPVersion1_1)
    assert_equal(SOAP::EnvelopeNamespace, implicit.elename.namespace)
    assert_equal(SOAP::EnvelopeNamespace, explicit.elename.namespace)
  end

  def test_parser_default_soap_version_is_1_1
    parser = SOAP::Parser.new
    assert_equal(SOAP::SOAPVersion1_1, parser.soap_version)
    assert_equal(SOAP::EnvelopeNamespace, parser.envelopenamespace)
  end

  def test_driver_proxy_soap_version_accessor_defaults_and_is_settable
    driver = SOAP::RPC::Driver.new("http://localhost:17171/")
    assert_equal(SOAP::SOAPVersion1_1, driver.soap_version)
    driver.soap_version = SOAP::SOAPVersion1_2
    assert_equal(SOAP::SOAPVersion1_2, driver.soap_version)
    assert_equal(SOAP::SOAPVersion1_2, driver.proxy.soap_version)
  end

  def test_router_soap_version_accessor_defaults_and_is_settable
    router = SOAP::RPC::Router.new('test_router')
    assert_equal(SOAP::SOAPVersion1_1, router.soap_version)
    router.soap_version = SOAP::SOAPVersion1_2
    assert_equal(SOAP::SOAPVersion1_2, router.soap_version)
  end
end


end
