=begin
SOAP4R - SOAP driver
Copyright (C) 2000, 2001, 2003 NAKAMURA Hiroshi.

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


require 'soap/rpc/driver'
require 'devel/logger'


module SOAP

  
class Driver < RPC::Driver
  include Devel::Logger::Severity

  attr_accessor :logdev
  alias logDev= logdev=
  alias logDev logdev
  alias setWireDumpDev wiredump_dev=
  alias setDefaultEncodingStyle default_encodingstyle=
  alias mappingRegistry= mapping_registry=
  alias mappingRegistry mapping_registry

  def initialize(log, logid, namespace, endpoint_url, httpproxy = nil, soapaction = nil)
    super(endpoint_url, namespace, soapaction)
    @logdev = log
    @logid = logid
    @logid_prefix = "<#{ @logid }> "
    self.httpproxy = httpproxy
    log(SEV_INFO) { 'initialize: initializing SOAP driver...' }
  end

  def invoke(headers, body)
    log(SEV_INFO) { "invoke: invoking message '#{ body.type }'." }
    super
  end

  def call(name, *params)
    log(SEV_INFO) { "call: calling method '#{ name }'." }
    log(SEV_DEBUG) { "call: parameters '#{ params.inspect }'." }
    log(SEV_DEBUG) {
      params = RPC.obj2soap(params, @mapping_registry).to_a
      "call: parameters '#{ params.inspect }'."
    }
    super
  end

  def addMethod(name, *params)
    addMethodWithSOAPActionAs(name, name, nil, *params)
  end

  def addMethodAs(name_as, name, *params)
    addMethodWithSOAPActionAs(name_as, name, nil, *params)
  end

  def addMethodWithSOAPAction(name, soapaction, *params)
    addMethodWithSOAPActionAs(name, name, soapaction, *params)
  end

  def addMethodWithSOAPActionAs(name_as, name, soapaction, *params)
    add_method_with_soapaction_as(name, name_as, soapaction, *params)
  end

private

  def log(sev)
    @logdev.add(sev, nil, self.class) { @logid_prefix + yield } if @logdev
  end
end


end
