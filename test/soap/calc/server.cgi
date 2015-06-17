# encoding: UTF-8
$:.unshift File.expand_path( File.dirname(__FILE__) + '../../../../lib')

require 'soap/rpc/cgistub'

class CalcServer < SOAP::RPC::CGIStub
  def initialize(*arg)
    super
    begin
      require_relative './calc'
    rescue
      require 'calc' # RubyJedi: This exists for the benefit of Ruby 1.8.7
    end
    servant = CalcService
    add_servant(servant, 'http://tempuri.org/calcService')
  end
end

status = CalcServer.new('CalcServer', nil).start
