# SOAP4R - RPC Routing library
# Copyright (C) 2001, 2002, 2004, 2005  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/soap'
require 'soap/processor'
require 'soap/mapping'
require 'soap/mapping/wsdlliteralregistry'
require 'soap/rpc/rpc'
require 'soap/rpc/element'
require 'soap/streamHandler'
require 'soap/mimemessage'
require 'soap/header/handlerset'


module SOAP
module RPC


class Router
  include SOAP

  attr_reader :actor
  attr_accessor :mapping_registry
  attr_accessor :literal_mapping_registry

  def initialize(actor)
    @actor = actor
    @mapping_registry = nil
    @headerhandler = Header::HandlerSet.new
    @literal_mapping_registry = ::SOAP::Mapping::WSDLLiteralRegistry.new
    @operation_by_soapaction = {}
    @operation_by_qname = {}
    @headerhandlerfactory = []
  end

  def add_request_headerhandler(factory)
    unless factory.respond_to?(:create)
      raise TypeError.new("factory must respond to 'create'")
    end
    @headerhandlerfactory << factory
  end

  def add_headerhandler(handler)
    @headerhandler.add(handler)
  end

  def add_rpc_operation(receiver, qname, soapaction, name, param_def, opt = {})
    opt[:request_style] ||= :rpc
    opt[:response_style] ||= :rpc
    opt[:request_use] ||= :encoded
    opt[:response_use] ||= :encoded
    opt[:request_qname] = qname
    op = ApplicationScopeOperation.new(soapaction, receiver, name, param_def,
      opt)
    if opt[:request_style] != :rpc
      raise RPCRoutingError.new("illegal request_style given")
    end
    assign_operation(soapaction, qname, op)
  end
  alias add_method add_rpc_operation
  alias add_rpc_method add_rpc_operation

  def add_rpc_request_operation(factory, qname, soapaction, name, param_def,
      opt = {})
    opt[:request_style] ||= :rpc
    opt[:response_style] ||= :rpc
    opt[:request_use] ||= :encoded
    opt[:response_use] ||= :encoded
    opt[:request_qname] = qname
    op = RequestScopeOperation.new(soapaction, factory, name, param_def, opt)
    if opt[:request_style] != :rpc
      raise RPCRoutingError.new("illegal request_style given")
    end
    assign_operation(soapaction, qname, op)
  end

  def add_document_operation(receiver, soapaction, name, param_def, opt = {})
    unless soapaction
      raise RPCRoutingError.new("soapaction is a must for document method")
    end
    opt[:request_style] ||= :document
    opt[:response_style] ||= :document
    opt[:request_use] ||= :encoded
    opt[:response_use] ||= :encoded
    op = ApplicationScopeOperation.new(soapaction, receiver, name, param_def,
      opt)
    if opt[:request_style] != :document
      raise RPCRoutingError.new("illegal request_style given")
    end
    assign_operation(soapaction, nil, op)
  end
  alias add_document_method add_document_operation

  def add_document_request_operation(factory, soapaction, name, param_def,
      opt = {})
    unless soapaction
      raise RPCRoutingError.new("soapaction is a must for document method")
    end
    opt[:request_style] ||= :document
    opt[:response_style] ||= :document
    opt[:request_use] ||= :encoded
    opt[:response_use] ||= :encoded
    op = RequestScopeOperation.new(soapaction, receiver, name, param_def, opt)
    if opt[:request_style] != :document
      raise RPCRoutingError.new("illegal request_style given")
    end
    assign_operation(soapaction, nil, op)
  end

  def route(conn_data)
    soap_response = default_encodingstyle = nil
    begin
      env = unmarshal(conn_data)
      if env.nil?
	raise ArgumentError.new("illegal SOAP marshal format")
      end
      op = lookup_operation(conn_data.soapaction, env.body)
      headerhandler = @headerhandler.dup
      @headerhandlerfactory.each do |f|
        headerhandler.add(f.create)
      end
      receive_headers(headerhandler, env.header)
      soap_response =
        op.call(env.body, @mapping_registry, @literal_mapping_registry)
      if op.response_use == :document
        default_encodingstyle =
          ::SOAP::EncodingStyle::ASPDotNetHandler::Namespace
      end
    rescue Exception
      soap_response = fault($!)
    end
    conn_data.is_fault = true if soap_response.is_a?(SOAPFault)
    header = call_headers(headerhandler)
    body = SOAPBody.new(soap_response)
    env = SOAPEnvelope.new(header, body)
    marshal(conn_data, env, default_encodingstyle)
  end

  # Create fault response string.
  def create_fault_response(e)
    header = SOAPHeader.new
    body = SOAPBody.new(fault(e))
    env = SOAPEnvelope.new(header, body)
    opt = {}
    opt[:external_content] = nil
    response_string = Processor.marshal(env, opt)
    conn_data = StreamHandler::ConnectionData.new(response_string)
    conn_data.is_fault = true
    if ext = opt[:external_content]
      mimeize(conn_data, ext)
    end
    conn_data
  end

