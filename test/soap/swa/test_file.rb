# encoding: UTF-8
require 'helper'
require 'soap/rpc/driver'
require 'soap/rpc/standaloneServer'
require 'soap/attachment'


module SOAP
module SWA


class TestFile < Test::Unit::TestCase
  Port = 17171
  THIS_FILE = File.expand_path(__FILE__)

  class SwAService
    def get_file
      return {
     	'name' => $0,
	'file' => SOAP::Attachment.new(File.open(THIS_FILE)) # closed when GCed.
      }
    end
  
    def put_file(name, file)
      "File '#{name}' was received ok."
    end
  end

  def setup
    @server = SOAP::RPC::StandaloneServer.new('SwAServer',
      'http://www.acmetron.com/soap', '0.0.0.0', Port)
    @server.add_servant(SwAService.new)
    @server.level = Logger::Severity::ERROR
    @t = Thread.new {
      @server.start
    }
    @endpoint = "http://localhost:#{Port}/"
    @client = SOAP::RPC::Driver.new(@endpoint, 'http://www.acmetron.com/soap')
    @client.add_method('get_file')
    @client.add_method('put_file', 'name', 'file')
    @client.wiredump_dev = STDERR if $DEBUG
  end

  def teardown
    @server.shutdown if @server
    if @t
      # join with a bound, falling back to kill only if genuinely
      # stuck (see git history: unconditional immediate kill raced
      # WEBrick's own async listener cleanup and occasionally leaked
      # the port).
      unless @t.join(10)
        @t.kill
        @t.join
      end
    end
    @client.reset_stream if @client
  end

  def test_get_file
    assert_equal(
      File.open(THIS_FILE) { |f| f.read },
      @client.get_file['file'].content
    )
  end

  def test_put_file
    assert_equal(
      "File 'foo' was received ok.",
      @client.put_file('foo',
	SOAP::Attachment.new(File.open(THIS_FILE)))
    )
    assert_equal(
      "File 'bar' was received ok.",
      @client.put_file('bar',
	SOAP::Attachment.new(File.open(THIS_FILE) { |f| f.read }))
    )
  end
end


end
end
