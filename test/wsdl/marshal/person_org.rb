# http://www.jin.gr.jp/~nahi/xmlns/sample/Person
class Person
  @@schema_type = "Person"
  @@schema_ns = "http://www.jin.gr.jp/~nahi/xmlns/sample/Person"

  def familyname
    @familyname
  end

  def familyname=(value)
    @familyname = value
  end

  def givenname
    @givenname
  end

  def givenname=(value)
    @givenname = value
  end

  def var1
    @var1
  end

  def var1=(value)
    @var1 = value
  end

  def var2
    @var2
  end

  def var2=(value)
    @var2 = value
  end

  def var3
    @var3
  end

  def var3=(value)
    @var3 = value
  end

  def initialize(familyname = nil,
      givenname = nil,
      var1 = nil,
      var2 = nil,
      var3 = nil)
    @familyname = familyname
    @givenname = givenname
    @var1 = var1
    @var2 = var2
    @var3 = var3
  end
end

