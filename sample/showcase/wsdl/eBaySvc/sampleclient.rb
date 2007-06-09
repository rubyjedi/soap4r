#!/usr/bin/env ruby

# This client sample is contributed by Garry Dolley at soap4r ML.
# You need to generate default.rb and defaultDriver.rb by wsdl2ruby.rb tool.
#
# % ruby wsdl2ruby.rb --wsdl http://developer.ebay.com/webservices/latest/eBaySvc.wsdl --type client --force
#
# You may need to get eBaySvc.wsdl and patch it with eBaySvc.wsdl.diff in the
# same directory to avoid eBaySvc.wsdl's namespace usage problem.

require 'defaultDriver.rb'
require 'soap/header/simplehandler'

class RequesterCredentialsHandler < SOAP::Header::SimpleHandler
  HeaderName    = XSD::QName.new('urn:ebay:apis:eBLBaseComponents', 'RequesterCredentials')
  Credentials   = XSD::QName.new('urn:ebay:apis:eBLBaseComponents', 'Credentials')

  EbayAuthToken = XSD::QName.new(nil, 'eBayAuthToken')
  DevId         = XSD::QName.new(nil, 'DevId')
  AppId         = XSD::QName.new(nil, 'AppId')
  AuthCert      = XSD::QName.new(nil, 'AuthCert')

  def initialize(eBayAuthToken, devId, appId, authCert)
    super(HeaderName)
    @token, @devId, @appId, @cert = eBayAuthToken, devId, appId, authCert
  end

  def on_simple_outbound
    { EbayAuthToken => @token,
      Credentials => { DevId => @devId, AppId => @appId, AuthCert => @cert } }
  end
end

callName  = 'GeteBayOfficialTime'
siteId    = '0'
appId     = '__appid__'
devId     = '__devid__'
certId    = '__certid__'
version   = '433'

authToken = '__authtoken__'

endpoint_url = 'https://api.sandbox.ebay.com/wsapi'

request_url  = endpoint_url + '?callname=' + callName +
                              '&siteid=' + siteId +
                              '&appid=' + appId +
                              '&version=' + version +
                              '&routing=default'

service = EBayAPIInterface.new(request_url)
service.headerhandler << RequesterCredentialsHandler.new(authToken,
devId, appId, certId)

request = GeteBayOfficialTimeRequestType.new()
request.version = version

response = service.geteBayOfficialTime(request)

puts response.timestamp
