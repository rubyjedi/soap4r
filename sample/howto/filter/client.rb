require 'soap/rpc/driver'


class ClientFilter1 < SOAP::Filter::Handler
  # 1 -> 2
  def on_outbound(envelope, opt)
    param = envelope.body.root_node.inparam
    param["amt"] = SOAP::SOAPInt.new(param["amt"].data + 1)
    param["amt"].elename = XSD::QName.new(nil, 'amt')
    envelope
  end

  # 31 -> 32
  def on_inbound(xml, opt)
    xml = xml.sub(/31/, '32')
    xml
  end
end

class ClientFilter2 < SOAP::Filter::Handler
  # 2 -> 4
  def on_outbound(envelope, opt)
    param = envelope.body.root_node.inparam
    param["amt"] = SOAP::SOAPInt.new(param["amt"].data * 2)
    param["amt"].elename = XSD::QName.new(nil, 'amt')
    envelope
  end

  # 30 -> 31
  def on_inbound(xml, opt)
    xml = xml.sub(/30/, '31')
    xml
  end
end


client = SOAP::RPC::Driver.new("http://localhost:7171", "urn:filter")
client.add_method('echo', 'amt')
client.filterchain << ClientFilter1.new
client.filterchain << ClientFilter2.new

p client.echo(1)
