=begin
SOAP4R - SOAP driver
Copyright (C) 2000, 2001 NAKAMURA Hiroshi.

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

require 'soap/proxy'
require 'soap/rpcUtils'
require 'application'


module SOAP


class Driver
  include Log::Severity
  include RPCUtils

  public

  def initialize( log, logId, namespace, endPoint, httpProxy = nil, soapAction = nil )
    @log = log
    @logId = logId
    log( SEV_INFO, 'initialize: initializing SOAP driver...' )
    @namespace = namespace
    @handler = HTTPPostStreamHandler.new( endPoint, httpProxy )
    @proxy = SOAPProxy.new( @namespace, @handler, soapAction )
    @proxy.allowUnqualifiedElement = true
  end

  def setWireDumpDev( dumpDev )
    @handler.dumpDev = dumpDev
  end

  def setWireDumpFileBase( base )
    @dumpFileBase = base
  end

  def addMethod( name, *paramNames )
    addMethodWithSOAPAction( name, nil, *paramNames )
  end

  def addMethodWithSOAPAction( name, soapAction, *paramNames )
    log( SEV_DEBUG, "addMethod: method '#{ name }', param '#{ paramNames.join( ',' ) }'." )
    paramDef = []
    paramNames.each do | paramName |
      paramDef.push( [ 'in', paramName ] )
    end
    paramDef.push( [ 'retval', 'return' ] )
    @proxy.addMethod( name, paramDef, soapAction )
  end

  def method_missing( msg_id, *params )
    log( SEV_INFO, "method_missing: invoked '#{ msg_id.id2name }'." )
    call( msg_id.id2name, *params )
  end

  private

  def log( sev, comment )
    @log.add( sev, "<#{ @logId }> #{ comment }", self.type ) if @log
  end

  def call( methodName, *params )
    log( SEV_INFO, "call: calling method '#{ methodName }'." )
    log( SEV_DEBUG, "call: parameters '#{ params.inspect }'." )

    # Convert parameters
    params.collect! { |param| obj2soap( param ) }
    log( SEV_DEBUG, "call: parameters '#{ params.inspect }'." )

    # Prepare SOAP header.
    headers = nil

    # Assign my namespace.
    NS.reset
    ns = NS.new
    ns.assign( @namespace )

    # Set dumpDev if needed.
    if @dumpFileBase
      @handler.dumpFileBase = @dumpFileBase + '_' << methodName
    end

    # Then, call @proxy.call like the following.
    header, body = @proxy.call( ns, headers, methodName, *params )

    # Check Fault.
    log( SEV_INFO, "call: checking SOAP-Fault..." )
    begin
      @proxy.checkFault( body )
    rescue SOAP::FaultError
      detail = soap2obj( $!.detail ) || ""
      $!.set_backtrace(
	if detail.is_a?( Array )
	  soap2obj( $!.detail ).map! { |s|
	    s.sub( /^/, @handler.endPoint + ':' )
	  }
	else
	  [ detail.to_s ]
	end
      )
      raise
    end

    obj = soap2obj( body.response )
    return obj
  end
end


end
