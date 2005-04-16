require 'xsd/qname'

# {urn:product}Rating
module Rating
  C_0 = "0"
  C_1 = "+1"
  C_1_2 = "-1"
end

# {urn:product}Product-Bag
class ProductBag
  @@schema_type = "Product-Bag"
  @@schema_ns = "urn:product"
  @@schema_attribute = {"version" => "SOAP::SOAPString", "yesno" => "SOAP::SOAPString"}
  @@schema_element = [["bag", "Product[]"], ["rating", ["SOAP::SOAPString[]", XSD::QName.new("urn:product", "Rating")]], ["product_Bag", [nil, XSD::QName.new("urn:product", "Product-Bag")]], ["comment_1", nil], ["comment_2", ["Comment[]", XSD::QName.new(nil, "comment-2")]]]

  attr_accessor :bag
  attr_accessor :product_Bag
  attr_accessor :comment_1
  attr_accessor :comment_2

  def Rating
    @rating
  end

  def Rating=(value)
    @rating = value
  end

  def attr_version
    (@__soap_attribute ||= {})["version"]
  end

  def attr_version=(value)
    (@__soap_attribute ||= {})["version"] = value
  end

  def attr_yesno
    (@__soap_attribute ||= {})["yesno"]
  end

  def attr_yesno=(value)
    (@__soap_attribute ||= {})["yesno"] = value
  end

  def initialize(bag = [], rating = [], product_Bag = nil, comment_1 = [], comment_2 = [])
    @bag = bag
    @rating = rating
    @product_Bag = product_Bag
    @comment_1 = comment_1
    @comment_2 = comment_2
    @__soap_attribute = {}
  end
end

# {urn:product}Creator
class Creator
  @@schema_type = "Creator"
  @@schema_ns = "urn:product"
  @@schema_element = []

  def initialize
  end
end

# {urn:product}Product
class Product
  @@schema_type = "Product"
  @@schema_ns = "urn:product"
  @@schema_element = [["name", "SOAP::SOAPString"], ["rating", ["SOAP::SOAPString", XSD::QName.new("urn:product", "Rating")]]]

  attr_accessor :name

  def Rating
    @rating
  end

  def Rating=(value)
    @rating = value
  end

  def initialize(name = nil, rating = nil)
    @name = name
    @rating = rating
  end
end

# {urn:product}Comment
class Comment < String
end
