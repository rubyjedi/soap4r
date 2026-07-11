# encoding: UTF-8
# SOAP4R - HTTP client backend: the curb gem (libcurl bindings).

require 'soap/httpbackend/registry'
require 'soap/curbClient'

SOAP::HTTPBackend.register(SOAP::CurbClient, true)
