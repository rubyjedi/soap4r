#!/usr/bin/env ruby
require 'defaultDriver.rb'
require 'soap/header/simplehandler'

class RequesterCredentialsHandler < SOAP::Header::SimpleHandler
  HeaderName = XSD::QName.new('urn:ebay:api:PayPalAPI', 'RequesterCredentials')
  CredentialsName =
    XSD::QName.new('urn:ebay:apis:eBLBaseComponents', 'Credentials')
  UsernameName = XSD::QName.new(nil, 'Username')
  PasswordName = XSD::QName.new(nil, 'Password')
  SubjectName = XSD::QName.new(nil, 'Subject')

  def initialize(username, password, subject)
    super(HeaderName)
    @username, @password, @subject = username, password, subject
  end

  def on_simple_outbound
    {CredentialsName => {UsernameName => @username, PasswordName => @password,
      SubjectName => @subject}}
  end
end

endpoint_url = ARGV.shift
obj = PayPalAPIAAInterface.new(endpoint_url)
obj.headerhandler << RequesterCredentialsHandler.new('NaHi', 'pass', 'authorizing_account_emailaddress')
obj.wiredump_dev = STDOUT if $DEBUG

obj.test_loopback_response << File.read("response.xml")
payerInfo = obj.getExpressCheckoutDetails(nil).getExpressCheckoutDetailsResponseDetails.payerInfo
p payerInfo.payerName.firstName
p payerInfo.payerBusiness
exit

getTransactionDetailsRequest = nil
puts obj.getTransactionDetails(getTransactionDetailsRequest)
