require 'soap/proxy'
require 'soap/rpcUtils'
require 'xmltree'
require 'application'


class SampleDriver
  include XML::SimpleTree
  include Log::Severity
  include SOAPRPCUtils

  public

  def initialize( log, logId, namespace, endPoint, httpProxy = nil )
    @log = log
    @logId = logId
    log( SEV_INFO, 'initialize: initializing SampleDriver...' )
    @namespace = namespace
    @handler = SOAPHTTPPostStreamHandler.new( endPoint, httpProxy )
    @proxy = SOAPProxy.new( @namespace, @handler )
  end

  def addMethod( name, *paramNames )
    log( SEV_DEBUG, "addMethod: method '#{ name }', param '#{ paramNames.join( ',' ) }'." )
    paramDef = []
    paramNames.each do | paramName |
      paramDef.push( [ 'in', paramName ] )
    end
    paramDef.push( [ 'retval', 'return' ] )
    @proxy.addMethod( name, paramDef )
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
    SOAPNS.reset
    ns = SOAPNS.new()
    ns.assign( @namespace )

    # Then, call @proxy.call like the following.
    ns, header, body = @proxy.call( ns, headers, methodName, *params )

    # Check Fault.
    log( SEV_INFO, "call: checking SOAP-Fault..." )
    begin
      @proxy.checkFault( ns, body )
    rescue SOAP::FaultError
      $!.set_backtrace(
	soap2obj( $!.detail ).map! { |s|
	  s.sub( /^/, @handler.endPoint + ':' )
	}
      )
      raise
    end

    obj = soap2obj( body.data.data[ "return" ] )
    return obj
  end
end
