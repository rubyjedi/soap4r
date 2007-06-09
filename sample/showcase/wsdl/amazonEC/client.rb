require 'soap/wsdlDriver'

wsdl = 'http://webservices.amazon.com/AWSECommerceService/JP/AWSECommerceService.wsdl'
wsdl = 'AWSECommerceService.wsdl'

require 'default'
drv = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
drv.wiredump_dev = STDOUT if $DEBUG

# I don't have an account of AWSECommerce so the following code is not tested.
# Please tell me (nahi@ruby-lang.org) if you will get good/bad result in
# communicating with AWSECommerce Server...
p drv.ItemSearch(ItemSearch.new("123", "tag", "Double", "validate"))
