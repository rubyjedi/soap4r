# SOAP4R - WEBrick HTTP Server
# Copyright (C) 2003, 2004 by NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'logger'
require 'soap/rpc/soaplet'
require 'soap/streamHandler'
require 'webrick'


module SOAP
module RPC


class HTTPServer < Logger::Application
  attr_reader :server
  attr_accessor :default_namespace

  def initialize(config)
    super(config[:SOAPHTTPServerApplicationName] || self.class.name)
    @default_namespace = config[:SOAPDefaultNamespace]
    @webrick_config = config.dup
    self.level = Logger::Severity::ERROR # keep silent by default
    @webrick_config[:Logger] ||= @log
    @log = @webrick_config[:Logger]     # sync logger of App and HTTPServer
    @router = ::SOAP::RPC::Router.new(self.class.name)
    @soaplet = ::SOAP::RPC::SOAPlet.new(@router)
    on_init
    @server = WEBrick::HTTPServer.new(@webrick_config)
    @server.mount('/', @soaplet)
  end

  def on_init
    # do extra initialization in a derived class if needed.
  end

  def status
    @server.status if @server
  end

  def shutdown
    @server.shutdown if @server
  end

  def mapping_registry
    @router.mapping_registry
  end

  def mapping_registry=(mapping_registry)
    @router.mapping_registry = mapping_registry
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

  # method entry interface

  def add_rpc_method(obj, name, *param)
    add_rpc_method_as(obj, name, name, *param)
  end
  alias add_method add_rpc_method

  def add_rpc_method_as(obj, name, name_as, *param)
    qname = XSD::QName.new(@default_namespace, name_as)
    soapaction = nil
    param_def = create_rpc_param_def(obj, name, param)
    @router.add_rpc_operation(obj, qname, soapaction, name, param_def)
  end
  alias add_method_as add_rpc_method_as

  def add_document_method(obj, name, soapaction, req_qnames, res_qnames)
    param_def = create_doc_param_def(req_qnames, res_qnames)
    @router.add_document_operation(obj, soapaction, name, param_def, opt)
  end

private

  def create_rpc_param_def(obj, name, param = nil)
    if param.nil? or param.empty?
      method = obj.method(name)
      ::SOAP::RPC::SOAPMethod.create_param_def(
        (1..method.arity.abs).collect { |i| "p#{i}" })
    elsif param.size == 1 and param[0].is_a?(Array)
      param[0]
    else
      ::SOAP::RPC::SOAPMethod.create_param_def(param)
    end
  end
  alias create_param_def create_rpc_param_def

  def create_doc_param_def(req_qnames, res_qnames)
    req_qnames = [req_qnames] if req_qnames.is_a?(XSD::QName)
    res_qnames = [res_qnames] if res_qnames.is_a?(XSD::QName)
    param_def = []
    req_qnames.each do |qname|
      param_def << ['in', qname.name, [nil, qname.namespace, qname.name]]
    end
    res_qnames.each do |qname|
      param_def << ['out', qname.name, [nil, qname.namespace, qname.name]]
    end
    param_def
  end

  def run
    @server.start
  end
end


end
end
