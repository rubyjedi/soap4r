#!/usr/bin/env ruby

require 'soap/rpc/standaloneServer'

class AuthHeaderPortServer < SOAP::RPC::StandaloneServer
  class AuthHeaderService
    def deposit(amt)
      "deposit #{amt} OK"
    end

    def withdrawal(amt)
      "withdrawal #{amt} OK"
    end
  end

  def initialize(*arg)
    super
    add_servant(AuthHeaderService.new, 'http://tempuri.org/authHeaderPort')
  end

end

if $0 == __FILE__
  status = AuthHeaderPortServer.new('AuthHeaderPortServer', nil, '0.0.0.0', 7000).start
end
