#!/usr/bin/env ruby
require 'defaultDriver.rb'

endpoint_url = ARGV.shift
obj = EchoPortType.new(endpoint_url)
obj.wiredump_dev = STDOUT if $DEBUG

request = EchoRequest.new
request.xmlattr_sampleAttr = 5
request.sampleElement = 3.14
p obj.echo(request)
