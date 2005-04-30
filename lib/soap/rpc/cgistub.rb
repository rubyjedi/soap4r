# SOAP4R - CGI stub library
# Copyright (C) 2001, 2003, 2004  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/streamHandler'
require 'webrick/httpresponse'
require 'webrick/httpstatus'
require 'logger'
require 'soap/rpc/soaplet'


module SOAP
module RPC


###
# SYNOPSIS
#   CGIStub.new
#
# DESCRIPTION
#   To be written...
#
class CGIStub < Logger::Application
  include SOAP
  include WEBrick

  class SOAPRequest
    attr_reader :body

    def initialize(stream)
      size = ENV['CONTENT_LENGTH'].to_i || 0
      @body = stream.read(size)
    end

    def [](var)
      ENV[var.gsub(/-/, '_').upcase]
    end

    def meta_vars
      {
        'HTTP_SOAPACTION' => ENV['HTTP_SOAPAction']
      }
    end
  end

  def initialize(appname, default_namespace)
    super(appname)
    set_log(STDERR)
    self.level = ERROR
    @default_namespace = default_namespace
    @remote_host = ENV['REMOTE_HOST'] || ENV['REMOTE_ADDR'] || 'unknown'
    @router = ::SOAP::RPC::Router.new(self.class.name)
    @soaplet = ::SOAP::RPC::SOAPlet.new(@router)
    on_init
  end
  
  def on_init
    # do extra initialization in a derived class if needed.
  end

  def mapping_registry
    @router.mapping_registry
  end

  def mapping_registry=(value)
    @router.mapping_registry = value
  end

  def generate_explicit_type
    @router.generate_explicit_type
  end

  def generate_explicit_type=(generate_explicit_type)
    @router.generate_explicit_type = generate_explicit_type
  end

  # servant entry interface

  def add_rpc_servant(obj, namespace = @default_namespace)
    @router.add_rpc_servant(obj, namespace)
  end
  alias add_servant add_rpc_servant

  def add_headerhandler(obj)
    @router.add_headerhandler(obj)
  end
  alias add_rpc_headerhandler add_headerhandler

  # method entry interface

  def add_rpc_method(obj, name, *param)
    add_rpc_method_with_namespace_as(@default_namespace, obj, name, name, *param)
  end
  alias add_method add_rpc_method

  def add_rpc_method_as(obj, name, name_as, *param)
    add_rpc_method_with_namespace_as(@default_namespace, obj, name, name_as, *param)
  end
  alias add_method_as add_rpc_method_as

  def add_rpc_method_with_namespace(namespace, obj, name, *param)
    add_rpc_method_with_namespace_as(namespace, obj, name, name, *param)
  end
  alias add_method_with_namespace add_rpc_method_with_namespace

  def add_rpc_method_with_namespace_as(namespace, obj, name, name_as, *param)
    qname = XSD::QName.new(namespace, name_as)
    soapaction = nil
    param_def = SOAPMethod.derive_rpc_param_def(obj, name, *param)
    @router.add_rpc_operation(obj, qname, soapaction, name, param_def)
  end
  alias add_method_with_namespace_as add_rpc_method_with_namespace_as

  def add_rpc_operation(receiver, qname, soapaction, name, param_def, opt = {})
    @router.add_rpc_operation(receiver, qname, soapaction, name, param_def, opt)
  end

  def add_document_operation(receiver, soapaction, name, param_def, opt = {})
    @router.add_document_operation(receiver, soapaction, name, param_def, opt)
  end

private

  def run
    prologue
    httpversion = WEBrick::HTTPVersion.new('1.0')
    res = WEBrick::HTTPResponse.new({:HTTPVersion => httpversion})
    conn_data = nil
    begin
      @log.info { "received a request from '#{ @remote_host }'" }
      req = SOAPRequest.new($stdin)
      @soaplet.do_POST(req, res)
      epilogue
    rescue HTTPStatus::EOFError, HTTPStatus::RequestTimeout => ex
      res.set_error(ex)
    rescue HTTPStatus::Error => ex
      res.set_error(ex)
    rescue HTTPStatus::Status => ex
      res.status = ex.code
    rescue StandardError, NameError => ex # for Ruby 1.6
      res.set_error(ex, true)
    ensure
      buf = ''
      res.send_response(buf)
      buf.sub!(/^[^\r]+\r\n/, '')       # Trim status line.
      @log.debug { "SOAP CGI Response:\n#{ buf }" }
      print buf
    end
    epilogue
    0
  end

  def prologue; end
  def epilogue; end
end


end
end
