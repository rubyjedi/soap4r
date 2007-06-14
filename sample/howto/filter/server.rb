require 'soap/rpc/standaloneServer'
require 'soap/filter'


class FilterTestServer < SOAP::RPC::StandaloneServer
  class Servant
    def self.create
      new
    end

    def echo(amt)
      amt
    end
  end

  class ServerFilter1 < SOAP::Filter::Handler
    # 15 -> 30
    def on_outbound(envelope, opt)
      unless envelope.body.is_fault
        node = envelope.body.root_node
        node.retval = SOAP::SOAPInt.new(node.retval.data * 2)
        node.elename = XSD::QName.new(nil, 'return')
      end
      envelope
    end

    # 4 -> 5
    def on_inbound(xml, opt)
      xml = xml.sub(/4/, '5')
      xml
    end
  end

  class ServerFilter2 < SOAP::Filter::Handler
    # 5 -> 15
    def on_outbound(envelope, opt)
      unless envelope.body.is_fault
        node = envelope.body.root_node
        node.retval = SOAP::SOAPInt.new(node.retval.data + 10)
        node.elename = XSD::QName.new(nil, 'return')
      end
      envelope
    end

    # 5 -> 6
    def on_inbound(xml, opt)
      xml = xml.sub(/5/, '6')
      xml
    end
  end

  def initialize(*arg)
    super
    add_rpc_servant(Servant.new, "urn:filter")
    self.filterchain << ServerFilter1.new
    self.filterchain << ServerFilter2.new
  end
end


if __FILE__ == $0
  server = FilterTestServer.new(self.class.name, nil, '0.0.0.0', 7171)
  trap("INT") do
    server.shutdown
  end
  server.start
end
