#!/usr/bin/env ruby

require 'soap/rpc/standaloneServer'
require 'soap/header/simplehandler'

class AuthHeaderPortServer < SOAP::RPC::StandaloneServer
  class AuthHeaderService
    def self.create
      new
    end

    def deposit(amt)
      "deposit #{amt} OK"
    end

    def withdrawal(amt)
      "withdrawal #{amt} OK"
    end
  end

  Name = 'http://tempuri.org/authHeaderPort'
  def initialize(*arg)
    super
    add_rpc_servant(AuthHeaderService.new, Name)
    ServerAuthHeaderHandler.init
    add_rpc_request_headerhandler(ServerAuthHeaderHandler)
  end

  class ServerAuthHeaderHandler < SOAP::Header::SimpleHandler
    MyHeaderName = XSD::QName.new("http://tempuri.org/authHeader", "auth")

    class << self
      def create
	new
      end

      def init
	@users = {
	  'NaHi' => 'passwd',
	  'HiNa' => 'wspass'
	}
	@sessions = {}
      end

      def login(userid, passwd)
	userid and passwd and @users[userid] == passwd
      end

      def auth(sessionid)
	@sessions[sessionid][0]
      end

      def create_session(userid)
	while true
	  key = create_sessionkey
	  break unless @sessions[key]
	end
	@sessions[key] = [userid]
	key
      end

      def destroy_session(sessionkey)
	@sessions.delete(sessionkey)
      end

      def a
	@sessions
      end

    private

      def create_sessionkey
	Time.now.usec.to_s
      end
    end

    def initialize
      super(MyHeaderName)
      @userid = @sessionid = nil
    end

    def on_simple_outbound
      { "sessionid" => @sessionid }
    end

    def on_simple_inbound(my_header, mu)
      auth = false
      userid = my_header["userid"]
      passwd = my_header["passwd"]
      if self.class.login(userid, passwd)
	auth = true
      elsif sessionid = my_header["sessionid"]
	if userid = self.class.auth(sessionid)
	  self.class.destroy_session(sessionid)
	  auth = true
	end
      end
      raise RuntimeError.new("authentication failed") unless auth
      @userid = userid
      @sessionid = self.class.create_session(userid)
      p self.class.a
    end
  end
end

if $0 == __FILE__
  status = AuthHeaderPortServer.new('AuthHeaderPortServer', nil, '0.0.0.0', 7000).start
end
