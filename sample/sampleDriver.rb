require 'SOAPProxy'
require 'xmltree'
require 'application'


class SampleDriver
  include XML::SimpleTree
  include Log::Severity

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
    params = params.filter { |param| paramConv( param ) }
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
      p $!
    end

    return body.data.retVal
  end


  ###
  ## Convert parameter
  #
  def paramConv( obj )
    case obj
    when SOAPBasetypeUtils
      obj
    when TrueClass, FalseClass
      SOAPBoolean.new( obj )
    when String
      SOAPString.new( obj )
    when Time
      SOAPTimeInstant.new( obj )
    when Fixnum
      SOAPInt.new( obj )
    when Integer
      SOAPInteger.new( obj )
    when Array
      param = SOAPArray.new()
      param.namespace = obj.type.instance_eval( "@namespace" )
      obj.each do | var |
	param.add( paramConv( var ))
      end
      param
    else
      typeName = obj.type.instance_eval( "@typeName" ) || obj.type.to_s
      param = SOAPStruct.new( typeName  )
      param.namespace = obj.type.instance_eval( "@namespace" )
      obj.instance_variables.each do | var |
	name = var.dup.sub!( /^@/, '' )
	param.add( name, paramConv( obj.instance_eval( var )))
      end
      param
    end
  end
end
