# encoding: UTF-8
# SOAP4R - SOAP protocol version bundle (1.1 vs 1.2).
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/soap'


module SOAP


# A SOAPVersion bundles the constants that differ between SOAP 1.1 and 1.2
# (envelope namespace, and -- as later phases land -- encoding namespace,
# media type, fault codes, header role attribute, etc). It's resolved once
# per call, the same place @default_encodingstyle already is (Proxy/Router's
# opt hashes), never inferred from parsed content: SOAP version is a
# whole-message, driver-configured-in-advance choice, not a per-element,
# reactively-discovered one like encodingStyle.
class SOAPVersion
  attr_reader :envelope_namespace
  # The attribute a header block uses to address its intended recipient:
  # SOAP 1.1 calls this "actor", SOAP 1.2 renamed it "role" and gave it
  # slightly different semantics (a URI identifying a SOAP role rather than
  # a specific node) -- both are exposed through this one field name since
  # from the header-encoding machinery's point of view they serve the same
  # structural purpose.
  attr_reader :role_attr_name
  # SOAP 1.2-only; nil under 1.1, since 1.1 has no equivalent concept.
  attr_reader :relay_attr_name
  attr_reader :mustunderstand_attr_name
  attr_reader :media_type
  # SOAP 1.2's HTTP binding folds the SOAPAction value into a Content-Type
  # "action" parameter and drops the separate SOAPAction header entirely;
  # 1.1 keeps them as two separate things. false under 1.1, true under 1.2.
  attr_reader :action_in_content_type

  # Plain positional args with defaults, not Ruby keyword args (`x:`/`x: 1`)
  # -- this project supports Ruby back to 1.8.7/1.9.3, which predate
  # keyword-argument syntax entirely.
  def initialize(envelope_namespace, role_attr_local_name, relay_attr_local_name = nil,
                  media_type = MediaType, action_in_content_type = false)
    @envelope_namespace = envelope_namespace
    @role_attr_name = XSD::QName.new(envelope_namespace, role_attr_local_name)
    @relay_attr_name =
      if relay_attr_local_name
        XSD::QName.new(envelope_namespace, relay_attr_local_name)
      end
    @mustunderstand_attr_name = XSD::QName.new(envelope_namespace, 'mustUnderstand')
    @media_type = media_type
    @action_in_content_type = action_in_content_type
  end

  # soapaction is only ever embedded when action_in_content_type is true
  # (1.2) AND a soapaction is actually given -- under 1.1 (or when no
  # soapaction applies, e.g. a response) this is just "<media_type>;
  # charset=<charset>", identical to what StreamHandler.create_media_type
  # already built before this existed.
  def build_content_type(charset, soapaction = nil)
    ct = "#{@media_type}; charset=#{charset}"
    if @action_in_content_type && soapaction
      ct += %Q{; action="#{soapaction}"}
    end
    ct
  end
end

SOAPVersion1_1 = SOAPVersion.new(EnvelopeNamespace, 'actor')
SOAPVersion1_2 = SOAPVersion.new('http://www.w3.org/2003/05/soap-envelope', 'role', 'relay',
  'application/soap+xml', true)

# SOAP 1.2's env:Fault/env:Code/env:Value content is a QName identifying
# the fault code; 1.1's Client/Server (SOAP::FaultCode in soap.rb) are
# renamed Sender/Receiver here, same VersionMismatch/MustUnderstand
# concepts otherwise.
module FaultCode12
  VersionMismatch = XSD::QName.new(SOAPVersion1_2.envelope_namespace, 'VersionMismatch').freeze
  MustUnderstand = XSD::QName.new(SOAPVersion1_2.envelope_namespace, 'MustUnderstand').freeze
  Sender = XSD::QName.new(SOAPVersion1_2.envelope_namespace, 'Sender').freeze
  Receiver = XSD::QName.new(SOAPVersion1_2.envelope_namespace, 'Receiver').freeze
end


end
