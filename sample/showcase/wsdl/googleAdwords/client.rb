# To generate default.rb, do like this;
# % wsdl2ruby.rb --wsdl "https://adwords.google.com/api/adwords/v2/CampaignService?WSDL" --classdef --force

require 'soap/wsdlDriver'
require 'soap/header/simplehandler'
require 'default'

class HeaderHandler < SOAP::Header::SimpleHandler
  def initialize(tag, value)
    super(XSD::QName.new(nil, tag))
    @tag = tag
    @value = value
  end

  def on_simple_outbound
    @value
  end
end

wsdl = 'https://adwords.google.com/api/adwords/v2/CampaignService?WSDL'

client = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver

client.wiredump_dev = STDOUT  # Log high-level activity
client.wiredump_file_base = "log"  # Log SOAP request and response

# My Client Center manager account
client.headerhandler << HeaderHandler.new('email', 'email@example.com')

client.headerhandler << HeaderHandler.new('password', 'mypassword')
client.headerhandler << HeaderHandler.new('useragent', 'soap4r test')
client.headerhandler << HeaderHandler.new('token', 'XYZ1234567890')

# (Optional) Any client account you manage
client.headerhandler << HeaderHandler.new('clientEmail', 'abc@mail.com')

camplist = client.call("getAllAdWordsCampaigns",
  GetAllAdWordsCampaigns.new(123))

p camplist 
