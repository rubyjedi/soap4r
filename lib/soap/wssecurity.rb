# encoding: UTF-8
# SOAP4R - WS-Security support.
#
# Covers the WS-Security UsernameToken Profile 1.0/1.1 (plain and digested
# password) and XML Signature (over the SOAP Body, exclusive C14N,
# RSA-SHA1 -- the shape a 2016-era WSS4J/XWSS default configuration
# expects). soap4r-ng had no WS-Security support of any kind before this.
#
# XML Signature needs real canonicalization, which soap4r has no code of
# its own for -- delegates to Nokogiri's built-in Node#canonicalize
# (soap4r already carries Nokogiri as an optional XML-parser dependency).
# Considered using libxml-ruby instead (also a supported parser backend,
# also a genuine libxml2-backed C14N engine, so this wouldn't be trading
# up to a "real" implementation from a "fake" one) -- rejected after
# hands-on testing surfaced a real bug in its Document#canonicalize(:nodes
# => ...): the C extension's node-array unwrapping (rxml_document_
# canonicalize in ruby_xml_document.c) calls Data_Get_Struct(elem, xmlNode,
# ...) unconditionally on every array entry, but a LibXML::XML::Namespace
# wraps a distinct underlying struct (xmlNs, not xmlNode) -- every
# namespace declaration silently vanishes from the canonicalized output
# when the nodeset includes namespace nodes, which any exclusive-C14N
# subtree canonicalization needs (confirmed via a direct A/B probe against
# Nokogiri's output on identical input). Not a hypothetical: this is what
# a real SOAP Body canonicalization needs, and it silently produces wrong
# bytes. REXML/Oga/Ox have no C14N implementation at all (checked their
# gem contents directly) -- Nokogiri is the only verified-correct option
# among the 5 supported parsers, and also the de facto standard choice for
# XML-DSig/WS-Security work in the Ruby ecosystem for the same reason.
#
# The dependency is scoped to just the two classes that actually need it
# (SignatureFilter, EncryptionFilter -- see their own `require 'nokogiri'`
# in #initialize) rather than required here at file level: UsernameToken
# Profile support needs no XML canonicalization or parsing at all, so
# `require 'soap/wssecurity'` alone must not force a Nokogiri dependency
# onto someone who only wants UsernameTokenFilter.
#
# No dependency on the `base64` library at all, in favor of a single
# Array#pack('m')-based helper (strict_base64encode, below) -- not a style
# preference, a correctness fix: `Base64.strict_encode64` (the newline-free
# variant XML-Enc/XML-DSig/WSSE need -- an embedded newline inside a
# CipherValue/DigestValue/BinarySecurityToken would still be valid XML
# content but breaks byte-for-byte digest/signature comparisons against it)
# doesn't exist on Ruby 1.8.7's `base64` at all (confirmed: NoMethodError --
# added later, alongside Array#pack's own "m0" no-wrap count modifier,
# which *also* doesn't work on 1.8.7 and silently falls back to
# 60-column-wrapped output there). `pack('m')` (no count, the classic
# RFC 2045 MIME form) plus stripping the newlines it inserts is the one
# encoding path confirmed identical to `strict_encode64`'s output *and*
# available on every Ruby version this library supports, so it's used
# unconditionally rather than branching on RUBY_VERSION or Base64's
# available methods.
require 'soap/filter/handler'
require 'soap/element'
require 'soap/processor'
require 'xsd/qname'
require 'digest/sha1'
require 'securerandom'
require 'time'
require 'openssl'


module SOAP
module WSSE


