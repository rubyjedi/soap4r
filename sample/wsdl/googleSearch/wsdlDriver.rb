#require 'uconv'
require 'soap/wsdlDriver'

word = ARGV.shift
# You must get key from http://www.google.com/apis/ to use Google Web APIs.
key = File.open(File.expand_path("~/.google_key")) { |f| f.read }.chomp

GOOGLE_WSDL = 'http://api.google.com/GoogleSearch.wsdl'
# GOOGLE_WSDL = 'GoogleSearch.wsdl'

def html2rd(str)
  str.gsub(%r(<b>(.*?)</b>), '((*\\1*))').strip
end


google = SOAP::WSDLDriverFactory.new(GOOGLE_WSDL).create_rpc_driver
google.options["soap.envelope.use_numeric_character_reference"] = true
google.wiredump_dev = STDOUT if $DEBUG
#google.generate_explicit_type = false

result = google.doGoogleSearch( key, word, 0, 10, false, "", false, "", 'utf-8', 'utf-8' )

exit

result.resultElements.each do |ele|
  puts "== #{html2rd(ele.title)}: #{ele["URL"]}"
  puts html2rd(ele.snippet)
  puts
end
