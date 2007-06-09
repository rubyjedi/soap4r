require 'soap/rpc/driver'

server = ARGV.shift || 'http://localhost:7000/'

drv = SOAP::RPC::Driver.new(server, 'http://tempuri.org/base64Service')
drv.wiredump_dev = STDERR if $DEBUG

drv.add_method('echo', 'arg')
drv.add_method('echo_base64', 'arg')

binary = "\0\0\0"
text = "000"

drv.echo(binary)        # => binary is automatically converted to Base64

drv.echo(text)                              # => send as String
drv.echo_base64(SOAP::SOAPBase64.new(text)) # => send as Base64 explicitly
