# urn:example.com:echo-type
class OneAnyMemberStruct
  @@schema_type = "OneAnyMemberStruct"
  @@schema_ns = "urn:example.com:echo-type"

  def any
    @any
  end

  def any=(value)
    @any = value
  end

  def initialize(any = nil)
    @any = any
  end
end

