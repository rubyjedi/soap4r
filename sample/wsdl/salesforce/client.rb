#!/usr/bin/env ruby
require 'defaultDriver.rb'
require 'soap/header/simplehandler'

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

calloptions_handler.client = 'client'

parameters = Login.new('NaHi', 'password')
login_result = obj.login(parameters).result
sessionid_handler.sessionid = login_result.sessionId

obj.delete(Delete.new([1, 2, 3]))
