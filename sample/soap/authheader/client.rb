require 'soap/rpc/driver'
require 'soap/header/simpleHandler'

server = ARGV.shift || 'http://localhost:7000/'

class AuthHeaderHandler < SOAP::Header::SimpleHandler
  MyHeaderName = XSD::QName.new("http://tempuri.org/authHeader", "auth")

  def initialize(userid, passwd)
    super(MyHeaderName)
    @session_id = nil
    @userid = userid
    @passwd = passwd
  end

  def on_simple_outbound
    if @session_id
      { :session_id => @session_id }
    else
      { :userid => @userid, :passwd => @passwd }
    end
  end

  def on_simple_inbound(my_header)
    @session_id = my_header[:session_id]
  end
end

serv = SOAP::RPC::Driver.new(server, 'http://tempuri.org/authHeaderPort')
serv.add_method('deposit', 'amt')
serv.add_method('withdrawal', 'amt')

auth_headeritem = AuthHeaderHandler.new('NaHi', 'passwd')
serv.headerhandler << auth_headeritem

serv.wiredump_dev = STDOUT

p serv.deposit(150)
p serv.withdrawal(120)
