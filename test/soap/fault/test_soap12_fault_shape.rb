# encoding: UTF-8
require 'helper'
require 'soap/processor'
require 'soap/rpc/element'


module SOAP
module Fault


# Phase 2 of SOAP 1.2 support, step 1: prove the nested/qualified/
# repeatable SOAP12Fault shape marshals and unmarshals correctly in
# isolation, before wiring it into router/exception machinery (that's
# test_soap12_fault_router.rb / test_soap12_fault_client.rb). SOAPFault
# itself is completely untouched by this -- confirmed separately by the
# existing test_fault.rb/test_customfault.rb/test_soaparray.rb suite
# still passing unmodified.
class TestSoap12FaultShape < Test::Unit::TestCase
  def build_envelope(fault)
    # Matches how router.rb actually builds a fault response
    # (SOAPBody.new(fault_obj, true, soap_version)) rather than the
    # decode-side body.fault= setter -- the latter forces the struct key
    # (and, via dup_name, the wire tag) to the literal lowercase string
    # "fault" regardless of the fault object's own elename, which is only
    # fine for values that get read back out via accessors, not
    # re-marshaled as-is.
    header = SOAP::SOAPHeader.new(SOAP::SOAPVersion1_2)
    body = SOAP::SOAPBody.new(fault, true, SOAP::SOAPVersion1_2)
    SOAP::SOAPEnvelope.new(header, body, SOAP::SOAPVersion1_2)
  end

  def test_fault_with_subcode_and_role_round_trips
    fault = SOAP::SOAP12Fault.new(
      SOAP::FaultCode12::Sender, "Invalid request", XSD::QName.new("urn:myapp", "BadArgument"),
      "http://example.com/myrole"
    )
    xml = SOAP::Processor.marshal(build_envelope(fault), :soap_version => SOAP::SOAPVersion1_2)

    assert_match(/env:Code/, xml)
    assert_match(/env:Value/, xml)
    assert_match(/env:Subcode/, xml)
    assert_match(/env:Reason/, xml)
    assert_match(/env:Text xml:lang="en"/, xml)
    assert_match(/env:Role/, xml)

    env = SOAP::Processor.unmarshal(xml, :soap_version => SOAP::SOAPVersion1_2)
    decoded = env.body.fault
    # Standard fault codes (Sender/Receiver/etc.) always live in the 1.2
    # envelope namespace per spec, so code_value resolves back to a real
    # QName even post-decode. Custom Subcodes can live in arbitrary
    # app namespaces, which the generic literal-style decode path has no
    # automatic QName-content resolution for (a pre-existing gap, not
    # specific to fault codes) -- so code_subcode is the raw wire string
    # ("prefix:localname") after a real decode, not a resolved QName.
    assert_equal(SOAP::FaultCode12::Sender, decoded.code_value)
    assert_equal("BadArgument", decoded.code_subcode.split(':').last)
    assert_equal("Invalid request", decoded.reason_text)
    assert_equal("http://example.com/myrole", decoded.role)
  end

  def test_fault_without_subcode_or_role
    fault = SOAP::SOAP12Fault.new(SOAP::FaultCode12::Receiver, "Server broke")
    xml = SOAP::Processor.marshal(build_envelope(fault), :soap_version => SOAP::SOAPVersion1_2)
    refute_match(/env:Subcode/, xml)
    refute_match(/env:Role/, xml)

    env = SOAP::Processor.unmarshal(xml, :soap_version => SOAP::SOAPVersion1_2)
    decoded = env.body.fault
    assert_equal(SOAP::FaultCode12::Receiver, decoded.code_value)
    assert_nil(decoded.code_subcode)
    assert_equal("Server broke", decoded.reason_text)
    assert_nil(decoded.role)
  end

  def test_fault_uses_sender_receiver_not_client_server
    fault = SOAP::SOAP12Fault.new(SOAP::FaultCode12::Sender, "bad input")
    xml = SOAP::Processor.marshal(build_envelope(fault), :soap_version => SOAP::SOAPVersion1_2)
    assert_match(/Sender/, xml)
    refute_match(/Client/, xml)
    refute_match(/Server/, xml)
  end

  private

  def refute_match(pattern, string)
    assert_nil(pattern.match(string), "expected #{pattern.inspect} not to match #{string.inspect}")
  end
end


end
end
