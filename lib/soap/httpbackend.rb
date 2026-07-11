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
# http-access2 (httpclient's own predecessor, by the same author) used to
# sit in this cascade too. Removed: the gem was renamed to httpclient years
# ago and is no longer published on RubyGems.org at all, so that entry
# could never actually load -- confirmed empirically (`gem install
# http-access2` fails outright). Anyone still vendoring the old gem
# directly (e.g. via a git ref) can select it by placing a matching
# lib/soap/httpbackend/http_access2.rb adapter back on their own
# $LOAD_PATH; see git history for the version that shipped here.
if ENV.has_key?('SOAP4R_HTTP_CLIENTS')
  backend_list = ENV['SOAP4R_HTTP_CLIENTS'].to_s.split(',')
else
  backend_list = [
    'httpclient',     ## Uses the httpclient gem
    'curb',           ## Uses the curb gem (libcurl bindings) ; not installed by default, opt-in
    'faraday',        ## Uses the faraday gem (itself pluggable -- see soap/faradayClient.rb) ; not installed by default, opt-in
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
