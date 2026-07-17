# encoding: UTF-8
# See test_ws_security_e2e/README.md for what this is and why it lives
# outside test/**/test_*.rb.
require 'helper'
require 'testutil'
require 'tmpdir'

require 'soap/wssecurity'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'
require 'soap/element'
require 'xsd/qname'
require 'openssl'

module WSSecurityE2E


# Exercises SOAP::WSSE::UsernameTokenFilter, SignatureFilter, and
# EncryptionFilter against all 9 endpoints of a real, live, self-hosted
# Bernardo-MG/spring-ws-security-soap-example WSS4J+XWSS test server (see
# soap4r-ws-security-testbed, a sibling project -- not vendored here, since
# it's a full Java/Maven/Spring-WS application, not a Ruby test fixture).
# Every test omits itself unless that server is actually reachable, so an
# ordinary `rake test:deep` run (which doesn't know or care about this
# server) never fails here -- it just skips, the same way
# vendor_wsdl_e2e's live NetSuite test does for a live network call.
#
# The signature/encryption endpoints' *responses* are also secured
# (soap4r-ws-security-testbed's Spring config sets secureResponse=true on
# the WSS4J interceptors and adds Sign/Encrypt generation directives to
# the XWSS policy files, on top of their original request-side-only
# config) specifically so SignatureFilter#on_inbound/
# EncryptionFilter#on_inbound have something real to verify/decrypt
# against, not just a synthetic self-test. test_signature_*/
# test_encryption_* below exercise both directions in one call: the
# request going out is signed/encrypted by soap4r-ng, and the response
# coming back is signed/encrypted by the server and verified/decrypted by
# soap4r-ng -- assert_entity_1 is only reached at all if both succeed.
class TestWSSecurity < Test::Unit::TestCase
  NS = 'http://bernardomg.com/example/ws/entity'
  BASE_URL = ENV['SOAP4R_TEST_WSSECURITY_URL'] || 'http://localhost:8080/swss'
  DIR = File.dirname(File.expand_path(__FILE__))
  KEY_PATH = File.join(DIR, 'keys', 'swss-cert.key.pem')
  CERT_PATH = File.join(DIR, 'keys', 'swss-cert.crt.pem')
  # The WSDL declares soapAction="" for getEntity, but the server's own
  # endpoint constants (ExampleEntityEndpointConstants.java) say the real
  # action must be sent whenever the request body's payload root gets
  # hidden (i.e. encryption) -- see lib/soap/wssecurity.rb's EncryptionFilter
  # comments for the full root-cause. Only needed for the two encryption
  # tests below.
  ACTION = 'http://bernardomg.com/example/ws/entity/getEntity'

  def setup
    unless self.class.server_reachable?
      omit("no WS-Security test server reachable at #{BASE_URL} -- " \
           'start soap4r-ws-security-testbed/bernardo-mg (see its README) ' \
           'to run these tests, or set SOAP4R_TEST_WSSECURITY_URL to point ' \
           'at one already running')
    end
  end

  def self.server_reachable?
    return @server_reachable if defined?(@server_reachable)
    require 'net/http'
    uri = URI("#{BASE_URL}/unsecure/entities.wsdl")
    @server_reachable =
      begin
        # Explicit attribute assignment rather than Net::HTTP.start's
        # keyword-style trailing options (open_timeout: 2) -- same
        # 1.8.7/1.9.3 `key: value` syntax concern as elsewhere in this
        # file; plain accessor assignment has worked on every Ruby version.
        http = Net::HTTP.new(uri.host, uri.port)
        http.open_timeout = 2
        http.read_timeout = 2
        http.start do |h|
          h.get(uri.request_uri).is_a?(Net::HTTPSuccess)
        end
      rescue StandardError
        false
      end
  end

  def build_driver(path, tmpdir)
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = "#{BASE_URL}/#{path}.wsdl"
    gen.basedir = tmpdir
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['driver'] = nil
    gen.opt['force'] = true
    TestUtil.silent do
      gen.run
    end
    TestUtil.require(tmpdir, 'defaultDriver.rb')
    ::Entities.new
  end

  def request_element
    request = SOAP::SOAPElement.new(XSD::QName.new(NS, 'getEntityRequest'))
    id = SOAP::SOAPInt.new(1)
    id.elename = XSD::QName.new(NS, 'id')
    request.add(id)
    request
  end

  def assert_entity_1(response)
    assert_equal(1, response.entity.id)
    assert_equal('entity_1', response.entity.name)
  end

  def test_unsecured
    Dir.mktmpdir('wssec_e2e_unsecured') do |tmpdir|
      driver = build_driver('unsecure/entities', tmpdir)
      assert_entity_1(driver.getEntity(request_element))
    end
  end

  def test_password_plain_wss4j
    assert_password('password/plain/wss4j/entities', false)
  end

  def test_password_plain_xwss
    assert_password('password/plain/xwss/entities', false)
  end

  def test_password_digest_wss4j
    assert_password('password/digest/wss4j/entities', true)
  end

  def test_password_digest_xwss
    assert_password('password/digest/xwss/entities', true)
  end

  def test_signature_wss4j
    assert_signature('signature/wss4j/entities')
  end

  def test_signature_xwss
    assert_signature('signature/xwss/entities')
  end

  def test_encryption_wss4j
    assert_encryption('encryption/wss4j/entities')
  end

  def test_encryption_xwss
    assert_encryption('encryption/xwss/entities')
  end

  # Confirms SignatureFilter#on_inbound actually rejects a bad response
  # rather than silently accepting anything -- the positive-path tests
  # above prove verification *can* succeed, this proves it can also fail
  # when it should. A throwaway, never-persisted cert stands in for
  # "the wrong signer"; assert_raise wants the exact class, matching this
  # file's existing convention (see e.g. test_ssl.rb elsewhere in this
  # project).
  def test_response_signature_tamper_detection
    Dir.mktmpdir('wssec_e2e_signature_tamper') do |tmpdir|
      driver = build_driver('signature/wss4j/entities', tmpdir)
      wrong_cert_path = File.join(tmpdir, 'wrong-cert.pem')
      File.open(wrong_cert_path, 'w') { |f| f.write(generate_throwaway_cert_pem) }
      driver.filterchain << SOAP::WSSE::SignatureFilter.new(KEY_PATH, CERT_PATH, wrong_cert_path)
      assert_raise(SOAP::WSSE::VerificationError) { driver.getEntity(request_element) }
    end
  end

  private

  # A cert with no relationship to the server's real signing key, purely
  # to prove SignatureFilter#on_inbound actually checks the signature
  # rather than rubber-stamping it -- generated in-process via Ruby's own
  # OpenSSL binding (not shelled out to the `openssl` CLI) so this test
  # doesn't depend on that tool being installed.
  def generate_throwaway_cert_pem
    key = OpenSSL::PKey::RSA.new(2048)
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = 1
    cert.subject = OpenSSL::X509::Name.parse('/CN=wrong')
    cert.issuer = cert.subject
    cert.public_key = key.public_key
    cert.not_before = Time.now
    cert.not_after = Time.now + 3600
    cert.sign(key, OpenSSL::Digest::SHA256.new)
    cert.to_pem
  end

  # Plain positional boolean, not a keyword argument -- keyword arguments
  # (even just at a private test-helper call site) need Ruby >= 1.9 for
  # the `key: value` calling convention, and this suite also needs to run
  # on Ruby 1.8.7 (see the matching note on UsernameTokenFilter#initialize
  # in lib/soap/wssecurity.rb).
  def assert_password(path, digest)
    Dir.mktmpdir('wssec_e2e_password') do |tmpdir|
      driver = build_driver(path, tmpdir)
      driver.filterchain << SOAP::WSSE::UsernameTokenFilter.new('myUser', 'myPassword', :digest => digest)
      assert_entity_1(driver.getEntity(request_element))
    end
  end

  # verify_cert_path defaults to CERT_PATH (see SignatureFilter.new) since
  # this test server signs its responses with the same shared keypair the
  # client signs requests with -- so this one call proves both directions.
  def assert_signature(path)
    Dir.mktmpdir('wssec_e2e_signature') do |tmpdir|
      driver = build_driver(path, tmpdir)
      driver.filterchain << SOAP::WSSE::SignatureFilter.new(KEY_PATH, CERT_PATH)
      assert_entity_1(driver.getEntity(request_element))
    end
  end

  # KEY_PATH passed as EncryptionFilter's second (decryption) argument for
  # the same reason as assert_signature above -- proves the response,
  # which the server encrypts for this same shared keypair, is actually
  # decrypted, not just that the request encrypts successfully.
  def assert_encryption(path)
    Dir.mktmpdir('wssec_e2e_encryption') do |tmpdir|
      driver = build_driver(path, tmpdir)
      # See ACTION's comment above -- required for encryption specifically.
      driver.add_document_operation(ACTION, 'getEntity', *::Entities::Methods[0][2, 2])
      driver.filterchain << SOAP::WSSE::EncryptionFilter.new(CERT_PATH, KEY_PATH)
      assert_entity_1(driver.getEntity(request_element))
    end
  end
end


end
