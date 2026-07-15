# encoding: UTF-8
require 'helper'
require 'testutil'
require 'soap/rpc/driver'
require 'soap/rpc/standaloneServer'
require 'soap/attachment'
require 'stringio'


module SOAP
module SWA


# Confirms SOAP-with-Attachments (MIME multipart) honors soap_version -- a
# real gap found alongside SOAP 1.2 support: MIMEMessage previously
# hardcoded "text/xml" for both the root part and the outer multipart's
# own "type" parameter regardless of soap_version, clobbering whatever
# Content-Type the non-attachment path would have built (see
# lib/soap/mimemessage.rb). Also confirms the legacy SOAPAction header is
# still sent for attachment requests even under 1.2, where it's otherwise
# folded into the Content-Type's action parameter instead -- action
# placement for attachments+1.2 combined isn't settled by any spec this
# was checked against, so the widely-supported legacy header is kept as a
# pragmatic fallback rather than guessed at (see
# StreamHandler::ConnectionData#multipart's comment).
class TestSoap12Swa < Test::Unit::TestCase
  Port = 17171

  class SwAService
    def put_file(name, file)
      "File '#{name}' was received ok."
    end
  end

  def setup
    @server = SOAP::RPC::StandaloneServer.new('SwAServer12',
      'http://www.acmetron.com/soap', '0.0.0.0', Port)
    @server.add_servant(SwAService.new)
    @server.level = Logger::Severity::ERROR
    @server.soap_version = SOAP::SOAPVersion1_2
    @t = TestUtil.start_server_thread(@server)
    @endpoint = "http://localhost:#{Port}/"
    @client = SOAP::RPC::Driver.new(@endpoint, 'http://www.acmetron.com/soap')
    @client.soap_version = SOAP::SOAPVersion1_2
    @client.add_method('put_file', 'name', 'file')
  end

  def teardown
    @server.shutdown if @server
    if @t
      unless @t.join(10)
        @t.kill
        @t.join
      end
    end
    @client.reset_stream if @client
  end

  def test_attachment_request_uses_soap12_media_type_and_keeps_soapaction_header
    wire = StringIO.new
    @client.wiredump_dev = wire
    # A synthetic payload, not this test's own source -- attaching the
    # latter would make refute_match's "text/xml" check below a false
    # positive against this very file's own comments.
    attachment = SOAP::Attachment.new(StringIO.new("attachment payload, unrelated to any media type string"))
    result = @client.put_file('foo', attachment)
    assert_equal("File 'foo' was received ok.", result)

    dump = wire.string
    assert_match(/Content-Type:.*multipart\/related.*type="application\/soap\+xml"/i, dump)
    assert_match(/SOAPAction:/i, dump)
    assert_match(/Content-Type:\s*application\/soap\+xml;\s*charset/i, dump)
    refute_match(/text\/xml/i, dump)
  end

  private

  def refute_match(pattern, string)
    assert_nil(pattern.match(string), "expected #{pattern.inspect} not to match #{string.inspect}")
  end
end


end
end
