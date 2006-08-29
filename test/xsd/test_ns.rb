require 'test/unit'
require 'soap/marshal'


module XSD


class TestNS < Test::Unit::TestCase
  def test_xmllang
    @file = File.join(File.dirname(File.expand_path(__FILE__)), 'xmllang.xml')
    obj = SOAP::Marshal.load(File.open(@file) { |f| f.read })
    assert_equal("12345", obj.partyDataLine.gln)
    lang = obj.partyDataLine.__xmlattr[
      XSD::QName.new(XSD::NS::Namespace, "lang")]
    assert_equal("EN", lang)
  end
end


end
