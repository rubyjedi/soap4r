#!/usr/bin/env ruby

require 'soap/driver'

server = 'http://www.ruby-lang.org/~nahi/soap/raa/'
proxy = ARGV.shift || nil


# Type Definition

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


###
## Create Proxy
#
def getWireDumpLogFile
  logFilename = File.basename( $0 ) + '.log'
  f = File.open( logFilename, 'w' )
  f << "File: #{ logFilename } - Wiredumps for SOAP4R client / #{ $serverName } server.\n"
  f << "Date: #{ Time.now }\n\n"
end

raa = SOAP::Driver.new( Log.new( STDERR ), 'SampleApp', RAAInterfaceNS, server, proxy )
raa.setWireDumpDev( getWireDumpLogFile )


# Method definition.
raa.addMethod( 'getAllListings' )
  # => Array of String(product name)

raa.addMethod( 'getProductTree' )
  # => Hash(major category) of Hash(minor category) of Array of String(name)
  
raa.addMethod( 'getInfoFromCategory', 'category' )
  # => Array of Info

raa.addMethod( 'getModifiedInfoSince', 'time' )
  # => Array of Info

raa.addMethod( 'getInfoFromName', 'name' )
  # => Info


###
## Invoke methods.
#
p raa.getAllListings().sort

p raa.getProductTree()

p raa.getInfoFromCategory( Category.new( "Library", "XML" ))

cat = Struct.new( "CCC", "major", "minor" )
p raa.getInfoFromCategory( cat.new( "Library", "XML" ))

t = Time.at( Time.now.to_i - 24 * 3600 )
p raa.getModifiedInfoSince( t )
p raa.getModifiedInfoSince( Date.new3( t.year, t.mon, t.mday, t.hour, t.min, t.sec ))

p raa.getInfoFromName( "SOAP4R" )
