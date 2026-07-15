# encoding: UTF-8
# SOAP4R - WEBrick HTTP Server
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'logger'
require 'logger-application' unless defined?(Logger::Application)
require 'soap/attrproxy'
require 'soap/rpc/soaplet'
require 'soap/streamHandler'
require 'webrick'


module SOAP
module RPC


class HTTPServer < Logger::Application
  include AttrProxy

  attr_reader :server
  attr_accessor :default_namespace

  attr_proxy :mapping_registry, true
  attr_proxy :literal_mapping_registry, true
  attr_proxy :generate_explicit_type, true
  attr_proxy :use_default_namespace, true
  attr_proxy :soap_version, true

  def initialize(config)
    actor = config[:SOAPHTTPServerApplicationName] || self.class.name
    super(actor)
    @default_namespace = config[:SOAPDefaultNamespace]
    @webrick_config = config.dup
    self.level = Logger::Severity::ERROR # keep silent by default
    @webrick_config[:Logger] ||= @log
    @log = @webrick_config[:Logger]     # sync logger of App and HTTPServer
    @router = ::SOAP::RPC::Router.new(actor)
    @soaplet = ::SOAP::RPC::SOAPlet.new(@router)
    on_init

    @server = new_webrick_server(@webrick_config)
    @server.mount('/soaprouter', @soaplet)
    if wsdldir = config[:WSDLDocumentDirectory]
      @server.mount('/wsdl', WEBrick::HTTPServlet::FileHandler, wsdldir)
    end
    @server.mount('/', @soaplet)
  end

  def on_init
    # do extra initialization in a derived class if needed.
  end

  def status
    @server.status if @server
  end

  def shutdown
    if @server
      @server.shutdown
      while (@server.listeners.length > 0) && (@server.tokens.length > 0) && (@server.status != :Stop) 
        sleep(0.25)
      end
      sleep(0.25) # One more for good measure.
    end
  end

  def authenticator
    @soaplet.authenticator
  end

  def authenticator=(authenticator)
    @soaplet.authenticator = authenticator
  end

  # servant entry interface

  def add_rpc_request_servant(factory, namespace = @default_namespace)
    @router.add_rpc_request_servant(factory, namespace)
  end

  def add_rpc_servant(obj, namespace = @default_namespace)
    @router.add_rpc_servant(obj, namespace)
  end
  
  def add_request_headerhandler(factory)
    @router.add_request_headerhandler(factory)
  end

  def add_headerhandler(obj)
    @router.add_headerhandler(obj)
  end
  alias add_rpc_headerhandler add_headerhandler

  def filterchain
    @router.filterchain
  end

  # method entry interface

  def add_rpc_method(obj, name, *param)
    add_rpc_method_as(obj, name, name, *param)
  end
  alias add_method add_rpc_method

  def add_rpc_method_as(obj, name, name_as, *param)
    qname = XSD::QName.new(@default_namespace, name_as)
    soapaction = nil
    param_def = SOAPMethod.derive_rpc_param_def(obj, name, *param)
    @router.add_rpc_operation(obj, qname, soapaction, name, param_def)
  end
  alias add_method_as add_rpc_method_as

  def add_document_method(obj, soapaction, name, req_qnames, res_qnames)
    param_def = SOAPMethod.create_doc_param_def(req_qnames, res_qnames)
    @router.add_document_operation(obj, soapaction, name, param_def)
  end

  def add_rpc_operation(receiver, qname, soapaction, name, param_def, opt = {})
    @router.add_rpc_operation(receiver, qname, soapaction, name, param_def, opt)
  end

  def add_rpc_request_operation(factory, qname, soapaction, name, param_def, opt = {})
    @router.add_rpc_request_operation(factory, qname, soapaction, name, param_def, opt)
  end

  def add_document_operation(receiver, soapaction, name, param_def, opt = {})
    @router.add_document_operation(receiver, soapaction, name, param_def, opt)
  end

  def add_document_request_operation(factory, soapaction, name, param_def, opt = {})
    @router.add_document_request_operation(factory, soapaction, name, param_def, opt)
  end

private

  # A short retry-on-EADDRINUSE, matching test/testutil.rb's existing
  # TestUtil.webrick_server helper, applied here so it covers every caller
  # (not just tests that happen to go through that helper). Note: the mass
  # EADDRINUSE cascade seen across the test suite (most test files share a
  # single fixed port) turned out to be caused by a genuinely orphaned
  # server -- test/soap/header/test_authheader_cgi.rb's teardown could
  # raise before reaching teardown_server, permanently leaking that test's
  # listener for the rest of the run -- not by transient TIME_WAIT. This
  # retry is still worth keeping as a real defensive measure, just don't
  # rely on it alone to mask a genuine leak elsewhere.
  def new_webrick_server(config)
    try = 0
    begin
      WEBrick::HTTPServer.new(config)
    rescue Errno::EADDRINUSE => e
      sleep 1
      # See test/testutil.rb's webrick_server for the full history and why
      # this was pulled back down from 120 to 20 -- the real leak (Thread#kill
      # racing WEBrick's own async shutdown cleanup in test teardown) is
      # fixed now, so this only needs to cover transient scheduling delay,
      # not a real leak. A large budget here actively hurts: sslsvr.rb (test
      # SSL support script) calls into this same path, and its parent process
      # blocks on a timeout-less read waiting for it to report a PID --
      # confirmed a stuck retry here manifests as a multi-minute *silent
      # hang* in CI (run 28892185757), not just a slow test.
      ((try += 1) < 20) ? retry : raise(e)
    end
  end

  def attrproxy
    @router
  end

  def run
    @server.start
  end
end


end
end
