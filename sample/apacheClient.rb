#!/usr/bin/env ruby

require 'soap/driver'

require 'soap/XMLSchemaDatatypes1999'


class SampleClient < Application

  private

  AppName = 'SampleClient'

  NS1 = 'urn:i3solutions-delayed-quotes'
  NS2 = 'urn:AddressFetcher'

  def initialize( server, proxy )
    super( AppName )
    @server = server
    @proxy = proxy
    @logId = Time.now.gmtime.strftime( "%Y-%m-%dT%X+0000" )
#    setLog( AppName.dup << '.log', 'weekly', nil )
    @drv1 = nil
    @drv2 = nil
  end

  def run()
    #@log.sevThreshold = SEV_DEBUG
    #@log.sevThreshold = SEV_INFO
    @log.sevThreshold = SEV_WARN

    # Driver initialize and method definition

    @drv1 = SOAP::Driver.new( @log, @logId, NS1, @server, @proxy )
    @drv1.addMethod( 'getQuote', 'symbol' )

    @drv2 = SOAP::Driver.new( @log, @logId, NS2, @server, @proxy )
    @drv2.addMethod( 'getAddressFromName', 'nameToLookup' )
    @drv2.addMethod( 'addEntry', 'nameToRegister', 'address' )

    # Method invocation

    puts @drv1.getQuote( "IBM" )

    address = @drv2.getAddressFromName( "John B. Good" )
    dumpAddress( address )

    phoneNumber = PhoneNumber.new( 987, '654', '3210' )
    address = Address.new( 123, 'STREET', 'CITY', 'NY', 99999, phoneNumber )
    result = @drv2.addEntry( 'NaHi', address )
    puts 'NaHi has been added.'

    address = @drv2.getAddressFromName( "NaHi" )
    dumpAddress( address )

    return 0
  end

  def dumpAddress( addr )
    phone = addr.phoneNumber
    puts <<EOS
#{ addr.streetNum } #{ addr.streetName }
#{ addr.city }, #{ addr.state } #{ addr.zip }
(#{ phone.areaCode }) #{ phone.exchange }-#{ phone.number }
EOS
  end

  ###
  ## Other utility methods
  #
  def log( sev, message )
    @log.add( sev, "<#{ @logId }> #{ message }", @appName ) if @log
  end
end


class Address
  @@typeName = 'address'
  @@typeNamespace = 'urn:ibm-soap-address-demo'

  attr_accessor :streetNum, :streetName, :city, :state, :zip, :phoneNumber
  def initialize( streetNum = nil, streetName = nil, city = nil, state = nil, zip = nil, phoneNumber = nil )
    @streetNum = streetNum
    @streetName = streetName
    @city = city
    @state = state
    @zip = zip
    @phoneNumber = phoneNumber
  end
end

class PhoneNumber
  @@typeName = 'phone'
  @@typeNamespace = 'urn:ibm-soap-address-demo'

  attr_accessor :areaCode, :exchange, :number
  def initialize( areaCode = nil, exchange = nil, number = nil )
    @exchange = exchange
    @areaCode = areaCode
    @number = number
  end
end

server = ARGV.shift or raise ArgumentError.new( 'Target URL was not given.' )
proxy = ARGV.shift || nil
app = SampleClient.new( server, proxy ).start()
