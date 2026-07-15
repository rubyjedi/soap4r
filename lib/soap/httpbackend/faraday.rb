# encoding: UTF-8
# SOAP4R - HTTP client backend: the faraday gem.

require 'soap/httpbackend/registry'
require 'soap/faradayClient'

SOAP::HTTPBackend.register(SOAP::FaradayClient, true)
