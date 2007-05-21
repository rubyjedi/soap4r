require 'soap/header/simplehandler'
require 'mms_MizGISDriver.rb'

class BasicAuthHeaderHandler < SOAP::Header::SimpleHandler
  MyHeaderName = XSD::QName.new('http://soap-authentication.org/basic/2001/10/', 'BasicAuth')

  def initialize(name, password)
    super(MyHeaderName)
    @name = name
    @password = password
  end

  def on_simple_outbound
    { 'Name' => @name, 'Password' => @password }
  end

  def on_simple_inbound(header, mustunderstand)
    p [header, mustunderstand]
  end
end

obj = Mms_MizGISPortType.new
obj.headerhandler << BasicAuthHeaderHandler.new('NaHi', 'HiNa')
obj.wiredump_dev = STDOUT
obj.getVersion