WSSE_NS = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd'
WSU_NS  = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'
DS_NS   = 'http://www.w3.org/2000/09/xmldsig#'
PASSWORD_TEXT_TYPE   = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText'
PASSWORD_DIGEST_TYPE = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordDigest'
ENCODING_TYPE_BASE64 = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary'
X509_V3_VALUE_TYPE   = 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3'
C14N_EXCLUSIVE_ALGORITHM = 'http://www.w3.org/2001/10/xml-exc-c14n#'
RSA_SHA1_SIGNATURE_ALGORITHM = 'http://www.w3.org/2000/09/xmldsig#rsa-sha1'
SHA1_DIGEST_ALGORITHM = 'http://www.w3.org/2000/09/xmldsig#sha1'
XENC_NS = 'http://www.w3.org/2001/04/xmlenc#'
AES128_CBC_ALGORITHM = 'http://www.w3.org/2001/04/xmlenc#aes128-cbc'
RSA_OAEP_MGF1P_ALGORITHM = 'http://www.w3.org/2001/04/xmlenc#rsa-oaep-mgf1p'
CONTENT_TYPE = 'http://www.w3.org/2001/04/xmlenc#Content'
# WSS 1.1 namespace for the TokenType attribute WSS4J puts on the
# SecurityTokenReference that points an EncryptedData back at its
# EncryptedKey (see build_encrypted_data) -- distinct from the WSS 1.0
# secext namespace (WSSE_NS) used for the token/reference elements
# themselves.
WSSE11_NS = 'http://docs.oasis-open.org/wss/oasis-wss-wssecurity-secext-1.1.xsd'
ENCRYPTED_KEY_TOKEN_TYPE = 'http://docs.oasis-open.org/wss/oasis-wss-soap-message-security-1.1#EncryptedKey'

TYPE_ATTR_NAME     = XSD::QName.new(nil, 'Type')
ENCODING_TYPE_ATTR = XSD::QName.new(nil, 'EncodingType')
VALUE_TYPE_ATTR    = XSD::QName.new(nil, 'ValueType')
ID_ATTR            = XSD::QName.new(nil, 'Id')
ALGORITHM_ATTR     = XSD::QName.new(nil, 'Algorithm')
URI_ATTR           = XSD::QName.new(nil, 'URI')
TOKEN_TYPE_ATTR    = XSD::QName.new(WSSE11_NS, 'TokenType')

# See the file-level comment above on why this exists instead of
# `Base64.strict_encode64`.
def self.strict_base64encode(data)
  [data].pack('m').gsub(/\n/, '')
end

# `String#unpack('m')` (unlike `strict_encode64`'s decode counterpart,
# `strict_decode64`) tolerates embedded newlines either way, and is
# available on every Ruby version this library supports -- same reasoning
# as strict_base64encode above, just the decode direction.
def self.strict_base64decode(data)
  data.unpack('m').first
end

# Raised by SignatureFilter#on_inbound/EncryptionFilter#on_inbound when a
# response fails verification or can't be decrypted -- callers should treat
# this the same as any other transport-level integrity failure, not retry
# blindly.
class VerificationError < StandardError; end


