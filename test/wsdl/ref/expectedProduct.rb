# urn:product
module Rating
  C_0 = "0"
  C_1 = "+1"
  C_1_2 = "-1"
end

# urn:product
class ProductBag
  @@schema_type = "ProductBag"
  @@schema_ns = "urn:product"
  @@schema_attribute = {"version" => "SOAP::SOAPString", "yesno" => "SOAP::SOAPString"}
  @@schema_element = {"bag" => "Product[]", "Rating" => "SOAP::SOAPString[]", "ProductBag" => nil, "comment_1" => nil, "comment_2" => "Comment[]"}

  attr_accessor :bag
  attr_accessor :comment_1
  attr_accessor :comment_2

  def Rating
    @rating
  end

  def Rating=(value)
    @rating = value
  end

  def ProductBag
    @productBag
  end

  def ProductBag=(value)
    @productBag = value
  end

  def attr_version
    @__soap_attribute["version"]
  end

  def attr_version=(value)
    @__soap_attribute["version"] = value
  end

  def attr_yesno
    @__soap_attribute["yesno"]
  end

  def attr_yesno=(value)
    @__soap_attribute["yesno"] = value
  end

  def initialize(bag = [], rating = [], productBag = nil, comment_1 = [], comment_2 = [])
    @bag = bag
    @rating = rating
    @productBag = productBag
    @comment_1 = comment_1
    @comment_2 = comment_2
    @__soap_attribute = {}
  end
end

# urn:product
class Creator
  @@schema_type = "Creator"
  @@schema_ns = "urn:product"
  @@schema_element = {}

  def initialize
  end
end

# urn:product
class Product
  @@schema_type = "Product"
  @@schema_ns = "urn:product"
  @@schema_element = {"name" => "SOAP::SOAPString", "Rating" => "SOAP::SOAPString"}

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

# urn:product
class Comment < String
end
