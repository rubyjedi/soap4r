module RAA

  InterfaceNS = "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.1"

  class Category
    include SOAP::Marshallable
    @@typeNamespace = InterfaceNS

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

  class Product
    include SOAP::Marshallable
    @@typeNamespace = InterfaceNS

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

  class Owner
    include SOAP::Marshallable
    @@typeNamespace = InterfaceNS

    attr_reader :id
    attr_accessor :email, :name

    def initialize( email, name )
      @email = email
      @name = name
      @id = "#{ @email }-#{ @name }"
    end
  end

  class Info
    include SOAP::Marshallable
    @@typeNamespace = InterfaceNS

    attr_accessor :category, :product, :owner, :update

    def initialize( category = nil, product = nil, owner = nil, update = nil )
      @category = category
      @product = product
      @owner = owner
      @update = update
    end
  end

  Methods = {
    'getAllListings' => [ 'Array' ],
    'getProductTree' => [ 'Hash' ],
    'getInfoFromCategory' => [ 'Array', 'category' ],
    'getModifiedInfoSince' => [ 'Array', 'time' ],
    'getInfoFromName' => [ 'Info', 'name' ],
  }
end
