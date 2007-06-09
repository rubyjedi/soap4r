require 'AddService.rb'
require 'AddServiceImpl.rb'

port = ARGV.shift
if (port == nil) then
  puts "Usage: ${0} <port>"
  exit -1
end

server = AddPortTypeApp.new('app', nil, '0.0.0.0', port.to_i)
trap(:INT) do
  server.shutdown
end
puts "Starting fault service endpoint"
server.start
