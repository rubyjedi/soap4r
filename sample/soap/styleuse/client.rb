require 'soap/rpc/driver'

server = 'http://localhost:7000/'

app = SOAP::RPC::Driver.new(server, 'urn:styleuse')
app.add_method('rpc_serv', 'obj1', 'obj2')
app.add_method('doc_serv', 'obj')
app.wiredump_dev = STDOUT

p app.rpc_serv(true, false)
p app.doc_serv({:foo => 1, :bar => 2})