class UsernameTokenFilter < SOAP::Filter::Handler
  # opt[:digest]: false (default) for PasswordText (sent proactively, in
  # the clear -- only meaningful over a transport that's independently
  # protecting confidentiality, e.g. TLS), true for PasswordDigest (nonce +
  # timestamp + SHA-1, per the Username Token Profile's digest algorithm --
  # proves knowledge of the password without sending it, but note this is
  # NOT the same thing as a cryptographic signature/encryption; it only
  # guards against a passive eavesdropper replaying the raw password).
  #
  # A plain trailing-hash parameter (matching the `opt = {}` convention
  # already used elsewhere in lib/soap/, e.g. Processor#marshal,
  # Parser#initialize) rather than a keyword argument with a default value
  # -- the latter is a hard SyntaxError on Ruby 1.8.7/1.9.3 (keyword
  # arguments were introduced in Ruby 2.0), which would otherwise make this
  # the only file in the library `require 'soap/wssecurity'` couldn't even
  # parse on those two versions. Caller syntax at the call site
  # (`UsernameTokenFilter.new(user, pass, :digest => true)` or, on Ruby
  # >= 1.9, the equivalent `digest: true`) is unaffected either way.
  def initialize(username, password, opt = {})
    digest = opt[:digest] || false
    @username = username
    @password = password
    @digest = digest
  end

  def on_outbound(envelope, opt)
    envelope.header ||= SOAP::SOAPHeader.new
    envelope.header.add('Security', build_security_element)
    envelope
  end

  private

  def build_security_element
    security = SOAP::SOAPElement.new(XSD::QName.new(WSSE_NS, 'Security'))
    security.add(build_username_token)
    security
  end

  def build_username_token
    token = SOAP::SOAPElement.new(XSD::QName.new(WSSE_NS, 'UsernameToken'))

    username = SOAP::SOAPString.new(@username)
    username.elename = XSD::QName.new(WSSE_NS, 'Username')
    token.add(username)

    if @digest
      nonce_bytes = SecureRandom.random_bytes(16)
      created = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%SZ')
      digest_value = WSSE.strict_base64encode(
        Digest::SHA1.digest(nonce_bytes + created + @password))

      password = SOAP::SOAPString.new(digest_value)
      password.elename = XSD::QName.new(WSSE_NS, 'Password')
      password.extraattr[TYPE_ATTR_NAME] = PASSWORD_DIGEST_TYPE
      token.add(password)

      nonce = SOAP::SOAPString.new(WSSE.strict_base64encode(nonce_bytes))
      nonce.elename = XSD::QName.new(WSSE_NS, 'Nonce')
      nonce.extraattr[ENCODING_TYPE_ATTR] = ENCODING_TYPE_BASE64
      token.add(nonce)

      created_ele = SOAP::SOAPString.new(created)
      created_ele.elename = XSD::QName.new(WSU_NS, 'Created')
      token.add(created_ele)
    else
      password = SOAP::SOAPString.new(@password)
      password.elename = XSD::QName.new(WSSE_NS, 'Password')
      password.extraattr[TYPE_ATTR_NAME] = PASSWORD_TEXT_TYPE
      token.add(password)
    end

    token
  end
end


