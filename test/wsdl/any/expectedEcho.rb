# urn:example.com:echo-type
class FooBar
  @@schema_type = "foo.bar"
  @@schema_ns = "urn:example.com:echo-type"

  attr_accessor :any

  def initialize(any = nil)
    @any = any
  end
end
