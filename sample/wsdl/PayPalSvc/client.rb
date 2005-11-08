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
obj = PayPalAPIInterface.new(endpoint_url)
obj.headerhandler << RequesterCredentialsHandler.new('NaHi', 'pass', 'authorizing_account_emailaddress')
obj.test_loopback_response << ""
obj.wiredump_dev = STDOUT

getTransactionDetailsRequest = nil
puts obj.getTransactionDetails(getTransactionDetailsRequest)
