require 'webrick/https'
require 'logger'
require 'rbconfig'

PORT = 17171
DIR = File.dirname(File.expand_path(__FILE__))

def cert(filename)
  OpenSSL::X509::Certificate.new(File.open(File.join(DIR, filename)) { |f|
    f.read
  })
end

def key(filename)
  OpenSSL::PKey::RSA.new(File.open(File.join(DIR, filename)) { |f|
    f.read
  })
end

def do_server_proc(req, res)
  res['content-type'] = 'text/xml'
  res.body = <<__EOX__
<?xml version="1.0" encoding="utf-8" ?>
<env:Envelope xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <env:Body>
    <n1:do_server_proc xmlns:n1="urn:foo" env:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
      <return xsi:type="xsd:string">hello</return>
    </n1:do_server_proc>
  </env:Body>
</env:Envelope>
__EOX__
end

logger = Logger.new(STDERR)
logger.level = Logger::Severity::FATAL	# avoid logging SSLError (ERROR level)

server = WEBrick::HTTPServer.new(
  :BindAddress => "0.0.0.0",
  :Logger => logger,
  :Port => PORT,
  :AccessLog => [],
  :DocumentRoot => DIR,
  :SSLEnable => true,
  :SSLCACertificateFile => File.join(DIR, 'ca.cert'),
  :SSLCertificate => cert('server.cert'),
  :SSLPrivateKey => key('server.key'),
  :SSLVerifyClient => nil, #OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT|OpenSSL::SSL::VERIFY_PEER,
  :SSLClientCA => cert('ca.cert'),
  :SSLCertName => nil
)

server.mount(
  '/',
  WEBrick::HTTPServlet::ProcHandler.new(method(:do_server_proc).to_proc)
)

trap(:INT) do
  server.shutdown
end

STDOUT.sync = true
STDOUT.puts $$
server.start
