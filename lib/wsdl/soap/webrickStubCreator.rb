=begin
WSDL4R - Creating WEBrick + SOAPlet stub code from WSDL.
Copyright (C) 2002 NAKAMURA Hiroshi.

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PRATICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 675 Mass
Ave, Cambridge, MA 02139, USA.
=end


require 'wsdl/info'
require 'wsdl/soap/mappingRegistryCreator'
require 'wsdl/soap/methodDefCreator'
require 'wsdl/soap/methodDefCreatorSupport'


module WSDL
  module SOAP


class WEBrickStubCreator
  include MethodDefCreatorSupport

  attr_reader :definitions

  def initialize(definitions)
    @definitions = definitions
  end

  def dump(service_name)
    STDERR.puts "!!! IMPORTANT !!!"
    STDERR.puts "WEBrick stub ignores port location defined in WSDL.  Location is http://localhost:10080/soapsrv by default.  Generated client from WSDL must be configured to point this endpoint by hand."
    STDERR.puts "!!! IMPORTANT !!!"

    result = ""
    result << <<__EOD__
require 'webrick'

STDERR.puts "All WEBrick httpd functions are enabled such as ERuby and CGI."
STDERR.puts "Take care before running this server in public network."

require 'devel/logger'
logdev = Devel::Logger.new('httpd.log')
logdev.sev_threshold = Devel::Logger::SEV_INFO

wwwsvr = WEBrick::HTTPServer.new(
  :BindAddress    => "0.0.0.0",
  :Port           => 10080, 
  :Logger         => logdev
)

require 'webrick/httpservlet/soaplet'
soapsrv = WEBrick::HTTPServlet::SOAPlet.new

require 'soap/rpcUtils'
MappingRegistry = SOAP::RPCUtils::MappingRegistry.new
__EOD__

    @definitions.service(service_name).ports.each do |port|
      result << dump_porttype(port.porttype.name)
      result << "\n"
    end

    result << <<__EOD__
soapsrv.app_scope_router.mapping_registry = MappingRegistry
wwwsvr.mount('/soapsrv', soapsrv)

trap("INT"){ wwwsvr.shutdown }
wwwsvr.start
__EOD__
    result
  end

private

  def dump_porttype(porttype)
    name = create_class_name(porttype)
    methoddef, types = MethodDefCreator.new(@definitions).dump(porttype)
    mr_creator = MappingRegistryCreator.new(@definitions)

    return <<__EOD__
#{ mr_creator.dump(types).gsub(/^/, "  ").chomp }

class #{ name }
  Methods = [
#{ methoddef.gsub(/^/, "    ").chomp }
  ]
end

servant = #{ name }.new
#{ name }::Methods.each do |name_as, name, params, soapaction, ns|
  soapsrv.app_scope_router.add_method(servant, XSD::QName.new(ns, name), soapaction, name_as, params)
end
__EOD__
  end
end


  end
end
