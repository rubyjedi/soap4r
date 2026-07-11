# encoding: UTF-8
# SOAP4R - HTTP client backend: the http-access2 gem (httpclient's
# predecessor, by the same author; no longer published on RubyGems.org, so
# this adapter is effectively unreachable in practice today, but kept for
# anyone still vendoring the gem directly).

require 'soap/httpbackend/registry'
require 'http-access2'

if HTTPAccess2::VERSION < "2.0"
  raise LoadError.new("http-access2/2.0 or later is required.")
end

SOAP::HTTPBackend.register(HTTPAccess2::Client, true)
