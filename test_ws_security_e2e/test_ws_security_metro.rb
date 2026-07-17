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
# against a real, live, self-hosted Metro/WSIT test server (see
# soap4r-ws-security-testbed, a sibling project, rub-nds-metro/ -- not
# vendored here, a full Java/Maven application). Every test omits itself
# unless that server is actually reachable, same convention as
# test_ws_security_bernardo.rb.
#
# Unlike rub-nds-cxf (one WSDL endpoint per security combination) and
# bernardo-mg (one WSDL, many URL-path-distinguished endpoints), this
# engine exposes exactly one endpoint at the WSDL root, configured via a
# WS-SecurityPolicy (sp:EncryptBeforeSigning) rather than WSS4J's own
# action-string config -- so there's only one test here, not a matrix.
# This is also the server whose own streaming-canonicalizer digest bug
# (see CHANGELOG.md, "WS-Security: combined sign+encrypt fix") the
# original combined-sign-encrypt investigation found along the way, on a
# WS-SecurityPolicy-driven stack independent of rub-nds-cxf's WSS4J
# action-string one -- this test is what would catch either engine
# regressing on that fix.
class TestWSSecurityMetro < Test::Unit::TestCase
  NS = 'http://metro1.kmzs.ba/'
  BASE_URL = ENV['SOAP4R_TEST_WSSECURITY_METRO_URL'] || 'http://localhost:8082'
  DIR = File.dirname(File.expand_path(__FILE__))
  CLIENT_KEY  = File.join(DIR, 'keys', 'metro', 'client.key.pem')
  CLIENT_CERT = File.join(DIR, 'keys', 'metro', 'client.crt.pem')
  SERVER_CERT = File.join(DIR, 'keys', 'metro', 'server.crt.pem')

  def setup
    unless self.class.server_reachable?
      omit("no WS-Security test server reachable at #{BASE_URL} -- " \
           'start soap4r-ws-security-testbed/rub-nds-metro (see its README) ' \
           'to run these tests, or set SOAP4R_TEST_WSSECURITY_METRO_URL to ' \
           'point at one already running')
    end
  end

  def self.server_reachable?
    return @server_reachable if defined?(@server_reachable)
    require 'net/http'
    uri = URI("#{BASE_URL}/?wsdl")
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

  # Same reason as test_ws_security_cxf.rb's own build_driver: this
  # server's WSDL declares an explicit service name, so wsdl2ruby.rb
  # doesn't fall back to the generic "defaultDriver.rb" -- glob for
  # whatever *Driver.rb file actually landed instead of assuming.
  def build_driver(tmpdir)
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = "#{BASE_URL}/?wsdl"
    gen.basedir = tmpdir
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['mapping_registry'] = nil
    gen.opt['driver'] = nil
    gen.opt['force'] = true
    TestUtil.silent do
      gen.run
    end
    driver_file = Dir.glob(File.join(tmpdir, '*.rb')).find { |f| f =~ /[Dd]river\.rb\z/ }
    raise "no driver file generated in #{tmpdir}: #{Dir.entries(tmpdir).inspect}" unless driver_file
    TestUtil.require(tmpdir, File.basename(driver_file))
    ::AdminConfig.new
  end

  def request_element
    SOAP::SOAPElement.new(XSD::QName.new(NS, 'getServerTime'))
  end

  def assert_server_time(response)
    assert_match(%r{\A\d{2}/\d{2}/\d{4} \d{2}:\d{2}:\d{2}\z}, response.v_return)
  end

  def test_encrypt_sign
    Dir.mktmpdir('wssec_e2e_metro_encsign') do |tmpdir|
      driver = build_driver(tmpdir)
      driver.filterchain << SOAP::WSSE::EncryptionFilter.new(SERVER_CERT, CLIENT_KEY)
      driver.filterchain << SOAP::WSSE::SignatureFilter.new(CLIENT_KEY, CLIENT_CERT, SERVER_CERT)
      assert_server_time(driver.getServerTime(request_element))
    end
  end

  # Same rationale as test_ws_security_bernardo.rb's own tamper-detection
  # test: proves SignatureFilter#on_inbound actually verifies rather than
  # rubber-stamping the response signature.
  def test_response_signature_tamper_detection
    Dir.mktmpdir('wssec_e2e_metro_tamper') do |tmpdir|
      driver = build_driver(tmpdir)
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
