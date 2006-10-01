require 'xsd/qname'

# {urn:example.com:echo-type}foo.bar
class FooBar
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
