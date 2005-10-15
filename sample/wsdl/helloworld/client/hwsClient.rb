#!/usr/bin/env ruby
require 'defaultDriver.rb'

endpoint_url = ARGV.shift
obj = HwsPort.new(endpoint_url)

# Uncomment the below line to see SOAP wiredumps.
# obj.wiredump_dev = STDERR

# SYNOPSIS
#   hello_world(from)
#
# ARGS
#   from            String - {http://www.w3.org/2001/XMLSchema}string
#
# RETURNS
#   from            String - {http://www.w3.org/2001/XMLSchema}string
#
from = "hwsClient" 
puts obj.hello_world(from)


