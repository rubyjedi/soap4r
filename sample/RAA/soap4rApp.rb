#!/usr/bin/env ruby

require 'soap/driver'

RAAInterfaceNS = "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.1"

class Category
  include SOAP::Marshallable
  @@typeNamespace = RAAInterfaceNS

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
  @@typeNamespace = RAAInterfaceNS

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
  @@typeNamespace = RAAInterfaceNS

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
  @@typeNamespace = RAAInterfaceNS

  attr_accessor :category, :product, :owner, :update

  def initialize( category = nil, product = nil, owner = nil, update = nil )
    @category = category
    @product = product
    @owner = owner
    @update = update
  end
end

class SampleClient < Application
private

  AppName = 'SampleClient'

  def initialize( server, proxy )
    super( AppName )
    @server = server
    @proxy = proxy
    @logId = Time.now.gmtime.strftime( "%Y-%m-%dT%X+0000" )
    @drv = nil
  end

  def run()
    @log.sevThreshold = SEV_WARN

    @drv = SOAPDriver.new( @log, @logId, RAAInterfaceNS, @server, @proxy )

    # Method definition.
    @drv.addMethod( 'getAllListings' )
      # => Array of String(product name)

    @drv.addMethod( 'getProductTree' )
      # => Hash(major category) of Hash(minor category) of Array of String(name)
      
    @drv.addMethod( 'getInfoFromCategory', 'category' )
      # => Array of Info

    @drv.addMethod( 'getModifiedInfoSince', 'time' )
      # => Array of Info

    @drv.addMethod( 'getInfoFromName', 'name' )
      # => Info

    p @drv.getAllListings()
    p @drv.getProductTree()
    p @drv.getInfoFromCategory( Category.new( "Library", "XML" ))

    t = Time.at( Time.now.to_i - 10 * 3600 )
    p @drv.getModifiedInfoSince( t )
    p @drv.getModifiedInfoSince( Date.new3( t.year, t.mon, t.mday, t.hour, t.min, t.sec ))

    p @drv.getInfoFromName( "SOAP4R" )

#    # This will take a long time...
#    @drv.getAllListings().each do |name|
#      productInfo = @drv.getInfoFromName( name )
#      p productInfo
#    end
  end


  ###
  ## Other utility methods
  #
  def log( sev, message )
    @log.add( sev, "<#{ @logId }> #{ message }", @appName ) if @log
  end
end

server = 'http://www.ruby-lang.org/~nahi/soap/raa/'
proxy = ARGV.shift || nil

app = SampleClient.new( server, proxy ).start()
