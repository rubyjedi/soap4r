#!/usr/bin/env ruby
require 'stockQuoteServicePortTypeDriver.rb'
require 'net/http'
require 'uri'
require 'yaml'

endpoint_url = ARGV.shift || 'http://localhost/cgi-bin/stockQuoteService.cgi'

Net::HTTP.get_print URI.parse("#{endpoint_url}?wsdl")

obj = StockQuoteServicePortType.new(endpoint_url)

# run ruby with -d to see SOAP wiredumps.
obj.wiredump_dev = STDERR if $DEBUG

# SYNOPSIS
#   getQuote(arg0)
#
# ARGS
#   arg0            String - {http://www.w3.org/2001/XMLSchema}string
#
# RETURNS
#   getQuoteResult  Float - {http://www.w3.org/2001/XMLSchema}float
#
arg0 = 'LEH'
puts obj.getQuote(arg0)
