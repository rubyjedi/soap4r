#!/usr/bin/env ruby
require 'defaultDriver.rb'

endpoint_url = ARGV.shift
obj = EchoPortType.new(endpoint_url)

request = EchoRequest.new
request.attr_sampleAttr = 5
request.sampleElement = 3.14
p obj.echo(request)
