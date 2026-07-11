# encoding: UTF-8
# SOAP4R - HTTP client backend loader.

require 'soap/httpbackend/registry'

# Provide a means to CHOOSE a preferred HTTP client backend and
# loading-order, if multiple backend gems are available -- mirrors
# xsd/xmlparser.rb's SOAP4R_PARSERS mechanism (same problem: several
# interchangeable backends, hardcoded fallback order, and no way to force a
# specific one without editing library code). This is what lets CI (and
# anyone debugging a backend-specific issue) actually exercise
# SOAP::NetHttpClient end-to-end instead of it only ever being reachable
# when every other backend happens to fail to load.
if ENV.has_key?('SOAP4R_HTTP_CLIENTS')
  backend_list = ENV['SOAP4R_HTTP_CLIENTS'].to_s.split(',')
else
  backend_list = [
    'httpclient',     ## Uses the httpclient gem
    'http_access2',   ## Uses the http-access2 gem ; no longer published on RubyGems.org
    'net_http',       ## Falls back to this project's own wrapper around stdlib Net::HTTP
  ]
end

loaded = false
backend_list.each do |name|
  begin
    require "soap/httpbackend/#{name}"
    loaded = true
    break
  rescue LoadError
  end
end
unless loaded
  raise RuntimeError.new("HTTP client backend not found.")
end
