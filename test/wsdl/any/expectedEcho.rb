# urn:example.com:echo-type
class FooBar
  @@schema_type = "foo.bar"
  @@schema_ns = "urn:example.com:echo-type"
  @@schema_attribute = {}
  @@schema_element = {"any" => nil}

  attr_accessor :any

  def initialize(any = nil)
    @any = any
  end
end
