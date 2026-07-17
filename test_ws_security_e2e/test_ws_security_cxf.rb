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


# Exercises SOAP::WSSE::SignatureFilter, TimestampFilter, and
# EncryptionFilter -- alone and combined -- against a real, live,
# self-hosted Apache CXF + WSS4J test server (see soap4r-ws-security-testbed,
# a sibling project, rub-nds-cxf/ -- not vendored here, since it's a full
# Java/Maven application, not a Ruby test fixture). Every test omits itself
# unless that server is actually reachable, same convention as
# test_ws_security_bernardo.rb.
#
# Unlike bernardo-mg (one shared client/server keypair, one payload-root-
# dispatched endpoint per security combination reached via a distinct URL
# path segment under one WSDL base), this server uses separate client and
# server identities (keys/cxf/client.* signs/decrypts what this suite
# sends, keys/cxf/server.crt.pem verifies/encrypts-to what the server
# sends back) and exposes each security combination as its own CXF
# endpoint (own WSDL, own URL) rather than a single shared one -- see
# CHANGELOG.md ("WS-Security: combined sign+encrypt fix") and
# ("WS-Security: SOAP 1.2 support") for how each of these endpoints and
# the bugs they caught came about.
#
# combined_encrypt_sign (the /encsign test below) is the endpoint the
# original combined-sign-encrypt wire-order bug was found and fixed
# against; sign12/timestamp12 are the endpoints added specifically to
# prove the SOAP 1.2 fix end to end (see the CHANGELOG entries above).
class TestWSSecurityCXF < Test::Unit::TestCase
  NS = 'http://cxf.kmzs.ba/'
  BASE_URL = ENV['SOAP4R_TEST_WSSECURITY_CXF_URL'] || 'http://localhost:8081'
  DIR = File.dirname(File.expand_path(__FILE__))
  CLIENT_KEY  = File.join(DIR, 'keys', 'cxf', 'client.key.pem')
  CLIENT_CERT = File.join(DIR, 'keys', 'cxf', 'client.crt.pem')
  SERVER_CERT = File.join(DIR, 'keys', 'cxf', 'server.crt.pem')

  def setup
    unless self.class.server_reachable?
      omit("no WS-Security test server reachable at #{BASE_URL} -- " \
           'start soap4r-ws-security-testbed/rub-nds-cxf (see its README) ' \
           'to run these tests, or set SOAP4R_TEST_WSSECURITY_CXF_URL to ' \
           'point at one already running')
    end
  end

  def self.server_reachable?
    return @server_reachable if defined?(@server_reachable)
    require 'net/http'
    uri = URI("#{BASE_URL}/1?wsdl")
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

  # Unlike bernardo-mg/rub-nds-axis2 (whose WSDLs have no explicit
  # wsdl:definitions name, so wsdl2ruby.rb falls back to a generic
  # "defaultDriver.rb"), this server's WSDL declares an explicit service
  # name ("AdminConfigImplService"), so the generated driver file is
  # named after it instead (confirmed directly: "AdminConfigImplService
  # Driver.rb") -- glob for whatever *Driver.rb file actually landed
  # rather than assuming the generic name.
  def build_driver(path, tmpdir)
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = "#{BASE_URL}/#{path}?wsdl"
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

  def test_unsecured
    Dir.mktmpdir('wssec_e2e_cxf_unsecured') do |tmpdir|
      driver = build_driver('1', tmpdir)
      assert_server_time(driver.getServerTime(request_element))
    end
  end

  def test_signature
    Dir.mktmpdir('wssec_e2e_cxf_sign') do |tmpdir|
      driver = build_driver('sign', tmpdir)
      driver.filterchain << SOAP::WSSE::SignatureFilter.new(CLIENT_KEY, CLIENT_CERT, SERVER_CERT)
      assert_server_time(driver.getServerTime(request_element))
    end
  end

  def test_timestamp
    Dir.mktmpdir('wssec_e2e_cxf_ts') do |tmpdir|
      driver = build_driver('ts', tmpdir)
      driver.filterchain << SOAP::WSSE::TimestampFilter.new
      assert_server_time(driver.getServerTime(request_element))
    end
  end

  # /enc is the one endpoint of this whole server that needs
  # add_document_operation's explicit SOAPAction override (confirmed
  # empirically -- /encsign, /encts, /tssign, /enctssign all work without
  # it): once Encryption alone hides the Body's operation-identifying
  # root element and there's no Signature/Timestamp header alongside it
  # for CXF's dispatcher to fall back on, CXF can't tell getServerTime
  # apart from this same service's other operation (getAdminToken)
  # without an explicit SOAPAction telling it which one this is.
  def test_encryption
    Dir.mktmpdir('wssec_e2e_cxf_enc') do |tmpdir|
      driver = build_driver('enc', tmpdir)
      driver.add_document_operation('getServerTime', 'getServerTime', *::AdminConfig::Methods[0][2, 2])
      driver.filterchain << SOAP::WSSE::EncryptionFilter.new(SERVER_CERT, CLIENT_KEY)
      assert_server_time(driver.getServerTime(request_element))
    end
  end

  def test_encrypt_sign
    Dir.mktmpdir('wssec_e2e_cxf_encsign') do |tmpdir|
      driver = build_driver('encsign', tmpdir)
      driver.filterchain << SOAP::WSSE::EncryptionFilter.new(SERVER_CERT, CLIENT_KEY)
      driver.filterchain << SOAP::WSSE::SignatureFilter.new(CLIENT_KEY, CLIENT_CERT, SERVER_CERT)
      assert_server_time(driver.getServerTime(request_element))
    end
  end

  def test_encrypt_timestamp
    Dir.mktmpdir('wssec_e2e_cxf_encts') do |tmpdir|
      driver = build_driver('encts', tmpdir)
      driver.filterchain << SOAP::WSSE::EncryptionFilter.new(SERVER_CERT, CLIENT_KEY)
      driver.filterchain << SOAP::WSSE::TimestampFilter.new
      assert_server_time(driver.getServerTime(request_element))
    end
  end

  def test_timestamp_sign
    Dir.mktmpdir('wssec_e2e_cxf_tssign') do |tmpdir|
      driver = build_driver('tssign', tmpdir)
      driver.filterchain << SOAP::WSSE::TimestampFilter.new
      driver.filterchain << SOAP::WSSE::SignatureFilter.new(CLIENT_KEY, CLIENT_CERT, SERVER_CERT)
      assert_server_time(driver.getServerTime(request_element))
    end
  end

  def test_encrypt_timestamp_sign
    Dir.mktmpdir('wssec_e2e_cxf_enctssign') do |tmpdir|
      driver = build_driver('enctssign', tmpdir)
      driver.filterchain << SOAP::WSSE::EncryptionFilter.new(SERVER_CERT, CLIENT_KEY)
      driver.filterchain << SOAP::WSSE::TimestampFilter.new
      driver.filterchain << SOAP::WSSE::SignatureFilter.new(CLIENT_KEY, CLIENT_CERT, SERVER_CERT)
      assert_server_time(driver.getServerTime(request_element))
    end
  end

  # /sign12 and /ts12: same interceptor config as /sign and /ts, bound to
  # SOAP 1.2 instead -- added specifically to prove the SOAP 1.2 fix (see
  # CHANGELOG.md, "WS-Security: SOAP 1.2 support") end to end against a
  # real server, not just unit-level.
  def test_signature_soap12
    Dir.mktmpdir('wssec_e2e_cxf_sign12') do |tmpdir|
      driver = build_driver('sign12', tmpdir)
      driver.soap_version = SOAP::SOAPVersion1_2
      driver.filterchain << SOAP::WSSE::SignatureFilter.new(CLIENT_KEY, CLIENT_CERT, SERVER_CERT)
      assert_server_time(driver.getServerTime(request_element))
    end
  end

  def test_timestamp_soap12
    Dir.mktmpdir('wssec_e2e_cxf_ts12') do |tmpdir|
      driver = build_driver('ts12', tmpdir)
      driver.soap_version = SOAP::SOAPVersion1_2
      driver.filterchain << SOAP::WSSE::TimestampFilter.new
      assert_server_time(driver.getServerTime(request_element))
    end
  end

  # Same rationale as test_ws_security_bernardo.rb's own tamper-detection
  # test: proves SignatureFilter#on_inbound actually verifies rather than
  # rubber-stamping the response signature.
  def test_response_signature_tamper_detection
    Dir.mktmpdir('wssec_e2e_cxf_tamper') do |tmpdir|
      driver = build_driver('sign', tmpdir)
      wrong_cert_path = File.join(tmpdir, 'wrong-cert.pem')
      File.open(wrong_cert_path, 'w') { |f| f.write(generate_throwaway_cert_pem) }
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
