#!/usr/local/bin/ruby

require 'soap/cgistub'

class Address
  @@typeName = 'address'
  @@namespace = 'urn:ibm-soap-address-demo'

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
  @@namespace = 'urn:ibm-soap-address-demo'

  attr_accessor :areaCode, :exchange, :number
  def initialize( areaCode = nil, exchange = nil, number = nil )
    @exchange = exchange
    @areaCode = areaCode
    @number = number
  end
end


class SampleApp < SOAPCGIStub
  def methodDef
    addMethod( self, "getAddressFromName" )
    addMethod( self, "addEntry" )
  end
  
  def getQuote( symbol )
    152
  end

  def getAddressFromName( nameToLookup )
    ret = Address.new( 123, 'Main Street', 'Anytown', 'NY', 12345, PhoneNumber.new( 123, '456', '7890' ))
    ret
  end

  def addEntry( nameToRegister, address )
    ret = Address.new( 123, 'Main Street', 'Anytown', 'NY', 12345, PhoneNumber.new( 123, '456', '7890' ))
    [ ret, ret, ret ]
  end
end

SampleApp.new( "foo", "http://www.sarion.com/xmlns/nakahiro/soap4r/sample1" ).start
