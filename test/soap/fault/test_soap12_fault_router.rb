# encoding: UTF-8
require 'helper'
require 'soap/rpc/router'
require 'soap/mapping/mapping'
require 'soap/processor'


module SOAP
module Fault


# Phase 2 of SOAP 1.2 support, step 2: wire SOAP12Fault into
# Router#create_fault_response/#fault and FaultError. Direct port of
# test_soaparray.rb's pattern (router.create_fault_response($!) ->
# Processor.unmarshal -> FaultError.new -> Mapping.fault2exception),
# with router.soap_version = SOAPVersion1_2 -- asserting Sender/Receiver
# fault codes appear, not Client/Server, and that the whole chain still
# ends up re-raising the original exception correctly.
class TestSoap12FaultRouter < Test::Unit::TestCase
  def test_parse_fault_soap12
    router = SOAP::RPC::Router.new('parse_soap12_error')
    router.soap_version = SOAP::SOAPVersion1_2
    soap_fault = pump_stack rescue router.create_fault_response($!)
    env = SOAP::Processor.unmarshal(soap_fault.send_string, :soap_version => SOAP::SOAPVersion1_2)
    assert_kind_of(SOAP::SOAP12Fault, env.body.fault)
    assert_equal(SOAP::FaultCode12::Receiver, env.body.fault.code_value)

    soap_fault = SOAP::FaultError.new(env.body.fault)
    assert_raises(RuntimeError) do
      registry = SOAP::Mapping::LiteralRegistry.new
      SOAP::Mapping.fault2exception(soap_fault, registry)
    end
  end

  def test_soap11_fault_router_unaffected
    router = SOAP::RPC::Router.new('parse_soap11_error')
    soap_fault = pump_stack rescue router.create_fault_response($!)
    env = SOAP::Processor.unmarshal(soap_fault.send_string)
    assert_kind_of(SOAP::SOAPFault, env.body.fault)
    # Same pre-existing decode limitation documented on SOAP12Fault#code_value
    # applies here too (not new): the wire value is a raw prefixed string,
    # not resolved back to a QName. Confirms 1.1's own fault path (and its
    # existing Client/Server codes) is untouched by the 1.2 work.
    assert_equal("Server", env.body.fault.faultcode.data.split(':').last)
  end

  def pump_stack(max = 0)
    raise ArgumentError if max > 10
    pump_stack(max+1)
  end
end


end
end
