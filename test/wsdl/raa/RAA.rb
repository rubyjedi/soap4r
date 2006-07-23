require 'xsd/qname'

# {http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/}Category
class Category
  @@schema_type = "Category"
  @@schema_ns = "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/"
  @@schema_element = [
    ["major", ["SOAP::SOAPString", XSD::QName.new(nil, "major")]],
    ["minor", ["SOAP::SOAPString", XSD::QName.new(nil, "minor")]]
  ]

  attr_accessor :major
  attr_accessor :minor

  def initialize(major = nil, minor = nil)
    @major = major
    @minor = minor
  end
end

# {http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/}Product
class Product
  @@schema_type = "Product"
  @@schema_ns = "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/"
  @@schema_element = [
    ["id", ["SOAP::SOAPInt", XSD::QName.new(nil, "id")]],
    ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "name")]],
    ["short_description", ["SOAP::SOAPString", XSD::QName.new(nil, "short_description")]],
    ["version", ["SOAP::SOAPString", XSD::QName.new(nil, "version")]],
    ["status", ["SOAP::SOAPString", XSD::QName.new(nil, "status")]],
    ["homepage", ["SOAP::SOAPAnyURI", XSD::QName.new(nil, "homepage")]],
    ["download", ["SOAP::SOAPAnyURI", XSD::QName.new(nil, "download")]],
    ["license", ["SOAP::SOAPString", XSD::QName.new(nil, "license")]],
    ["description", ["SOAP::SOAPString", XSD::QName.new(nil, "description")]]
  ]

  attr_accessor :id
  attr_accessor :name
  attr_accessor :short_description
  attr_accessor :version
  attr_accessor :status
  attr_accessor :homepage
  attr_accessor :download
  attr_accessor :license
  attr_accessor :description

  def initialize(id = nil, name = nil, short_description = nil, version = nil, status = nil, homepage = nil, download = nil, license = nil, description = nil)
    @id = id
    @name = name
    @short_description = short_description
    @version = version
    @status = status
    @homepage = homepage
    @download = download
    @license = license
    @description = description
  end
end

# {http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/}Owner
class Owner
  @@schema_type = "Owner"
  @@schema_ns = "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/"
  @@schema_element = [
    ["id", ["SOAP::SOAPInt", XSD::QName.new(nil, "id")]],
    ["email", ["SOAP::SOAPAnyURI", XSD::QName.new(nil, "email")]],
    ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "name")]]
  ]

  attr_accessor :id
  attr_accessor :email
  attr_accessor :name

  def initialize(id = nil, email = nil, name = nil)
    @id = id
    @email = email
    @name = name
  end
end

# {http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/}Info
class Info
  @@schema_type = "Info"
  @@schema_ns = "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/"
  @@schema_element = [
    ["category", ["Category", XSD::QName.new(nil, "category")]],
    ["product", ["Product", XSD::QName.new(nil, "product")]],
    ["owner", ["Owner", XSD::QName.new(nil, "owner")]],
    ["created", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "created")]],
    ["updated", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "updated")]]
  ]

  attr_accessor :category
  attr_accessor :product
  attr_accessor :owner
  attr_accessor :created
  attr_accessor :updated

  def initialize(category = nil, product = nil, owner = nil, created = nil, updated = nil)
    @category = category
    @product = product
    @owner = owner
    @created = created
    @updated = updated
  end
end

# {http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/}InfoArray
class InfoArray < ::Array
  @@schema_element = [
    ["item", ["Info", XSD::QName.new(nil, "item")]]
  ]
end

# {http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/}StringArray
class StringArray < ::Array
  @@schema_element = [
    ["item", ["String", XSD::QName.new(nil, "item")]]
  ]
end