# Signs the SOAP Body via XML Signature (exclusive C14N, RSA-SHA1),
# embedding the signing certificate directly as a BinarySecurityToken
# (DirectReference) rather than assuming the server already has it in a
# separate truststore lookup keyed by issuer/serial.
#
# Architecture note: `on_outbound` receives the envelope *object*, before
# soap4r's own Processor.marshal serializes it -- but a signature needs
# the Body's exact canonical XML *bytes*, which only exist once something
# has serialized it. Rather than invent a second serializer, this calls
# soap4r's own Processor.marshal itself, as a *preview* pass, to get a
# real serialized string with correct/self-consistent namespace prefixes;
# parses that with Nokogiri (whose Node#canonicalize correctly accounts
# for namespaces inherited from ancestor elements -- exactly the problem
# a bare per-element serializer would get wrong); computes the digest and
# signature from that; then mutates the *same* DigestValue/SignatureValue
# element objects already attached to the real envelope (via their own
# `#set`, not string surgery) so the caller's subsequent *real* marshal --
# which runs immediately after this filter returns, in
# SOAP::RPC::Proxy#marshal -- produces output structurally identical to
# what was just canonicalized and signed, just with the placeholder
# digest/signature text replaced by the real computed values. Confirmed
# empirically that the Body's own serialization is unaffected by this
# (same object, no structural change between the preview and real pass --
# only text-node content changes on elements that aren't the Body itself).
#
# `on_inbound` verifies a signed *response* using `verify_cert` (defaults
# to the same cert used for outbound signing, since typical deployments --
# including the server this was verified against -- reuse one keypair for
# both directions; pass a distinct one if the server signs with a
# different cert than the client does). Deliberately does NOT resolve the
# signer's identity from the response's own KeyInfo/SecurityTokenReference
# (which varies by server -- WSS4J emits X509IssuerSerial, XWSS emits a
# DirectReference to its own BinarySecurityToken, confirmed empirically
# against both) -- trust is anchored to the cert the caller already
# configured, the same way a real client pins its trusted server cert out
# of band rather than trusting whatever certificate a message claims to
# carry.
#
# `on_inbound` runs on the raw XML string before Processor.unmarshal (see
# SOAP::RPC::Proxy#unmarshal) -- soap4r has no other hook for a filter to
# see the response before it's parsed into an envelope object. Once
# verified, the wsse:Security header is removed from the string entirely
# (mirroring on_outbound's full ownership of adding it) so
# Processor.unmarshal never sees the SOAP-ENV:mustUnderstand="1" attribute
# on it -- left in place, it would raise
# SOAP::UnhandledMustUnderstandHeaderError regardless of whether the
# signature actually verified, since that check happens independently of
# this filter chain (SOAP::Header::HandlerSet, a separate mechanism this
# filter doesn't otherwise touch).
class SignatureFilter < SOAP::Filter::Handler
  def initialize(key_path, cert_path, verify_cert_path = cert_path)
    require 'nokogiri' # see the file-level comment on canonicalization above
    @private_key = OpenSSL::PKey::RSA.new(File.read(key_path))
    @cert = OpenSSL::X509::Certificate.new(File.read(cert_path))
    @verify_cert = OpenSSL::X509::Certificate.new(File.read(verify_cert_path))
  end

  def on_outbound(envelope, opt)
    body_id = "Body-#{SecureRandom.hex(8)}"
    cert_id = "X509-#{SecureRandom.hex(8)}"
    envelope.body.extraattr[XSD::QName.new(WSU_NS, 'Id')] = body_id

    digest_value_ele = SOAP::SOAPString.new('')
    digest_value_ele.elename = XSD::QName.new(DS_NS, 'DigestValue')
    signature_value_ele = SOAP::SOAPString.new('')
    signature_value_ele.elename = XSD::QName.new(DS_NS, 'SignatureValue')

    security = build_security(body_id, cert_id, digest_value_ele, signature_value_ele)
    envelope.header ||= SOAP::SOAPHeader.new
    envelope.header.add('Security', security)

    # Preview pass: same envelope, same opt, just to get real serialized
    # bytes to canonicalize -- see class comment above.
    preview_xml = SOAP::Processor.marshal(envelope, opt)
    doc = Nokogiri::XML(preview_xml)

    body_node = doc.at_xpath("//*[@*[local-name()='Id']='#{body_id}']")
    digest = WSSE.strict_base64encode(
      Digest::SHA1.digest(body_node.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)))
    digest_value_ele.set(digest)
    # SignedInfo's own canonical form must reflect the *real* digest
    # (not the placeholder still sitting in `doc`) for the signature over
    # it to actually validate -- update `doc`'s copy too before signing.
    doc.at_xpath("//*[local-name()='DigestValue']").content = digest

    signed_info_node = doc.at_xpath("//*[local-name()='SignedInfo']")
    canon_signed_info = signed_info_node.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
    signature = @private_key.sign(OpenSSL::Digest::SHA1.new, canon_signed_info)
    signature_value_ele.set(WSSE.strict_base64encode(signature))

    envelope
  end

  def on_inbound(xml, opt)
    doc = Nokogiri::XML(xml)
    security_node = doc.at_xpath("//*[local-name()='Security']")
    return xml if security_node.nil?
    signature_node = security_node.at_xpath(".//*[local-name()='Signature']")
    return xml if signature_node.nil?

    signed_info_node = signature_node.at_xpath(".//*[local-name()='SignedInfo']")
    canon_signed_info = signed_info_node.canonicalize(
      Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0, inclusive_prefixes_for(signed_info_node))
    signature_value = WSSE.strict_base64decode(
      signature_node.at_xpath(".//*[local-name()='SignatureValue']").content.strip)
    unless @verify_cert.public_key.verify(OpenSSL::Digest::SHA1.new, signature_value, canon_signed_info)
      raise VerificationError, 'response signature does not verify against the configured cert'
    end

    # A signature can cover more than the Body alone (WSS4J's response, for
    # instance, also signs its own SignatureConfirmation token) -- verify
    # every Reference's digest, not just the first.
    signed_info_node.xpath(".//*[local-name()='Reference']").each do |reference_node|
      target_id = reference_node['URI'].to_s.sub(/\A#/, '')
      target_node = doc.at_xpath("//*[@*[local-name()='Id']='#{target_id}']")
      if target_node.nil?
        raise VerificationError, "signed reference \##{target_id} not found in response"
      end
      expected_digest = reference_node.at_xpath(".//*[local-name()='DigestValue']").content.strip
      actual_digest = WSSE.strict_base64encode(
        Digest::SHA1.digest(target_node.canonicalize(
          Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0, inclusive_prefixes_for(reference_node))))
      if actual_digest != expected_digest
        raise VerificationError, "digest mismatch for signed reference \##{target_id}"
      end
    end

    # Fully consumed -- see the class comment above on why this must not be
    # left for Processor.unmarshal to trip over.
    security_node.remove
    doc.to_xml
  end

  private

  # Exclusive C14N's InclusiveNamespaces PrefixList hint (nested under the
  # given node's own CanonicalizationMethod/Transform child) genuinely
  # affects the canonical output -- it forces specific ancestor namespace
  # declarations to be included even when unused within the canonicalized
  # subtree itself. Confirmed empirically that omitting it (Nokogiri's
  # canonicalize defaults to none) reproduces this project's own
  # on_outbound signatures correctly (WSS4J/XWSS have always validated
  # those), but does NOT reproduce WSS4J/XWSS's own response signatures --
  # both set a non-empty PrefixList (e.g. "wsse SOAP-ENV") that Nokogiri
  # must be told about explicitly to get byte-identical canonical output.
  def inclusive_prefixes_for(node)
    incl_ns = node.at_xpath(".//*[local-name()='InclusiveNamespaces']")
    return nil unless incl_ns
    list = incl_ns['PrefixList'].to_s.split(' ')
    list.empty? ? nil : list
  end

  def build_security(body_id, cert_id, digest_value_ele, signature_value_ele)
    security = SOAP::SOAPElement.new(XSD::QName.new(WSSE_NS, 'Security'))

    bst = SOAP::SOAPString.new(WSSE.strict_base64encode(@cert.to_der))
    bst.elename = XSD::QName.new(WSSE_NS, 'BinarySecurityToken')
    bst.extraattr[VALUE_TYPE_ATTR] = X509_V3_VALUE_TYPE
    bst.extraattr[ENCODING_TYPE_ATTR] = ENCODING_TYPE_BASE64
    bst.extraattr[XSD::QName.new(WSU_NS, 'Id')] = cert_id
    security.add(bst)

    signature = SOAP::SOAPElement.new(XSD::QName.new(DS_NS, 'Signature'))
    signature.add(build_signed_info(body_id, digest_value_ele))
    signature.add(signature_value_ele)
    signature.add(build_key_info(cert_id))
    security.add(signature)

    security
  end

  def build_signed_info(body_id, digest_value_ele)
    signed_info = SOAP::SOAPElement.new(XSD::QName.new(DS_NS, 'SignedInfo'))

    c14n_method = SOAP::SOAPElement.new(XSD::QName.new(DS_NS, 'CanonicalizationMethod'))
    c14n_method.extraattr[ALGORITHM_ATTR] = C14N_EXCLUSIVE_ALGORITHM
    signed_info.add(c14n_method)

    sig_method = SOAP::SOAPElement.new(XSD::QName.new(DS_NS, 'SignatureMethod'))
    sig_method.extraattr[ALGORITHM_ATTR] = RSA_SHA1_SIGNATURE_ALGORITHM
    signed_info.add(sig_method)

    reference = SOAP::SOAPElement.new(XSD::QName.new(DS_NS, 'Reference'))
    reference.extraattr[URI_ATTR] = "##{body_id}"

    transforms = SOAP::SOAPElement.new(XSD::QName.new(DS_NS, 'Transforms'))
    transform = SOAP::SOAPElement.new(XSD::QName.new(DS_NS, 'Transform'))
    transform.extraattr[ALGORITHM_ATTR] = C14N_EXCLUSIVE_ALGORITHM
    transforms.add(transform)
    reference.add(transforms)

    digest_method = SOAP::SOAPElement.new(XSD::QName.new(DS_NS, 'DigestMethod'))
    digest_method.extraattr[ALGORITHM_ATTR] = SHA1_DIGEST_ALGORITHM
    reference.add(digest_method)

    reference.add(digest_value_ele)
    signed_info.add(reference)
    signed_info
  end

  def build_key_info(cert_id)
    key_info = SOAP::SOAPElement.new(XSD::QName.new(DS_NS, 'KeyInfo'))
    str = SOAP::SOAPElement.new(XSD::QName.new(WSSE_NS, 'SecurityTokenReference'))
    str_ref = SOAP::SOAPElement.new(XSD::QName.new(WSSE_NS, 'Reference'))
    str_ref.extraattr[URI_ATTR] = "##{cert_id}"
    str_ref.extraattr[VALUE_TYPE_ATTR] = X509_V3_VALUE_TYPE
    str.add(str_ref)
    key_info.add(str)
    key_info
  end
end


# Encrypts the SOAP Body's *content* (its children, not the Body element
# itself -- Type=Content, matching a 2016-era WSS4J/XWSS default
# configuration with no scope override) via XML Encryption: a random
# AES-128 key encrypts the content (CBC mode, random IV prepended to the
# ciphertext per the XML-Enc convention), and that AES key is itself
# RSA-encrypted ("key transport") for the recipient using the same
# DirectReference-embedded certificate convention confirmed for this test
# server (see keystore.properties/interceptor-encryption-wss4j.properties
# in soap4r-ws-security-testbed).
#
# No canonicalization needed here (unlike SignatureFilter) -- encryption
# operates on plain serialized bytes, not canonical XML, so this only
# needs a *single* Processor.marshal preview pass to capture the
# plaintext content's real serialized bytes, then replaces the envelope's
# Body outright (a fresh, empty SOAPBody containing just the
# EncryptedData) rather than mutating placeholders in place the way
# SignatureFilter's two-pass dance does.
#
# `on_inbound` decrypts an encrypted *response* -- needs `key_path`, the
# private key matching whatever cert the server encrypted for (typically
# the same keypair `cert_path` already names, per the shared-keypair demo
# setup this was verified against; pass a distinct key if the server
# actually uses the client's own public key rather than a shared one).
# Optional and nil by default so existing outbound-only callers
# (`EncryptionFilter.new(cert_path)`) are unaffected.
#
# Resolves the AES key via the EncryptedData's own KeyInfo -> STR Reference
# -> EncryptedKey chain rather than assuming a fixed Id or sibling-vs-nested
# placement -- WSS4J and XWSS were confirmed to structure this differently
# (see build_reference_list's own comment on the WSS4J/XWSS placement
# difference on the *outbound* side; the inbound response from each follows
# its own server's convention, not necessarily this filter's outbound one).
#
# Like SignatureFilter#on_inbound, runs on the raw XML string before
# Processor.unmarshal and fully removes the wsse:Security header once
# consumed, for the same SOAP::UnhandledMustUnderstandHeaderError reason.
class EncryptionFilter < SOAP::Filter::Handler
  def initialize(cert_path, key_path = nil)
    require 'nokogiri' # see the file-level comment on canonicalization above
    @cert = OpenSSL::X509::Certificate.new(File.read(cert_path))
    @private_key = key_path && OpenSSL::PKey::RSA.new(File.read(key_path))
  end

  def on_outbound(envelope, opt)
    preview_xml = SOAP::Processor.marshal(envelope, opt)
    doc = Nokogiri::XML(preview_xml)
    body_node = doc.at_xpath("//*[local-name()='Body']")
    plaintext = body_node.children.to_xml

    aes_key = OpenSSL::Cipher.new('aes-128-cbc').random_key
    cipher = OpenSSL::Cipher.new('aes-128-cbc')
    cipher.encrypt
    cipher.key = aes_key
    iv = cipher.random_iv
    encrypted_content = iv + cipher.update(plaintext) + cipher.final

    # WSS4J's default key-transport algorithm is RSA-OAEP (with MGF1/SHA1),
    # not RSA-v1.5 -- confirmed against the project's own known-working
    # test fixture (request-encryption-wss4j.xml). OpenSSL's PKCS1_PADDING
    # default implements v1.5, so OAEP padding must be requested explicitly.
    encrypted_key = @cert.public_key.public_encrypt(
      aes_key, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)

    cert_id = "X509-#{SecureRandom.hex(8)}"
    enc_key_id = "EK-#{SecureRandom.hex(8)}"
    enc_data_id = "EncData-#{SecureRandom.hex(8)}"

    security = SOAP::SOAPElement.new(XSD::QName.new(WSSE_NS, 'Security'))

    bst = SOAP::SOAPString.new(WSSE.strict_base64encode(@cert.to_der))
    bst.elename = XSD::QName.new(WSSE_NS, 'BinarySecurityToken')
    bst.extraattr[VALUE_TYPE_ATTR] = X509_V3_VALUE_TYPE
    bst.extraattr[ENCODING_TYPE_ATTR] = ENCODING_TYPE_BASE64
    bst.extraattr[XSD::QName.new(WSU_NS, 'Id')] = cert_id
    security.add(bst)

    security.add(build_encrypted_key(cert_id, enc_key_id, encrypted_key))
    security.add(build_reference_list(enc_data_id))
    security.extraattr[AttrMustUnderstandName] = '1'
    envelope.header ||= SOAP::SOAPHeader.new
    envelope.header.add('Security', security)

    new_body = SOAP::SOAPBody.new
    new_body.add('EncryptedData',
      build_encrypted_data(enc_data_id, enc_key_id, WSSE.strict_base64encode(encrypted_content)))
    envelope.body = new_body

    envelope
  end

  def on_inbound(xml, opt)
    doc = Nokogiri::XML(xml)
    encrypted_data_node = doc.at_xpath("//*[local-name()='EncryptedData']")
    return xml if encrypted_data_node.nil?
    unless @private_key
      raise VerificationError, 'response is encrypted but no key_path was given to EncryptionFilter.new'
    end

    str_ref = encrypted_data_node.at_xpath(".//*[local-name()='KeyInfo']//*[local-name()='Reference']")
    enc_key_id = str_ref['URI'].to_s.sub(/\A#/, '')
    encrypted_key_node = doc.at_xpath("//*[local-name()='EncryptedKey' and @Id='#{enc_key_id}']")
    if encrypted_key_node.nil?
      raise VerificationError, "EncryptedKey \##{enc_key_id} referenced by EncryptedData not found"
    end
    encrypted_key_bytes = WSSE.strict_base64decode(
      encrypted_key_node.at_xpath(".//*[local-name()='CipherValue']").content.strip)
    aes_key = @private_key.private_decrypt(encrypted_key_bytes, OpenSSL::PKey::RSA::PKCS1_OAEP_PADDING)

    encrypted_content = WSSE.strict_base64decode(
      encrypted_data_node.at_xpath(".//*[local-name()='CipherValue']").content.strip)
    iv, ciphertext = encrypted_content[0, 16], encrypted_content[16..-1]
    cipher = OpenSSL::Cipher.new('aes-128-cbc')
    cipher.decrypt
    # XML-Enc's own block-cipher padding (RFC: the last byte is the pad
    # length; every *other* padding byte is arbitrary, unlike PKCS7's
    # requirement that they all equal the pad length) -- confirmed
    # empirically against both WSS4J and XWSS responses: OpenSSL's default
    # auto-unpadding (PKCS7 semantics) raises "bad decrypt" on otherwise
    # correctly-decrypted plaintext, because the non-final padding bytes
    # aren't uniformly the pad-length value the way our own on_outbound's
    # ciphertext (produced by OpenSSL's own PKCS7 padding) happens to be.
    # Disable auto-unpadding and strip it manually instead.
    cipher.padding = 0
    cipher.key = aes_key
    cipher.iv = iv
    padded = cipher.update(ciphertext) + cipher.final
    plaintext = padded[0...-padded.bytes.last]

    # Type=Content (the only scope this filter's own on_outbound produces,
    # and the only one confirmed against this test server) means the
    # plaintext is the Body's *children* -- replace EncryptedData (the
    # Body's sole child per that same convention) with them directly.
    encrypted_data_node.replace(Nokogiri::XML.fragment(plaintext))

    security_node = doc.at_xpath("//*[local-name()='Security']")
    security_node.remove if security_node
    doc.to_xml
  end

  private

  def build_encrypted_key(cert_id, enc_key_id, encrypted_key_bytes)
    ek = SOAP::SOAPElement.new(XSD::QName.new(XENC_NS, 'EncryptedKey'))
    ek.extraattr[ID_ATTR] = enc_key_id

    method = SOAP::SOAPElement.new(XSD::QName.new(XENC_NS, 'EncryptionMethod'))
    method.extraattr[ALGORITHM_ATTR] = RSA_OAEP_MGF1P_ALGORITHM
    ek.add(method)

    key_info = SOAP::SOAPElement.new(XSD::QName.new(DS_NS, 'KeyInfo'))
    str = SOAP::SOAPElement.new(XSD::QName.new(WSSE_NS, 'SecurityTokenReference'))
    str_ref = SOAP::SOAPElement.new(XSD::QName.new(WSSE_NS, 'Reference'))
    str_ref.extraattr[URI_ATTR] = "##{cert_id}"
    str_ref.extraattr[VALUE_TYPE_ATTR] = X509_V3_VALUE_TYPE
    str.add(str_ref)
    key_info.add(str)
    ek.add(key_info)

    cipher_data = SOAP::SOAPElement.new(XSD::QName.new(XENC_NS, 'CipherData'))
    cipher_value = SOAP::SOAPString.new(WSSE.strict_base64encode(encrypted_key_bytes))
    cipher_value.elename = XSD::QName.new(XENC_NS, 'CipherValue')
    cipher_data.add(cipher_value)
    ek.add(cipher_data)

    ek
  end

  # A sibling of EncryptedKey under Security, not nested inside it --
  # matches the project's own XWSS reference fixture exactly (its WSS4J
  # fixture nests ReferenceList inside EncryptedKey instead; both
  # placements are legal XML-Enc, but XWSS's decryption resolver appears
  # to specifically need the sibling form -- nesting it produced a
  # "XMLCipher unexpectedly not in UNWRAP_MODE or DECRYPT_MODE" error).
  def build_reference_list(enc_data_id)
    ref_list = SOAP::SOAPElement.new(XSD::QName.new(XENC_NS, 'ReferenceList'))
    data_ref = SOAP::SOAPElement.new(XSD::QName.new(XENC_NS, 'DataReference'))
    data_ref.extraattr[URI_ATTR] = "##{enc_data_id}"
    ref_list.add(data_ref)
    ref_list
  end

  def build_encrypted_data(enc_data_id, enc_key_id, cipher_value_b64)
    enc_data = SOAP::SOAPElement.new(XSD::QName.new(XENC_NS, 'EncryptedData'))
    enc_data.extraattr[ID_ATTR] = enc_data_id
    enc_data.extraattr[TYPE_ATTR_NAME] = CONTENT_TYPE

    method = SOAP::SOAPElement.new(XSD::QName.new(XENC_NS, 'EncryptionMethod'))
    method.extraattr[ALGORITHM_ATTR] = AES128_CBC_ALGORITHM
    enc_data.add(method)

    # Back-reference to the EncryptedKey that decrypts this block -- WSS4J
    # needs this (not just the EncryptedKey's own forward ReferenceList) to
    # locate the right key when processing EncryptedData; confirmed against
    # the project's own known-working fixture, which includes this and
    # which my earlier, 404-ing attempt omitted entirely.
    key_info = SOAP::SOAPElement.new(XSD::QName.new(DS_NS, 'KeyInfo'))
    str = SOAP::SOAPElement.new(XSD::QName.new(WSSE_NS, 'SecurityTokenReference'))
    str.extraattr[TOKEN_TYPE_ATTR] = ENCRYPTED_KEY_TOKEN_TYPE
    str_ref = SOAP::SOAPElement.new(XSD::QName.new(WSSE_NS, 'Reference'))
    str_ref.extraattr[URI_ATTR] = "##{enc_key_id}"
    str.add(str_ref)
    key_info.add(str)
    enc_data.add(key_info)

    cipher_data = SOAP::SOAPElement.new(XSD::QName.new(XENC_NS, 'CipherData'))
    cipher_value = SOAP::SOAPString.new(cipher_value_b64)
    cipher_value.elename = XSD::QName.new(XENC_NS, 'CipherValue')
    cipher_data.add(cipher_value)
    enc_data.add(cipher_data)

    enc_data
  end
end


end
end
