# encoding: UTF-8
$:.unshift File.expand_path(File.dirname(__FILE__)+'/../../../lib')
$:.unshift '.' if RUBY_VERSION.to_f >= 1.9
require 'soap/rpc/cgistub'

class CalcServer < SOAP::RPC::CGIStub
  def initialize(*arg)
    super

    require 'calc'
    servant = CalcService
    add_servant(servant, 'http://tempuri.org/calcService')
  end
end

status = CalcServer.new('CalcServer', nil).start
