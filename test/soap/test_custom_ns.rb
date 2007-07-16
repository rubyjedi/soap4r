require 'test/unit'
require 'soap/processor'


module SOAP


class TestCustomNs < Test::Unit::TestCase
  NORMAL_XML = <<__XML__.chomp
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:env="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Header>
      <n1:headeritem xmlns:n1="my:foo"
          env:mustUnderstand="0">hi</n1:headeritem>
  </env:Header>
  <env:Body>
    <n2:test xmlns:n2="my:foo">bi</n2:test>
  </env:Body>
</env:Envelope>
__XML__

  CUSTOM_NS_XML = <<__XML__.chomp
<?xml version="1.0" encoding="utf-8" ?>
<ENV:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:myns="my:foo"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <ENV:Header>
      <myns:headeritem ENV:mustUnderstand="0">hi</myns:headeritem>
  </ENV:Header>
  <ENV:Body>
    <myns:test>bi</myns:test>
  </ENV:Body>
</ENV:Envelope>
__XML__

  def test_custom_ns
    # create test env
    header = SOAP::SOAPHeader.new()
    hi = SOAP::SOAPElement.new(XSD::QName.new("my:foo", "headeritem"), 'hi')
    header.add("test", hi)
    body = SOAP::SOAPBody.new()
    bi = SOAP::SOAPElement.new(XSD::QName.new("my:foo", "bodyitem"), 'bi')
    body.add("test", bi)
    env = SOAP::SOAPEnvelope.new(header, body)
    # normal
    opt = {}
    result = SOAP::Processor.marshal(env, opt)
    assert_equal(NORMAL_XML, result)
    # ns customize
    ns = XSD::NS.new
    ns.assign(SOAP::EnvelopeNamespace, 'ENV')
    ns.assign('my:foo', 'myns')
    opt = { :default_ns => ns }
    result = SOAP::Processor.marshal(env, opt)
    assert_equal(CUSTOM_NS_XML, result)
  end
end


end
