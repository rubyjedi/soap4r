require 'soap/rpc/driver'

Namespace = 'urn:echo'
drv = SOAP::RPC::Driver.new('http://localhost:7171/', Namespace)
drv.add_document_method('echo', 'echo_soapaction',
  XSD::QName.new(Namespace, 'echoRequest'),
  XSD::QName.new(Namespace, 'echoResponse'))

drv.return_response_as_xml = true
drv.wiredump_dev = STDOUT

require 'rexml/document'
request = REXML::Document.new(<<__XML__)
<echoRequest xmlns="urn:echo">
  <foo bar="baz">
    <qux>quxx</qux>
  </foo>
</echoRequest>
__XML__

response = drv.echo(request)
p REXML::XPath.match(REXML::Document.new(response), "//*[name()='n1:foo']")
