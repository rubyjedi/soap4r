#!/usr/bin/env ruby

require 'defaultDriver.rb'
require 'soap/header/simplehandler'
include XSD
include SOAP

class SessionHeaderHandler < SOAP::Header::SimpleHandler
  HeaderName = XSD::QName.new('urn:partner.soap.sforce.com', 'SessionHeader')

  attr_accessor :sessionid

  def initialize
    super(HeaderName)
    @sessionid = nil
  end

  def on_simple_outbound
    if @sessionid
      {'sessionId' => @sessionid}
    else
      nil       # no header
    end
  end
end

class CallOptionsHandler < SOAP::Header::SimpleHandler
  HeaderName = XSD::QName.new('urn:partner.soap.sforce.com', 'CallOptions')

  attr_accessor :client

  def initialize
    super(HeaderName)
    @client = nil
  end

  def on_simple_outbound
    if @client
      {'client' => @client}
    else
      nil       # no header
    end
  end
end

sessionid_handler = SessionHeaderHandler.new
calloptions_handler = CallOptionsHandler.new

endpoint_url = ARGV.shift
obj = Soap.new(endpoint_url)
obj.headerhandler << sessionid_handler
obj.headerhandler << calloptions_handler
obj.wiredump_dev = STDOUT

p obj.delete(Delete.new([1, 2, 3]))
p obj.describeSObject(:sObjectType => "hello world")
p obj.describeSObject(DescribeSObject.new("hello world"))

if false
require 'soap/wsdlDriver'
obj = SOAP::WSDLDriverFactory.new("partner.wsdl").create_rpc_driver
end

ns = "urn:sobject.partner.soap.sforce.com"

if false
require 'orderedhash'
sobj = OrderedHash.new
sobj[QName.new(ns, "type")] = "Contact"
sobj[QName.new(ns, "Id")] = "012345678901234567"
#sobj["type"] = "Contact"
#sobj["Id"] = "012345678901234567"
sobj[:FirstName] = "Joe"
sobj[:lastname] = "Blow"
sobj[:Salutation] = "Mr."
sobj[:Phone] = "999.999.9999"
sobj[:Title] = "Purchasing Director"
obj.test_loopback_response << ''
obj.create(:sObjects => [sobj, sobj])
end

if false
ns1 = 'urn:partner.soap.sforce.com'
ns2 = "urn:sobject.partner.soap.sforce.com"
ele = SOAPElement.new(QName.new(ns1, 'create'))
sobj = SOAPElement.new(QName.new(ns1, 'sObjects'))
sobj.add(SOAPElement.new(QName.new(ns2, "type"), "Contact"))
sobj.add(SOAPElement.new(QName.new(ns2, 'Id'), "012345678901234567"))
sobj.add(SOAPElement.new(QName.new(nil, 'FirstName'), 'Joe'))
sobj.add(SOAPElement.new(QName.new(nil, 'lastname'), 'Blow'))
sobj.add(SOAPElement.new(QName.new(nil, 'Salutation'), 'Mr.'))
sobj.add(SOAPElement.new(QName.new(nil, 'Phone'), '999.999.9999'))
sobj.add(SOAPElement.new(QName.new(nil, 'Title'), 'Purchasing Director'))
ele.add(sobj)
ele.add(sobj)
obj.test_loopback_response << ''
obj.create(:sObjects => [sobj, sobj]) rescue nil
end

sobj = [
  [QName.new(ns, "type"), "Contact"],
  [QName.new(ns, "Id"), "012345678901234567"],
  [:FirstName, "Joe"],
  [:lastname, "Blow"],
  [:Salutation, "Mr."],
  [:Phone, "999.999.9999"],
  [:Title, "Purchasing Director"]
]
obj.test_loopback_response << ''
obj.create(:sObjects => [sobj, sobj]) rescue nil


mycontact = SObject.new
mycontact.type = "Contact"
mycontact.Id = "012345678901234567"
mycontact.set_any([
  [:FirstName, "Joe"],
  [:lastname, "Blow"],
  [:Salutation, "Mr."],
  [:Phone, "999.999.9999"],
  [:Title, "Purchasing Director"]
])

obj.test_loopback_response << ''
obj.create(Create.new([mycontact, mycontact])) rescue nil
exit



ns = "urn:sobject.partner.soap.sforce.com"
ele = SOAP::SOAPElement.new(XSD::QName.new(nil, "type"))
ele.text = "Contact"
ele.extraattr["xmlns"] = ns

sobj = SObject.new("Contact")
sobj.instance_eval do
  @Id = "id"
  @FirstName = "Joe"
  @lastname = "Blow"
  @Salutation = "Mr."
  @Phone = "999.999.9999"
  @Title = "Purchasing Director"
end

obj.create(Create.new([sobj]))
#obj.create(Create.new([SObject.new(ele, ["fields", "To", "Null"], "id", {"LastName" => "Spaceley"}) ]))

exit

calloptions_handler.client = 'client'

parameters = Login.new('NaHi', 'password')
login_result = obj.login(parameters).result
sessionid_handler.sessionid = login_result.sessionId

obj.delete(Delete.new([1, 2, 3]))
