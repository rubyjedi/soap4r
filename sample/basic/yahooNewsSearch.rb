query = ARGV.shift or raise ArgumentError

require 'soap/marshal'
class MyXMLHandler < SOAP::EncodingStyle::SOAPHandler
  Namespace = 'urn:myxmlhandler'
  add_handler
  def decode_parent(parent, node)
    super if parent.node
  end
end

require 'httpclient'
appid = 'soap4r-dev'
url = 'http://api.search.yahoo.com/NewsSearchService/V1/newsSearch'
type = 'all'    # any, phrase
results = 3
language = 'en'
results_sort = 'rank'     # date

param = {
  'appid' => appid,
  'query' => query,
  'results' => results,
  'language' => language,
  'results_sort' => results_sort
}
proxy = ENV['http_proxy'] || ENV['HTTP_PROXY']
result = HTTPClient.new(proxy).get_content(url, param)

opt = {:default_encodingstyle => 'urn:myxmlhandler'}
soap = SOAP::Processor.unmarshal(result, opt)

SOAP::Mapping.soap2obj(soap).result.each do |result|
  puts "== " + result.title + " =="
  puts result.summary
end
