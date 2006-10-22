require 'xsd/qname'

# {urn:ref}Rating
class Rating < ::String
  C_0 = Rating.new("0")
  C_1 = Rating.new("+1")
  C_1_2 = Rating.new("-1")
end

# {urn:ref}Product-Bag
class ProductBag
  attr_accessor :bag
  attr_accessor :rating
  attr_accessor :comment_1
  attr_accessor :comment_2

  def m___point
    @v___point
  end

  def m___point=(value)
    @v___point = value
  end

  def xmlattr_version
    (@__xmlattr ||= {})[XSD::QName.new("urn:ref", "version")]
  end

  def xmlattr_version=(value)
    (@__xmlattr ||= {})[XSD::QName.new("urn:ref", "version")] = value
  end

  def xmlattr_yesno
    (@__xmlattr ||= {})[XSD::QName.new("urn:ref", "yesno")]
  end

  def xmlattr_yesno=(value)
    (@__xmlattr ||= {})[XSD::QName.new("urn:ref", "yesno")] = value
  end

  def initialize(bag = [], rating = [], comment_1 = [], comment_2 = [], v___point = nil)
    @bag = bag
    @rating = rating
    @comment_1 = comment_1
    @comment_2 = comment_2
    @v___point = v___point
    @__xmlattr = {}
  end
end

# {urn:ref}Creator
class Creator < ::String
  def xmlattr_Role
    (@__xmlattr ||= {})[XSD::QName.new(nil, "Role")]
  end

  def xmlattr_Role=(value)
    (@__xmlattr ||= {})[XSD::QName.new(nil, "Role")] = value
  end

  def initialize(*arg)
    super
    @__xmlattr = {}
  end
end

# {urn:ref}yesno
class Yesno < ::String
  N = Yesno.new("N")
  Y = Yesno.new("Y")
end

# {urn:ref}Product
class Product
  attr_accessor :name
  attr_accessor :rating

  def initialize(name = nil, rating = nil)
    @name = name
    @rating = rating
  end
end

# {urn:ref}Comment
class Comment < ::String
  def xmlattr_msgid
    (@__xmlattr ||= {})[XSD::QName.new(nil, "msgid")]
  end

  def xmlattr_msgid=(value)
    (@__xmlattr ||= {})[XSD::QName.new(nil, "msgid")] = value
  end

  def initialize(*arg)
    super
    @__xmlattr = {}
  end
end

# {urn:ref}_point
class C__point < ::String
  def xmlattr_unit
    (@__xmlattr ||= {})[XSD::QName.new(nil, "unit")]
  end

  def xmlattr_unit=(value)
    (@__xmlattr ||= {})[XSD::QName.new(nil, "unit")] = value
  end

  def initialize(*arg)
    super
    @__xmlattr = {}
  end
end

# {urn:ref}Document
class Document < ::String
  def xmlattr_ID
    (@__xmlattr ||= {})[XSD::QName.new(nil, "ID")]
  end

  def xmlattr_ID=(value)
    (@__xmlattr ||= {})[XSD::QName.new(nil, "ID")] = value
  end

  def initialize(*arg)
    super
    @__xmlattr = {}
  end
end

# {urn:ref}DerivedChoice_BaseSimpleContent
class DerivedChoice_BaseSimpleContent
  attr_accessor :varStringExt
  attr_accessor :varFloatExt

  def xmlattr_ID
    (@__xmlattr ||= {})[XSD::QName.new(nil, "ID")]
  end

  def xmlattr_ID=(value)
    (@__xmlattr ||= {})[XSD::QName.new(nil, "ID")] = value
  end

  def xmlattr_attrStringExt
    (@__xmlattr ||= {})[XSD::QName.new(nil, "attrStringExt")]
  end

  def xmlattr_attrStringExt=(value)
    (@__xmlattr ||= {})[XSD::QName.new(nil, "attrStringExt")] = value
  end

  def initialize(varStringExt = nil, varFloatExt = nil)
    @varStringExt = varStringExt
    @varFloatExt = varFloatExt
    @__xmlattr = {}
  end
end
