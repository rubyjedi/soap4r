# soaplet.rb -- SOAP handler servlet
# Copyright (C) 2001 NAKAMURA Hiroshi.

require 'webrick/httpservlet/abstract'
require 'webrick/httpstatus'
require 'soap/rpcRouter'

module SOAP


class WEBrickSOAPlet < WEBrick::HTTPServlet::AbstractServlet
  include WEBrick

  def get_instance( config, *options )
    @config = config
    @options = options[0]
    if @options && @options.has_key?( 'mappingRegistry' )
      @router.mappingRegistry = @options[ 'mappingRegistry' ]
    end
    self
  end

  def require_path_info?
    false
  end

  def initialize
    super( {} )
    @router = SOAP::RPCRouter.new( self.type.to_s )
  end

  def addServant( namespace, obj, mappingRegistry = nil )
   ( obj.methods - Kernel.instance_methods ).each do | methodName |
      method = obj.method( methodName )
      paramDef = RPCUtils::SOAPMethod.createParamDef(
	( 1..method.arity.abs ).collect { |i| "p#{ i }" } )
      @router.addMethod( namespace, obj, methodName, paramDef )
    end
  end

  def do_GET( req, res )
    res.header[ 'Allow' ] = 'POST'
    raise HTTPStatus::MethodNotAllowed, "GET request not allowed."
  end

  def do_POST( req, res )
    isFault = false

    begin
      responseString, isFault = @router.route( req.body )
    rescue Exception => e
      responseString = @router.createFaultResponseString( e )
      isFault = true
    end

    res.body = responseString
    res[ 'content-type' ] =
      "text/xml; charset=\"#{ SOAP::Charset.getXMLInstanceEncodingLabel }\""

    if isFault
      res.status = HTTPStatus::RC_INTERNAL_SERVER_ERROR
    end
  end
end


end
