# soaplet.rb -- SOAP handler servlet
# Copyright (C) 2001, 2002, 2003 NAKAMURA Hiroshi.

require 'webrick/httpservlet/abstract'
require 'webrick/httpstatus'
require 'soap/rpcRouter'
require 'soap/streamHandler'


module WEBrick


class SOAPlet < WEBrick::HTTPServlet::AbstractServlet
public

  attr_reader :appScopeRouter

  def initialize
    @routerMap = {}
    @appScopeRouter = SOAP::RPCRouter.new( self.class.name )
  end

  # Add servant klass whose object has request scope.  A servant object is
  # instanciated for each request.
  #
  # Bare in mind that servant klasses are distinguished by HTTP SOAPAction
  # header in request.  Client which calls request-scoped servant must have a
  # SOAPAction header which is a namespace of the servant klass.
  # I mean, use Driver#addMethodWithSOAPAction instead of Driver#addMethod at
  # client side.
  #
  def addRequestServant( namespace, klass, mappingRegistry = nil )
    router = RequestRouter.new( namespace, klass, mappingRegistry )
    addRouter( namespace, router )
  end

  # Add servant object which has application scope.
  def addServant( namespace, obj )
    router = @appScopeRouter
    SOAPlet.addServantToRouter( router, namespace, obj )
    addRouter( namespace, router )
  end


  ###
  ## Servlet interfaces for WEBrick.
  #
  def get_instance( config, *options )
    @config = config
    self
  end

  def require_path_info?
    false
  end

  def do_GET( req, res )
    res.header[ 'Allow' ] = 'POST'
    raise HTTPStatus::MethodNotAllowed, "GET request not allowed."
  end

  def do_POST( req, res )
    namespace = getNSFromSOAPAction( req.meta_vars[ 'HTTP_SOAPACTION' ] )
    router = lookupRouter( namespace )

    charset = nil
    isFault = false

    begin
      charset = ::SOAP::StreamHandler.parseMediaType( req[ 'content-type' ] )
      responseString, isFault = router.route( req.body, charset )
    rescue Exception => e
      responseString = router.createFaultResponseString( e )
      isFault = true
    end

    res.body = responseString
    res[ 'content-type' ] = "text/xml; charset=\"#{ charset }\""

    if isFault
      res.status = HTTPStatus::RC_INTERNAL_SERVER_ERROR
    end
  end

private

  class RequestRouter < SOAP::RPCRouter
    def initialize( namespace, klass, mappingRegistry = nil )
      super( namespace )
      if mappingRegistry
	self.mappingRegistry = mappingRegistry
      end
      @namespace = namespace
      @klass = klass
    end

    def route( soapString, charset )
      obj = @klass.new
      namespace = self.actor
      router = SOAP::RPCRouter.new( @namespace )
      SOAPlet.addServantToRouter( router, namespace, obj )
      router.route( soapString, charset )
    end
  end

  def addRouter( namespace, router )
    @routerMap[ namespace ] = router
  end

  def getNSFromSOAPAction( soapAction )
    if /^"(.*)"$/ =~ soapAction
      soapAction = $1
    end
    if soapAction.empty?
      return nil
    end
    soapAction
  end

  def lookupRouter( namespace )
    if namespace
      @routerMap[ namespace ] || @appScopeRouter
    else
      @appScopeRouter
    end
  end

  class << self
  public
    def addServantToRouter( router, namespace, obj )
      ( obj.methods - Kernel.instance_methods ).each do | methodName |
	addServantMethodToRouter( router, namespace, obj, methodName )
      end
    end

    def addServantMethodToRouter( router, namespace, obj, methodName )
      method = obj.method( methodName )
      paramDef = SOAP::RPCUtils::SOAPMethod.createParamDef(
	( 1..method.arity.abs ).collect { |i| "p#{ i }" } )
      router.addMethod( namespace, obj, methodName, paramDef )
    end
  end
end


end
