# http://www.jin.gr.jp/~nahi/xmlns/sample/Person
class Person
  @@schema_type = "Person"
  @@schema_ns = "http://www.jin.gr.jp/~nahi/xmlns/sample/Person"

  attr_accessor :familyname
  attr_accessor :givenname
  attr_accessor :var1
  attr_accessor :var2
  attr_accessor :var3

  def initialize(familyname = nil, givenname = nil, var1 = nil, var2 = nil, var3 = nil)
    @familyname = familyname
    @givenname = givenname
    @var1 = var1
    @var2 = var2
    @var3 = var3
  end
end
