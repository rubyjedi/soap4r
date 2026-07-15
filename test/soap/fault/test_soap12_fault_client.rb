# encoding: UTF-8
require 'helper'
require 'soap/rpc/driver'
require 'soap/rpc/standaloneServer'


module SOAP
module Fault


# Phase 2 of SOAP 1.2 support, step 2 (continued): full client-side
# canned-envelope test mirroring test_fault.rb, but feeding a hand-built
# SOAP 1.2 fault envelope through a driver configured with
# soap_version = SOAPVersion1_2, confirming the raised FaultError carries
# the right message end to end (parser -> SOAP12Fault -> FaultError).
class TestSoap12FaultClient < Test::Unit::TestCase
  def setup
    @client = SOAP::RPC::Driver.new(nil, 'urn:fault')
    @client.wiredump_dev = STDERR if $DEBUG
    @client.soap_version = SOAP::SOAPVersion1_2
    @client.add_method("hello", "msg")
  end

  def teardown
    @client.reset_stream if @client
  end

  def test_soap12_fault
    @client.mapping_registry = SOAP::Mapping::EncodedRegistry.new
    @client.test_loopback_response << <<__XML__
<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope">
  <env:Body>
    <env:Fault>
      <env:Code>
        <env:Value>env:Sender</env:Value>
      </env:Code>
      <env:Reason>
        <env:Text xml:lang="en">DN cannot be empty</env:Text>
      </env:Reason>
    </env:Fault>
  </env:Body>
</env:Envelope>
__XML__
    begin
      @client.hello("world")
      assert(false)
    rescue ::SOAP::FaultError => e
      assert_equal("DN cannot be empty", e.message)
      assert_equal(SOAP::FaultCode12::Sender, e.faultcode)
    end
  end
end


end
end
