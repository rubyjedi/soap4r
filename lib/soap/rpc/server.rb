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
#   Server.new(app_name, default_namespace)
#
# DESCRIPTION
#   To be written...
#
class Server < Devel::Application
  def initialize(app_name, default_namespace = nil)
    super(app_name)
    self.sev_threshold = SEV_INFO
    @default_namespace = default_namespace
    @router = SOAP::RPC::Router.new(app_name)
    on_init
  end
 
  def mapping_registry
    @router.mapping_registry
  end

  def mapping_registry=(value)
    @router.mapping_registry = value
  end

  def add_servant(obj, namespace = @default_namespace, soapaction = nil)
    RPC.defined_methods(obj).each do |name|
      qname = XSD::QName.new(namespace, name)
      param_size = obj.method(name).arity.abs
      params = (1..param_size).collect { |i| "p#{ i }" }
      param_def = SOAP::RPC::SOAPMethod.create_param_def(params)
      @router.add_method(obj, qname, soapaction, name, param_def)
    end
  end

  def on_init
    # Override this method in derived class to call 'add_method*' to add methods.
  end

  def add_method(receiver, name, *param)
    add_method_with_namespace_as(@default_namespace, receiver,
      name, name, *param)
  end

  def add_method_as(receiver, name, name_as, *param)
    add_method_with_namespace_as(@default_namespace, receiver,
      name, name_as, *param)
  end

  def add_method_with_namespace(namespace, receiver, name, *param)
    add_method_with_namespace_as(namespace, receiver, name, name, *param)
  end

  def add_method_with_namespace_as(namespace, receiver, name, name_as, *param)
    param_def = if param.size == 1 and param[0].is_a?(Array)
        param[0]
      else
        SOAP::RPC::SOAPMethod.create_param_def(param)
      end
    qname = XSD::QName.new(namespace, name_as)
    @router.add_method(receiver, qname, nil, name, param_def)
  end

  def route(request_string, charset)
    @router.route(request_string, charset)
  end

  def create_fault_response(e)
    @router.create_fault_response(e)
  end
end


end
end
