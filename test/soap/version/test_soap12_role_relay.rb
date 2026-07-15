# encoding: UTF-8
require 'helper'
require 'soap/processor'


module SOAP


class TestSoap12RoleRelay < Test::Unit::TestCase
  ROLE = 'http://www.w3.org/2003/05/soap-envelope/role/next'

  def build_envelope_with_header_item
    header = SOAP::SOAPHeader.new(SOAP::SOAPVersion1_2)
    item_element = SOAP::SOAPElement.new(XSD::QName.new("my:foo", "auth"), 'secret')
    header.add("auth", item_element)
    header_item = header.instance_variable_get(:@data).last
    header_item.actor = ROLE
    header_item.relay = true
    body = SOAP::SOAPBody.new(nil, false, SOAP::SOAPVersion1_2)
    SOAP::SOAPEnvelope.new(header, body, SOAP::SOAPVersion1_2)
  end

  def test_role_and_relay_round_trip
    xml = SOAP::Processor.marshal(build_envelope_with_header_item, :soap_version => SOAP::SOAPVersion1_2)
    assert_match(/env:role="#{Regexp.escape(ROLE)}"/, xml)
    assert_match(/env:relay="true"/, xml)
    assert_nil(/actor=/.match(xml))

    env = SOAP::Processor.unmarshal(xml, :soap_version => SOAP::SOAPVersion1_2)
    item = env.header.instance_variable_get(:@data).first
    assert_equal(ROLE, item.actor)
    assert_equal(true, item.relay)
  end

  def test_soap11_header_item_never_emits_role_or_relay
    header = SOAP::SOAPHeader.new
    item_element = SOAP::SOAPElement.new(XSD::QName.new("my:foo", "auth"), 'secret')
    header.add("auth", item_element)
    header_item = header.instance_variable_get(:@data).last
    header_item.actor = 'http://example.com/actor'
    header_item.relay = true # should be silently ignored -- no such concept under 1.1
    body = SOAP::SOAPBody.new
    env = SOAP::SOAPEnvelope.new(header, body)

    xml = SOAP::Processor.marshal(env, {})
    assert_match(/env:actor="http:\/\/example\.com\/actor"/, xml)
    assert_nil(/relay=/.match(xml))
  end
end


end
