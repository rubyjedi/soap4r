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

  attr_accessor :logDev

  def initialize(log, logId, namespace, endpointUrl, httpProxy = nil, soapAction = nil)
    super(endpointUrl, namespace, soapAction)
    @logDev = log
    @logId = logId
    @logIdPrefix = "<#{ @logId }> "
    setHttpProxy(httpProxy)
    log(SEV_INFO) { 'initialize: initializing SOAP driver...' }
  end


  ###
  ## Driving interface.
  #
  def invoke(reqHeaders, reqBody)
    log(SEV_INFO) { "invoke: invoking message '#{ reqBody.type }'." }
    super
  end

  def call(methodName, *params)
    log(SEV_INFO) { "call: calling method '#{ methodName }'." }
    log(SEV_DEBUG) { "call: parameters '#{ params.inspect }'." }
    log(SEV_DEBUG) {
      params = RPC.obj2soap(params, @mappingRegistry).to_a
      "call: parameters '#{ params.inspect }'."
    }
    super
  end

private

  def log(sev)
    @logDev.add(sev, nil, self.class) { @logIdPrefix + yield } if @logDev
  end
end


end
