#!/usr/bin/env ruby

# SOAP server cannot use WEBrick's httpauth feature for now...
require 'soap/rpc/standaloneServer'

class Server < SOAP::RPC::StandaloneServer
  Namespace = 'urn:test'

  class Servant
    @@counter = 0

    def self.create
      new(@@counter += 1)
    end

    def initialize(counter)
      @counter = counter
    end

    def echo(msg)
      "echo from servant ##{@counter} (#{SOAP::RPC::SOAPlet.user}): #{msg}"
    end
  end

  def initialize(*arg)
    super
    add_rpc_request_servant(Servant)
  end

  def on_init
    userdb_file = File.join(File.dirname(__FILE__), 'htpasswd')
    userdb = WEBrick::HTTPAuth::Htpasswd.new(userdb_file)
    self.authenticator = WEBrick::HTTPAuth::BasicAuth.new(:Realm => 'auth', :UserDB => userdb)
  end
end

if $0 == __FILE__
  server = Server.new('tst', Server::Namespace, '0.0.0.0', 7000)
  trap(:INT) do
    server.shutdown
  end
  status = server.start
end
