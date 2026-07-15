# encoding: UTF-8
require 'helper'
require 'wsdl/importer'


module WSDL
module SOAP


# Phase 4 of SOAP 1.2 support: WSDL binding-namespace recognition. Proves
# the six case/when dispatch points (binding.rb, operationBinding.rb,
# param.rb, port.rb, service.rb, soap/header.rb) actually recognize
# <soap12:binding> etc -- the fixture (soap12/soap12.wsdl) uses the SOAP
# 1.2 WSDL binding namespace exclusively, no <soap:binding> at all, so
# this only passes if every one of those six arms works.
class TestSoap12BindingParse < Test::Unit::TestCase
  DIR = File.dirname(File.expand_path(__FILE__))

  def test_soap12_binding_recognized
    wsdl = WSDL::Importer.import(File.join(DIR, 'soap12', 'soap12.wsdl'))
    binding = wsdl.bindings.find { |b| b.name.name == 'soap12echo_binding' }
    assert_not_nil(binding)
    assert_not_nil(binding.soapbinding)
    assert_equal(true, binding.soapbinding.soap12)
    assert_equal(:rpc, binding.soapbinding.style)

    operation = binding.operations.find { |op| op.name == 'echo' }
    assert_not_nil(operation.soapoperation)

    port = wsdl.services[0].ports[0]
    assert_not_nil(port.soap_address)
    assert_equal('http://localhost:17171/', port.soap_address.location)
  end
end


end
end
