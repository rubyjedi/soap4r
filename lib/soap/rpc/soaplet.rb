# SOAP4R - SOAP handler servlet for WEBrick
# Copyright (C) 2001, 2002, 2003, 2004  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'webrick/httpservlet/abstract'
require 'webrick/httpstatus'
require 'soap/rpc/router'
require 'soap/streamHandler'
begin
  require 'stringio'
  require 'zlib'
rescue LoadError
  STDERR.puts "Loading stringio or zlib failed.  No gzipped response support." if $DEBUG
end


module SOAP
module RPC


class SOAPlet < WEBrick::HTTPServlet::AbstractServlet
public
  attr_reader :options

  def initialize
    @router = ::SOAP::RPC::Router.new(self.class.name)
    @options = {}
    @config = {}
  end

  # for backward compatibility
  def app_scope_router
    @router
  end

  def allow_content_encoding_gzip=(allow)
    @options[:allow_content_encoding_gzip] = allow
  end

  # Add servant factory whose object has request scope.  A servant object is
  # instanciated for each request.
  def add_rpc_request_servant(factory, namespace)
    unless factory.respond_to?(:create)
      raise TypeError.new("factory must respond to 'create'")
    end
    obj = factory.create
    ::SOAP::RPC.defined_methods(obj).each do |name|
      begin
        qname = XSD::QName.new(namespace, name)
        method = obj.method(name)
        param_def = ::SOAP::RPC::SOAPMethod.create_param_def(
          (1..method.arity.abs).collect { |i| "p#{ i }" })
        opt = {}
        opt[:request_style] = opt[:response_style] = :rpc
        opt[:request_use] = opt[:response_use] = :encoded
        @router.add_rpc_request_operation(factory, qname, nil, name, param_def,
          opt)
      rescue SOAP::RPC::MethodDefinitionError => e
        p e if $DEBUG
      end
    end
  end

  # Add servant object which has application scope.
  def add_rpc_servant(obj, namespace)
    ::SOAP::RPC.defined_methods(obj).each do |name|
      begin
        qname = XSD::QName.new(namespace, name)
        method = obj.method(name)
        param_def = ::SOAP::RPC::SOAPMethod.create_param_def(
          (1..method.arity.abs).collect { |i| "p#{ i }" })
        opt = {}
        opt[:request_style] = opt[:response_style] = :rpc
        opt[:request_use] = opt[:response_use] = :encoded
        @router.add_rpc_operation(obj, qname, nil, name, param_def, opt)
      rescue SOAP::RPC::MethodDefinitionError => e
        p e if $DEBUG
      end
    end
  end
  alias add_servant add_rpc_servant

  def add_rpc_request_headerhandler(factory)
    @router.add_request_headerhandler(factory)
  end

  def add_rpc_headerhandler(handler)
    @router.add_headerhandler(handler)
  end
  alias add_headerhandler add_rpc_headerhandler

  ###
  ## Servlet interfaces for WEBrick.
  #
  def get_instance(config, *options)
    @config = config
    self
  end

  def require_path_info?
    false
  end

  def do_GET(req, res)
    res.header['Allow'] = 'POST'
    raise WEBrick::HTTPStatus::MethodNotAllowed, "GET request not allowed."
  end

  def do_POST(req, res)
    logger.debug { "SOAP request: " + req.body } if logger
    begin
      conn_data = ::SOAP::StreamHandler::ConnectionData.new
      conn_data.receive_string = req.body
      conn_data.receive_contenttype = req['content-type']
      conn_data.soapaction = parse_soapaction(req.meta_vars['HTTP_SOAPACTION'])
      conn_data = @router.route(conn_data)
      res['content-type'] = conn_data.send_contenttype
      if conn_data.is_fault
        res.status = WEBrick::HTTPStatus::RC_INTERNAL_SERVER_ERROR
      end
      if outstring = encode_gzip(req, conn_data.send_string)
        res['content-encoding'] = 'gzip'
        res['content-length'] = outstring.size
        res.body = outstring
      else
        res.body = conn_data.send_string
      end
    rescue Exception => e
      conn_data = @router.create_fault_response(e)
      res.status = WEBrick::HTTPStatus::RC_INTERNAL_SERVER_ERROR
      res.body = conn_data.send_string
      res['content-type'] = conn_data.send_contenttype || "text/xml"
    end

    if res.body.is_a?(IO)
      res.chunked = true
      logger.debug { "SOAP response: (chunked response not logged)" } if logger
    else
      logger.debug { "SOAP response: " + res.body } if logger
    end
  end

private

  def logger
    @config[:Logger]
  end

  def parse_soapaction(soapaction)
    if !soapaction.nil? and !soapaction.empty?
      if /^"(.+)"$/ =~ soapaction
        return $1
      end
    end
    nil
  end

  def encode_gzip(req, outstring)
    unless encode_gzip?(req)
      return nil
    end
    begin
      ostream = StringIO.new
      gz = Zlib::GzipWriter.new(ostream)
      gz.write(outstring)
      ostream.string
    ensure
      gz.close
    end
  end

  def encode_gzip?(req)
    @options[:allow_content_encoding_gzip] and defined?(::Zlib) and
      req['accept-encoding'] and
      req['accept-encoding'].split(/,\s*/).include?('gzip')
  end
end


end
end