private

  def assign_operation(soapaction, qname, op)
    assigned = false
    if soapaction and !soapaction.empty?
      @operation_by_soapaction[soapaction] = op
      assigned = true
    end
    if qname
      @operation_by_qname[qname] = op
      assigned = true
    end
    unless assigned
      raise RPCRoutingError.new("cannot assign operation")
    end
  end

  def lookup_operation(soapaction, body)
    if op = @operation_by_soapaction[soapaction]
      return op
    end
    qname = body.root_node.elename
    if op = @operation_by_qname[qname]
      return op
    end
    if soapaction
      raise RPCRoutingError.new("operation: #{soapaction} not supported")
    else
      raise RPCRoutingError.new("operation: #{qname} not supported")
    end
  end

  def call_headers(headerhandler)
    headers = headerhandler.on_outbound
    if headers.empty?
      nil
    else
      h = ::SOAP::SOAPHeader.new
      headers.each do |header|
        h.add(header.elename.name, header)
      end
      h
    end
  end

  def receive_headers(headerhandler, headers)
    headerhandler.on_inbound(headers) if headers
  end

  def unmarshal(conn_data)
    opt = {}
    contenttype = conn_data.receive_contenttype
    if /#{MIMEMessage::MultipartContentType}/i =~ contenttype
      opt[:external_content] = {}
      mime = MIMEMessage.parse("Content-Type: " + contenttype,
        conn_data.receive_string)
      mime.parts.each do |part|
	value = Attachment.new(part.content)
	value.contentid = part.contentid
	obj = SOAPAttachment.new(value)
	opt[:external_content][value.contentid] = obj if value.contentid
      end
      opt[:charset] =
	StreamHandler.parse_media_type(mime.root.headers['content-type'].str)
      env = Processor.unmarshal(mime.root.content, opt)
    else
      opt[:charset] = ::SOAP::StreamHandler.parse_media_type(contenttype)
      env = Processor.unmarshal(conn_data.receive_string, opt)
    end
    charset = opt[:charset]
    conn_data.send_contenttype = "text/xml; charset=\"#{charset}\""
    env
  end

  def marshal(conn_data, env, default_encodingstyle = nil)
    opt = {}
    opt[:external_content] = nil
    opt[:default_encodingstyle] = default_encodingstyle
    response_string = Processor.marshal(env, opt)
    conn_data.send_string = response_string
    if ext = opt[:external_content]
      mimeize(conn_data, ext)
    end
    conn_data
  end

  def mimeize(conn_data, ext)
    mime = MIMEMessage.new
    ext.each do |k, v|
      mime.add_attachment(v.data)
    end
    mime.add_part(conn_data.send_string + "\r\n")
    mime.close
    conn_data.send_string = mime.content_str
    conn_data.send_contenttype = mime.headers['content-type'].str
    conn_data
  end

  # Create fault response.
  def fault(e)
    detail = Mapping::SOAPException.new(e)
    SOAPFault.new(
      SOAPString.new('Server'),
      SOAPString.new(e.to_s),
      SOAPString.new(@actor),
      Mapping.obj2soap(detail, @mapping_registry))
  end

  class Operation
    attr_reader :name
    attr_reader :soapaction
    attr_reader :request_style
    attr_reader :response_style
    attr_reader :request_use
    attr_reader :response_use

    def initialize(soapaction, name, param_def, opt)
      @soapaction = soapaction
      @name = name
      @request_style = opt[:request_style]
      @response_style = opt[:response_style]
      @request_use = opt[:request_use]
      @response_use = opt[:response_use]
      case @response_style
      when :rpc
        request_qname = opt[:request_qname] or raise
        @rpc_method_factory =
          RPC::SOAPMethodRequest.new(request_qname, param_def, @soapaction)
        @rpc_response_qname = opt[:response_qname]
      when :document
        @doc_request_qnames = @doc_response_qnames = nil
        if param_def
          @doc_request_qnames = []
          @doc_response_qnames = []
          param_def.each do |inout, paramname, typeinfo|
            klass, nsdef, namedef = typeinfo
            case inout
            when 'in', 'input'
              @doc_request_qnames << XSD::QName.new(nsdef, namedef)
            when 'out', 'output'
              @doc_response_qnames << XSD::QName.new(nsdef, namedef)
            else
                raise ArgumentError.new("illegal inout definition: #{inout}")
            end
          end
        end
      else
        raise "unknown request style: #{style}"
      end
    end

    def call(body, mapping_registry, literal_mapping_registry)
      case @request_style
      when :rpc
        result = request_rpc(body, mapping_registry)
      when :document
        result = request_document(body, literal_mapping_registry)
      else
        raise "unknown request style: #{@request_type}"
      end
      return result if result.is_a?(SOAPFault)
      case @response_style
      when :rpc
        response_rpc(result, mapping_registry)
      when :document
        response_document(result, literal_mapping_registry)
      else
        raise "unknown response style: #{@response_style}"
      end
    end

  private

    def receiver
      raise NotImplementedError.new('must be defined in derived class')
    end

    def request_rpc(body, mapping_registry)
      request = body.request
      unless request.is_a?(SOAPStruct)
        raise RPCRoutingError.new("not an RPC style")
      end
      if @request_use == :encoded
        request_rpc_enc(request, mapping_registry)
      elsif @request_use == :literal
        request_rpc_lit(request)
      else
        raise
      end
    end

    def request_document(body, mapping_registry)
      # ToDo: compare names with @doc_request_qnames
      if @request_use == :encoded
        request_doc_enc(body, mapping_registry)
      elsif @request_use == :literal
        request_doc_lit(body)
      else
        raise
      end
    end

    def request_rpc_enc(request, mapping_registry)
      param = Mapping.soap2obj(request, mapping_registry)
      values = request.collect { |key, value| param[key] }
      receiver.method(@name.intern).call(*values)
    end

    def request_rpc_lit(request)
      values = request.collect { |key, value| value.to_obj }
      receiver.method(@name.intern).call(*values)
    end

    def request_doc_enc(body, literal_mapping_registry)
      param = []
      body.each do |key, value|
        param << Mapping.soap2obj(value, literal_mapping_registry)
      end
      receiver.method(@name.intern).call(*param)
    end

    def request_doc_lit(body)
      param = []
      body.each do |key, value|
        param << value.to_obj
      end
      receiver.method(@name.intern).call(*param)
    end

    def response_rpc(result, mapping_registry)
      if @response_use == :encoded
        response_rpc_enc(result, mapping_registry)
      elsif @response_use == :literal
        response_rpc_lit(result)
      else
        raise
      end
    end
    
    def response_document(result, mapping_registry)
      unless result.respond_to?(:size)
        result = [result]
      end
      if @doc_response_qnames and result.size != @doc_response_qnames.size
        raise "required #{@doc_response_qnames.size} responses " +
          "but #{result.size} given"
      end
      if @response_use == :encoded
        response_doc_enc(result, literal_mapping_registry)
      elsif @response_use == :literal
        response_doc_lit(result)
      else
        raise
      end
    end

    def response_rpc_enc(result, mapping_registry)
      soap_response =
        @rpc_method_factory.create_method_response(@rpc_response_qname)
      if soap_response.have_outparam?
        unless result.is_a?(Array)
          raise RPCRoutingError.new("out parameter was not returned")
        end
        outparams = {}
        i = 1
        soap_response.each_param_name('out', 'inout') do |outparam|
          outparams[outparam] = Mapping.obj2soap(result[i], mapping_registry)
          i += 1
        end
        soap_response.set_outparam(outparams)
        soap_response.retval = Mapping.obj2soap(result[0], mapping_registry)
      else
        soap_response.retval = Mapping.obj2soap(result, mapping_registry)
      end
      soap_response
    end

    def response_rpc_lit(result)
      raise NotImplementedError
    end

    def response_doc_enc(result, literal_mapping_registry)
      (0...result.size).collect { |idx|
        literal_mapping_registry.obj2soap(result[idx],
          @doc_response_qnames[idx])
      }
    end

    def response_doc_lit(result)
      (0...result.size).collect { |idx|
        item = result[idx]
        unless item.respond_to?(:size) and item.size == 1
          raise ArgumentError.new(
            "result element is expected to be Hash-like object with one key")
        end
        ele = SOAPElement.from_obj(item)
        ele.elename =
          @doc_response_qnames[idx] || XSD::QName.new(nil, item.keys[0])
        ele
      }
    end
  end

  class ApplicationScopeOperation < Operation
    def initialize(soapaction, receiver, name, param_def, opt)
      super(soapaction, name, param_def, opt)
      @receiver = receiver
    end

  private

    def receiver
      @receiver
    end
  end

  class RequestScopeOperation < Operation
    def initialize(soapaction, receiver_factory, name, param_def, opt)
      super(soapaction, name, param_def, opt)
      unless receiver_factory.respond_to?(:create)
        raise TypeError.new("factory must respond to 'create'")
      end
      @receiver_factory = receiver_factory
    end

  private

    def receiver
      @receiver_factory.create
    end
  end
end


end
end
