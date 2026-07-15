# encoding: UTF-8
require 'helper'
require 'soap/processor'


module SOAP


# Phase 1 of SOAP 1.2 support: envelope/header/body namespace switching via
# SOAPVersion1_2, no fault shape yet (that's Phase 2) and no HTTP transport
# changes yet (Phase 3). Fault-less SOAP 1.2 messages should already
# round-trip correctly through Processor.marshal/unmarshal at this point.
class TestSoap12EnvelopeRoundtrip < Test::Unit::TestCase
  def build_envelope
    header = SOAP::SOAPHeader.new(SOAP::SOAPVersion1_2)
    body = SOAP::SOAPBody.new(
      SOAP::SOAPElement.new(XSD::QName.new("my:foo", "bodyitem"), 'bi'),
      false, SOAP::SOAPVersion1_2
    )
    SOAP::SOAPEnvelope.new(header, body, SOAP::SOAPVersion1_2)
  end

  def test_marshal_uses_soap12_namespace_only
    xml = SOAP::Processor.marshal(build_envelope, :soap_version => SOAP::SOAPVersion1_2)
    assert_match(/xmlns:env="http:\/\/www\.w3\.org\/2003\/05\/soap-envelope"/, xml)
    refute_match(/#{Regexp.escape(SOAP::EnvelopeNamespace)}/, xml)
  end

  def test_unmarshal_roundtrip
    xml = SOAP::Processor.marshal(build_envelope, :soap_version => SOAP::SOAPVersion1_2)
    env = SOAP::Processor.unmarshal(xml, :soap_version => SOAP::SOAPVersion1_2)
    assert_equal('http://www.w3.org/2003/05/soap-envelope', env.elename.namespace)
    assert_equal('http://www.w3.org/2003/05/soap-envelope', env.body.elename.namespace)
    assert_equal('bi', env.body.root_node.data)
  end

  # Documents the existing, pre-SOAP-1.2 contract: an envelope in a
  # namespace the Parser wasn't configured to recognize was never a clean
  # error (this predates soap_version entirely -- any unrecognized
  # envelope namespace falls through to decode_tag's generic
  # encoding-style handler instead of decode_soap_envelope). soap_version
  # being "explicit opt-in only" rides on that existing behavior rather
  # than needing anything new: a 1.2 envelope fed to a default (1.1)
  # Parser is simply never recognized as an envelope at all.
  def test_soap12_envelope_not_recognized_by_default_1_1_parser
    xml = SOAP::Processor.marshal(build_envelope, :soap_version => SOAP::SOAPVersion1_2)
    result = SOAP::Processor.unmarshal(xml, {})
    assert_not_equal(SOAP::SOAPEnvelope, result.class)
  end

  private

  def refute_match(pattern, string)
    assert_nil(pattern.match(string), "expected #{pattern.inspect} not to match")
  end
end


end
