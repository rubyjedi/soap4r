require 'xsd/qname'

# {urn:example.com:echo-type}foo.bar
class FooBar
  @@schema_type = "foo.bar"
  @@schema_ns = "urn:example.com:echo-type"
  @@schema_element = [["any", nil]]

  attr_accessor :any

  def initialize(any = nil)
    @any = any
  end
end
