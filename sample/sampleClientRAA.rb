#!/usr/bin/env ruby

$:.push( '../lib' )
$:.push( '../redist' )

require 'sampleDriver'
require 'application'


RAAInterfaceNS = "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.1"

class Category
  @@namespace = RAAInterfaceNS

  attr_accessor :major, :minor

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
  @@namespace = RAAInterfaceNS

  attr_accessor :name
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
  @@namespace = RAAInterfaceNS

  attr_accessor :id
  attr_accessor :email, :name

  def initialize( email, name )
    @email = email
    @name = name
    @id = "#{ @email }-#{ @name }"
  end
end

class Info
  @@namespace = RAAInterfaceNS

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

  NS = 'http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.1'

  def initialize( server, proxy )
    super( AppName )
    @server = server
    @proxy = proxy
    @logId = Time.now.gmtime.strftime( "%Y-%m-%dT%X+0000" )
    @drv = nil
  end

  def run()
    @log.sevThreshold = SEV_DEBUG

    @drv = SampleDriver.new( @log, @logId, NS, @server, @proxy )
    @drv.addMethod( 'getAllListings' )
    @drv.addMethod( 'getInfoFromCategory', 'category' )
    @drv.addMethod( 'getModifiedInfoSince', 'time' )
    @drv.addMethod( 'getInfoFromName', 'name' )

    p @drv.getAllListings()

    p @drv.getCategoryListings( Category.new( "Library", "XML" ))

    recent = @drv.getModifiedListings( Time.at( Time.now.to_i - 24 * 3600 ))
    p recent.length

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

#server = ARGV.shift or raise ArgumentError.new( 'Target URL was not given.' )
#proxy = ARGV.shift || nil

server = 'http://www.ruby-lang.org/~nahi/soap/'
proxy = nil
app = SampleClient.new( server, proxy ).start()
