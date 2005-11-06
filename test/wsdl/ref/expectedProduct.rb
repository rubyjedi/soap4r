require 'xsd/qname'

# {urn:ref}Rating
module Rating
  C_0 = "0"
  C_1 = "+1"
  C_1_2 = "-1"
end

# {urn:ref}Product-Bag
class ProductBag
  @@schema_type = "Product-Bag"
  @@schema_ns = "urn:ref"
  @@schema_attribute = {XSD::QName.new("urn:ref", "version") => "SOAP::SOAPString", XSD::QName.new("urn:ref", "yesno") => "SOAP::SOAPString"}
  @@schema_element = [
    ["bag", ["Product[]", XSD::QName.new(nil, "bag")]],
    ["rating", ["SOAP::SOAPString[]", XSD::QName.new("urn:ref", "Rating")]],
    ["comment_1", ["[]", XSD::QName.new(nil, "comment_1")]],
    ["comment_2", ["Comment[]", XSD::QName.new(nil, "comment-2")]]]

  attr_accessor :bag
  attr_accessor :rating
  attr_accessor :comment_1
  attr_accessor :comment_2

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

  def initialize(bag = [], rating = [], comment_1 = [], comment_2 = [])
    @bag = bag
    @rating = rating
    @comment_1 = comment_1
    @comment_2 = comment_2
    @__xmlattr = {}
  end
end

# {urn:ref}Creator
class Creator < String
  @@schema_attribute = {XSD::QName.new(nil, "Role") => nil}

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
module Yesno
  N = "N"
  Y = "Y"
end

# {urn:ref}Product
class Product
  @@schema_type = "Product"
  @@schema_ns = "urn:ref"
  @@schema_element = [
    ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "name")]],
    ["rating", ["SOAP::SOAPString", XSD::QName.new("urn:ref", "Rating")]]]

  attr_accessor :name
  attr_accessor :rating

  def initialize(name = nil, rating = nil)
    @name = name
    @rating = rating
  end
end

# {urn:ref}Comment
class Comment < String
  @@schema_attribute = {XSD::QName.new(nil, "msgid") => "SOAP::SOAPString"}

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
