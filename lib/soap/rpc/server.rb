=begin
SOAP4R - RPC Server implementation
Copyright (c) 2001, 2003 NAKAMURA, Hiroshi

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


require 'soap/rpc/router'
require 'devel/logger'


module SOAP
module RPC


###
# SYNOPSIS
#   Server.new(appName, defaultNamespace)
#
# DESCRIPTION
#   To be written...
#
class Server < Devel::Application
  def initialize(appName, defaultNamespace = nil)
    super(appName)
    setSevThreshold(SEV_INFO)
    @defaultNamespace = defaultNamespace
    @router = SOAP::RPC::Router.new(appName)
    methodDef
  end
 
  def mappingRegistry
    @router.mappingRegistry
  end

  def mappingRegistry=(value)
    @router.mappingRegistry = value
  end

  def addServant(obj, namespace = @defaultNamespace, soapAction = nil)
   (obj.methods - Kernel.instance_methods(true)).each do |methodName|
      qname = XSD::QName.new(namespace, methodName)
      paramSize = obj.method(methodName).arity.abs
      params = (1..paramSize).collect { |i| "p#{ i }" }
      paramDef = SOAP::RPC::SOAPMethod.createParamDef(params)
      @router.addMethod(obj, qname, soapAction, methodName, paramDef)
    end
  end

  def methodDef
    # Override this method in derived class to call 'addMethod*' to add methods.
  end

  def addMethod(receiver, methodName, *paramArg)
    addMethodWithNSAs(@defaultNamespace, receiver, methodName, methodName, *paramArg)
  end

  def addMethodAs(receiver, methodName, methodNameAs, *paramArg)
    addMethodWithNSAs(@defaultNamespace, receiver, methodName, methodNameAs, *paramArg)
  end

  def addMethodWithNS(namespace, receiver, methodName, *paramArg)
    addMethodWithNSAs(namespace, receiver, methodName, methodName, *paramArg)
  end

  def addMethodWithNSAs(namespace, receiver, methodName, methodNameAs,
      *paramArg)
    paramDef = if paramArg.size == 1 and paramArg[0].is_a?(Array)
        paramArg[0]
      else
        SOAP::RPC::SOAPMethod.createParamDef(paramArg)
      end
    qname = XSD::QName.new(namespace, methodNameAs)
    @router.addMethod(receiver, qname, nil, methodName, paramDef)
  end

  def route(requestString, charset)
    @router.route(requestString, charset)
  end

  def createFaultResponseString(e)
    @router.createFaultResponseString(e)
  end
end


end
end
