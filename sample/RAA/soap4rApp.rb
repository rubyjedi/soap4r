#!/usr/bin/env ruby

proxy = ARGV.shift || nil

require 'soap/driver'

require 'iRAA'
include RAA
server = 'http://www.ruby-lang.org/~nahi/soap/raa/'


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

    @drv = SOAP::Driver.new( @log, @logId, RAA::InterfaceNS, @server, @proxy )

    # Method definition.
    RAA::Methods.each do | method, params |
      @drv.addMethod( method, *( params[1..-1] ))
    end

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

app = SampleClient.new( server, proxy ).start()
