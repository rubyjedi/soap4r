require 'soap/rpc/standaloneServer'
require 'soap/filter'


class CustomNSTestServer < SOAP::RPC::StandaloneServer
  class Servant
    def self.create
      new
    end

    def echo(amt)
      amt
    end
  end

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

  def initialize(*arg)
    super
    add_rpc_servant(Servant.new, "urn:custom_ns")
    self.filterchain << DefaultNSFilter.new
  end
end


if __FILE__ == $0
  server = CustomNSTestServer.new(self.class.name, nil, '0.0.0.0', 7171)
  trap("INT") do
    server.shutdown
  end
  server.start
end
