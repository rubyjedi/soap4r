#!/usr/bin/env ruby

require 'soap/rpc/driver'

server = 'http://www.jin.gr.jp/~nahi/yarpc/soapServer.cgi'
NS = 'http://www.ruby-lang.org/xmlns/soap/interface/RWiki/0.0.1'

drv = SOAP::RPC::Driver.new(server, NS)
# drv.wiredump_dev = STDERR
drv.add_method('find', 'keyword')
drv.add_method('src', 'name')
drv.add_method('view', 'name', 'env')
drv.add_method('setSrcAndView', 'name', 'src', 'env')

from = "nahi"
to = "hina"

env = { 'base' => 'mailto:nahi@keynauts.com' }

drv.find(from).each do | name |
  p name
  src = drv.src(name)
  src.gsub!(/#{ from }/i, to)
#  drv.setSrcAndView(name, src, env)
end

drv.find(from).each do | name |
  puts drv.view(name, env)
end
