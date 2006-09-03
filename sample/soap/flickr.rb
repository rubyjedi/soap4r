require 'soap/rpc/driver'

api_key = ARGV.shift or raise

flickr = SOAP::RPC::Driver.new('http://www.flickr.com/services/soap/')
flickr.wiredump_dev = STDOUT if $DEBUG

flickr.add_document_method('request', nil,
  XSD::QName.new('urn:flickr', 'FlickrRequest'),
  XSD::QName.new('urn:flickr', 'FlickrResponse'))

soap12namespace = 'http://www.w3.org/2003/05/soap-envelope'
flickr.options['soap.envelope.requestnamespace'] = soap12namespace
flickr.options['soap.envelope.responsenamespace'] = soap12namespace

response = flickr.request(
  :api_key => api_key,
  :method => 'flickr.test.echo',
  :name => 'hello world')

responsexml = "<dummy>#{response}</dummy>"

require 'xsd/mapping'
obj = XSD::Mapping.xml2obj(responsexml)
p obj.method
p obj.name
