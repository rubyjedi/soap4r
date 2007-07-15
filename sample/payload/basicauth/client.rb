require 'soap/rpc/driver'

# SOAP client with BasicAuth requires httpclient.
# http://raa.ruby-lang.org/project/httpclient/
drv = SOAP::RPC::Driver.new('http://localhost:7000/', 'urn:test')
drv.wiredump_dev = STDERR if $DEBUG
drv.options["protocol.http.basic_auth"] <<
  ['http://localhost:7000/', "admin", "admin"]

p drv.add_method('echo', 'msg').call('hello')
