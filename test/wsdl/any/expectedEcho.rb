require 'xsd/qname'

# {urn:example.com:echo-type}foo.bar
class FooBar
  @@schema_type = "foo.bar"
  @@schema_ns = "urn:example.com:echo-type"
  @@schema_element = [
    ["before", ["SOAP::SOAPString", XSD::QName.new(nil, "before")]],
    ["any", [nil, XSD::QName.new("http://www.w3.org/2001/XMLSchema", "anyType")]],
    ["after", ["SOAP::SOAPString", XSD::QName.new(nil, "after")]]]

  attr_accessor :before
  attr_reader :__xmlele_any
  attr_accessor :after

  def set_any(elements)
    @__xmlele_any = elements
  end

  def initialize(before = nil, after = nil)
    @before = before
    @__xmlele_any = nil
    @after = after
  end
end
