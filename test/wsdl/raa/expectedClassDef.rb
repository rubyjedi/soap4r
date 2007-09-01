require 'xsd/qname'

module WSDL::RAA


# {http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/}Category
class Category
  attr_accessor :major
  attr_accessor :minor

  def initialize(major = nil, minor = nil)
    @major = major
    @minor = minor
  end
end

# {http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/}Product
class Product
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
end

# {http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/}StringArray
class StringArray < ::Array
end


end
