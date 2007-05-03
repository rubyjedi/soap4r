#!/usr/bin/env ruby
require 'AddDriver.rb'

endpoint_url = ARGV.shift
value = ARGV.shift
if ((endpoint_url == nil) or (value == nil)) then
  puts "Usage: #{$0} <service-url> <value>"
  exit -1
end

obj = AddPortType.new(endpoint_url)
# run ruby with -d to see SOAP wiredumps.
obj.wiredump_dev = STDERR if $DEBUG


begin
  request = Add.new(value)
  response = obj.add(request)
  puts "Result: #{response.sum}"
rescue SOAP::FaultError => e
  if (e.faultstring.to_s == "AddFault")
    puts "Fault caught! Reason: '#{e.detail.addFault.reason}' Severity: '#{e.detail.addFault.severity}'"
  else
    puts "Fault caught! Reason: '#{e.detail.negativeValueFault.reason}' Severity: '#{e.detail.negativeValueFault.severity}'"
  end
end


