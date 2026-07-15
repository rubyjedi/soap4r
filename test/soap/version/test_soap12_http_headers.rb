# encoding: UTF-8
require 'helper'
require 'soap/streamHandler'


module SOAP


# Phase 3 of SOAP 1.2 support: HTTP binding. SOAP 1.2 replaces the
# separate SOAPAction header with an action="..." parameter folded into
# Content-Type (application/soap+xml instead of text/xml). Unit-level
# coverage for the building blocks; test_soap12_http_roundtrip.rb covers
# a real client -> WEBrick server -> back round trip.
class TestSoap12HttpHeaders < Test::Unit::TestCase
  def test_soap11_content_type_never_embeds_action
    ct = SOAP::SOAPVersion1_1.build_content_type("utf-8", "urn:foo:bar")
    assert_equal("text/xml; charset=utf-8", ct)
  end

  def test_soap12_content_type_embeds_action
    ct = SOAP::SOAPVersion1_2.build_content_type("utf-8", "urn:foo:bar")
    assert_equal('application/soap+xml; charset=utf-8; action="urn:foo:bar"', ct)
  end

  def test_soap12_content_type_omits_action_when_absent
    ct = SOAP::SOAPVersion1_2.build_content_type("utf-8")
    assert_equal("application/soap+xml; charset=utf-8", ct)
  end

  def test_parse_media_type_handles_both_versions
    assert_equal("utf-8", SOAP::StreamHandler.parse_media_type("text/xml; charset=utf-8"))
    assert_equal("utf-8", SOAP::StreamHandler.parse_media_type("application/soap+xml; charset=utf-8"))
    # action can appear before or after charset
    assert_equal("utf-8", SOAP::StreamHandler.parse_media_type(
      'application/soap+xml; action="urn:foo"; charset=utf-8'))
    assert_equal("utf-8", SOAP::StreamHandler.parse_media_type(
      'application/soap+xml; charset=utf-8; action="urn:foo"'))
  end

  def test_parse_media_type_defaults_charset_when_absent
    assert_equal("utf-8", SOAP::StreamHandler.parse_media_type("text/xml"))
  end

  def test_parse_media_type_rejects_unrelated_content_type
    assert_nil(SOAP::StreamHandler.parse_media_type("application/json"))
  end

  def test_parse_action_from_content_type
    assert_equal("urn:foo:bar", SOAP::StreamHandler.parse_action_from_content_type(
      'application/soap+xml; charset=utf-8; action="urn:foo:bar"'))
    assert_nil(SOAP::StreamHandler.parse_action_from_content_type("text/xml; charset=utf-8"))
    assert_nil(SOAP::StreamHandler.parse_action_from_content_type(nil))
  end

  def test_create_media_type_backward_compatible_two_arg_form
    # the pre-1.2 call site (charset only) must keep producing exactly
    # what it always did.
    assert_equal("text/xml; charset=utf-8", SOAP::StreamHandler.create_media_type("utf-8"))
  end
end


end
