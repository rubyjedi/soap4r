=begin
SOAP4R - WEBrick Server
Copyright (c) 2003 by NAKAMURA, Hiroshi

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

require 'devel/logger'
require 'soap/streamHandler'

# require 'webrick'
require 'webrick/compat.rb'
require 'webrick/version.rb'
require 'webrick/config.rb'
require 'webrick/log.rb'
require 'webrick/server.rb'
require 'webrick/utils.rb'
require 'webrick/accesslog'
# require 'webrick/htmlutils.rb'
require 'webrick/httputils.rb'
# require 'webrick/cookie.rb'
require 'webrick/httpversion.rb'
require 'webrick/httpstatus.rb'
require 'webrick/httprequest.rb'
require 'webrick/httpresponse.rb'
require 'webrick/httpserver.rb'
# require 'webrick/httpservlet.rb'
# require 'webrick/httpauth.rb'
#
require 'webrick/httpservlet/soaplet'


module SOAP


###
# SYNOPSIS
#   WEBrickServer.new(namespace, listening_i/f, listening_port)
#
# DESCRIPTION
#   To be written...
#
class WEBrickServer < Devel::Application
  attr_reader :server

  def initialize(appName, namespace, host = "0.0.0.0", port = 8080)
    super(appName)
    @namespace = namespace
    @server = WEBrick::HTTPServer.new(
      :BindAddress => host,
      :AccessLog => [],
      :Port => port
    )
    @soaplet = WEBrick::HTTPServlet::SOAPlet.new
    methodDef
    @server.mount('/', @soaplet)
  end
  
  def addRPCRequestServant(namespace, klass, mappingRegistry = nil)
    @soaplet.addRPCRequestServant(namespace, klass, mappingRegistry)
  end

  def addRPCServant(namespace, obj, singleton = true)
    @soaplet.addRPCServant(namespace, obj, singleton)
  end

  def mappingRegistry
    @soaplet.appScopeRouter.mappingRegistry
  end

  def mappingRegistry=(mappingRegistry)
    @soaplet.appScopeRouter.mappingRegistry = mappingRegistry
  end

  def addMethod(obj, methodName, *paramArg)
    qname = XSD::QName.new(@namespace, methodName)
    soapAction = nil
    method = obj.method(methodName)
    paramDef = ::SOAP::RPCUtils::SOAPMethod.createParamDef(
      (1..method.arity.abs).collect { |i| "p#{ i }" })
    @soaplet.appScopeRouter.addMethod(obj, qname, soapAction, methodName, paramDef)
  end

private

  def run
    @server.start.join
  end
end


end
