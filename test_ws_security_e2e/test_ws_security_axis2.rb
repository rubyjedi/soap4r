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


# Exercises combined SOAP::WSSE::EncryptionFilter + SignatureFilter
# against a real, live, self-hosted Axis2/Rampart test server (see
# soap4r-ws-security-testbed, a sibling project, rub-nds-axis2/ -- not
# vendored here, a full Java/Maven application). Every test omits itself
# unless that server is actually reachable, same convention as
# test_ws_security_bernardo.rb.
#
# Only the axis2-encsign service is covered here (combined Encrypt+Sign,
# both SOAP 1.1 and 1.2 -- the latter added specifically to prove the
# SOAP 1.2 fix end to end here too, see CHANGELOG.md, "WS-Security: SOAP
# 1.2 support"). Deliberately NOT covering axis2-ut/axis2-ut-digest
# (UsernameToken): both hit a genuine Rampart 1.8.0/WSS4J 3.0.3
# version-mismatch bug on the *server* side (axis2-ut doesn't actually
# validate PasswordText content; axis2-ut-digest rejects a spec-correct
# Digest token outright -- see the testbed's own CHANGELOG.md,
# "rub-nds-cxf/rub-nds-axis2: new SOAP 1.2 and UsernameToken endpoints",
# for the full trace) that soap4r-ng has no control over and shouldn't
# lock into its own formal suite as expected behavior.
class TestWSSecurityAxis2 < Test::Unit::TestCase
  NS = 'http://axis21.kmzs.ba'
  BASE_URL = ENV['SOAP4R_TEST_WSSECURITY_AXIS2_URL'] || 'http://localhost:8083'
  DIR = File.dirname(File.expand_path(__FILE__))
  CLIENT_KEY  = File.join(DIR, 'keys', 'axis2', 'client.key.pem')
  CLIENT_CERT = File.join(DIR, 'keys', 'axis2', 'client.crt.pem')
  SERVER_CERT = File.join(DIR, 'keys', 'axis2', 'server.crt.pem')

  def setup
    unless self.class.server_reachable?
      omit("no WS-Security test server reachable at #{BASE_URL} -- " \
           'start soap4r-ws-security-testbed/rub-nds-axis2 (see its README) ' \
           'to run these tests, or set SOAP4R_TEST_WSSECURITY_AXIS2_URL to ' \
           'point at one already running')
    end
  end

  def self.server_reachable?
    return @server_reachable if defined?(@server_reachable)
    require 'net/http'
    uri = URI("#{BASE_URL}/axis2/services/Version?wsdl")
    @server_reachable =
      begin
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

  def build_driver(endpoint_name, tmpdir)
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = "#{BASE_URL}/axis2/services/axis2-encsign?wsdl"
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
    endpoint = "#{BASE_URL}/axis2/services/axis2-encsign.#{endpoint_name}/"
    ::Axis2EncsignPortType.new(endpoint)
  end

  def request_element
    SOAP::SOAPElement.new(XSD::QName.new(NS, 'getServerTime'))
  end

  def assert_server_time(response)
    assert_match(%r{\A\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2}\z}, response.v_return)
  end

  def test_encrypt_sign
    Dir.mktmpdir('wssec_e2e_axis2_encsign') do |tmpdir|
      driver = build_driver('axis2-encsignHttpSoap11Endpoint', tmpdir)
      driver.filterchain << SOAP::WSSE::EncryptionFilter.new(SERVER_CERT, CLIENT_KEY)
      driver.filterchain << SOAP::WSSE::SignatureFilter.new(CLIENT_KEY, CLIENT_CERT, SERVER_CERT)
      assert_server_time(driver.getServerTime(request_element))
    end
  end

  # Axis2 auto-generates a SOAP 1.2 port for every deployed service --
  # the only engine in this testbed that does, which is why it's the one
  # used to prove the SOAP 1.2 fix end to end for the combined
  # Encrypt+Sign path (rub-nds-cxf covers Signature-only/Timestamp-only
  # under SOAP 1.2 instead, see test_ws_security_cxf.rb).
  def test_encrypt_sign_soap12
    Dir.mktmpdir('wssec_e2e_axis2_encsign12') do |tmpdir|
      driver = build_driver('axis2-encsignHttpSoap12Endpoint', tmpdir)
      driver.soap_version = SOAP::SOAPVersion1_2
      driver.filterchain << SOAP::WSSE::EncryptionFilter.new(SERVER_CERT, CLIENT_KEY)
      driver.filterchain << SOAP::WSSE::SignatureFilter.new(CLIENT_KEY, CLIENT_CERT, SERVER_CERT)
      assert_server_time(driver.getServerTime(request_element))
    end
  end

  # Same rationale as test_ws_security_bernardo.rb's own tamper-detection
  # test: proves SignatureFilter#on_inbound actually verifies rather than
  # rubber-stamping the response signature.
  def test_response_signature_tamper_detection
    Dir.mktmpdir('wssec_e2e_axis2_tamper') do |tmpdir|
      driver = build_driver('axis2-encsignHttpSoap11Endpoint', tmpdir)
      wrong_cert_path = File.join(tmpdir, 'wrong-cert.pem')
      File.open(wrong_cert_path, 'w') { |f| f.write(generate_throwaway_cert_pem) }
      driver.filterchain << SOAP::WSSE::EncryptionFilter.new(SERVER_CERT, CLIENT_KEY)
      driver.filterchain << SOAP::WSSE::SignatureFilter.new(CLIENT_KEY, CLIENT_CERT, wrong_cert_path)
      assert_raise(SOAP::WSSE::VerificationError) { driver.getServerTime(request_element) }
    end
  end

  private

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
end


end
