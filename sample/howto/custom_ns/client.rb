require 'soap/rpc/driver'
require 'soap/header/simplehandler'


class DefaultNSFilter < SOAP::Filter::Handler
  def on_outbound(envelope, opt)
    opt[:default_ns] = @default_ns
    envelope
  end

  def initialize
    @default_ns = SOAP::NS.new
    @default_ns.assign('urn:custom_ns', 'myns')
  end
end


class MyHeaderHandler < SOAP::Header::SimpleHandler
  MyHeaderName = XSD::QName.new('urn:custom_ns', 'myheader')

  def initialize
    super(MyHeaderName)
  end

  def on_simple_outbound
    { "hello" => "world" }
  end
end


client = SOAP::RPC::Driver.new("http://localhost:7171", "urn:custom_ns")
client.add_method('echo', 'amt')
client.filterchain << DefaultNSFilter.new
client.headerhandler << MyHeaderHandler.new
client.wiredump_dev = STDOUT

p client.echo(1)
