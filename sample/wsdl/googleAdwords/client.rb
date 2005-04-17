require 'soap/wsdlDriver'
require 'soap/header/simplehandler'

wsdl = 'https://adwords.google.com/api/adwords/v2/CampaignService?WSDL'

class HeaderHandler < SOAP::Header::SimpleHandler
  def initialize(tag, value)
    super(XSD::QName.new(nil, tag))
    @tag = tag
    @value = value
  end

  def on_simple_outbound
    {@tag => @value}
  end
end

require 'default'
# I don't have an account of AdWords so the following code is not tested.
# Please tell me (nahi@ruby-lang.org) if you will get good/bad result in
# communicating with AdWords Server...
drv = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
drv.headerhandler << HeaderHandler.new('email', 'nakahiro@gmail.com')
drv.headerhandler << HeaderHandler.new('useragent', 'test')
p drv.getCampaign(GetCampaign.new(123))
