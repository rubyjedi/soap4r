# encoding: UTF-8
# SOAP4R - HTTP client backend: the httpclient gem.

require 'soap/httpbackend/registry'
require 'httpclient'

SOAP::HTTPBackend.register(HTTPClient, true)
