require 'soap/rpcUtils'


module RAA; extend SOAP


InterfaceNS = "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.1"
MappingRegistry = SOAP::RPCUtils::MappingRegistry.new

Methods = [
  [ 'getAllListings', [ 'retval', 'return' ]],
  [ 'getProductTree', [ 'retval', 'return' ]],
  [ 'getInfoFromCategory', [ 'in', 'category' ], [ 'retval', 'return' ]],
  [ 'getModifiedInfoSince', [ 'in', 'time' ], [ 'retval', 'return' ]],
  [ 'getInfoFromName', [ 'in', 'name' ], [ 'retval', 'return' ]],
]

class Category
  include SOAP::Marshallable

  attr_reader :major, :minor

  def initialize( major, minor = nil )
    @major = major
    @minor = minor
  end

  def to_s
    "#{ @major }/#{ @minor }"
  end

  def ==( rhs )
    if @major != rhs.major
      false
    elsif !@minor or !rhs.minor
      true
    else
      @minor == rhs.minor
    end
  end
end

MappingRegistry.set(
  ::RAA::Category,
  ::SOAP::SOAPStruct,
  ::SOAP::RPCUtils::MappingRegistry::TypedStructFactory,
  [ InterfaceNS, "Category" ]
)

class Product
  include SOAP::Marshallable

  attr_reader :name
  attr_accessor :version, :status, :homepage, :download, :license, :description

  def initialize( name, version = nil, status = nil, homepage = nil, download = nil, license = nil, description = nil )
    @name = name
    @version = version
    @status = status
    @homepage = homepage
    @download = download
    @license = license
    @description = description
  end
end

MappingRegistry.set(
  ::RAA::Product,
  ::SOAP::SOAPStruct,
  ::SOAP::RPCUtils::MappingRegistry::TypedStructFactory,
  [ InterfaceNS, "Product" ]
)

class Owner
  include SOAP::Marshallable

  attr_reader :id
  attr_accessor :email, :name

  def initialize( email, name )
    @email = email
    @name = name
    @id = "#{ @email }-#{ @name }"
  end
end

MappingRegistry.set(
  ::RAA::Owner,
  ::SOAP::SOAPStruct,
  ::SOAP::RPCUtils::MappingRegistry::TypedStructFactory,
  [ InterfaceNS, "Owner" ]
)

class Info
  include SOAP::Marshallable

  attr_accessor :category, :product, :owner, :update

  def initialize( category = nil, product = nil, owner = nil, update = nil )
    @category = category
    @product = product
    @owner = owner
    @update = update
  end

  def <=>( rhs )
    @update <=> rhs.update
  end

  def eql?( rhs )
    @product.name == rhs.product.name
  end
end

MappingRegistry.set(
  ::RAA::Info,
  ::SOAP::SOAPStruct,
  ::SOAP::RPCUtils::MappingRegistry::TypedStructFactory,
  [ InterfaceNS, "Info" ]
)

class StringArray < Array; end
MappingRegistry.set(
  ::RAA::StringArray,
  ::SOAP::SOAPArray,
  ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
  [ XSD::Namespace, XSD::StringLiteral ]
)

class InfoArray < Array; end
MappingRegistry.set(
  ::RAA::InfoArray,
  ::SOAP::SOAPArray,
  ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
  [ InterfaceNS, 'Info' ]
)


end
