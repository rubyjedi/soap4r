# encoding: UTF-8
# SOAP4R - HTTP client backend: this project's own wrapper around stdlib
# Net::HTTP. Final fallback when no third-party HTTP client gem is
# available.

require 'soap/httpbackend/registry'
require 'soap/netHttpClient'

SOAP::HTTPBackend.register(SOAP::NetHttpClient, false)
