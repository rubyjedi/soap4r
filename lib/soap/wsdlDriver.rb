=begin
SOAP4R - SOAP WSDL driver
Copyright (C) 2002, 2003  NAKAMURA, Hiroshi.

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


require 'wsdl/parser'
require 'wsdl/importer'
require 'xsd/qname'
require 'soap/element'
require 'soap/baseData'
require 'soap/streamHandler'
require 'soap/mapping'
require 'soap/rpc/rpc'
require 'soap/rpc/element'
require 'soap/processor'
require 'devel/logger'


module SOAP


class WSDLDriverFactory
  attr_reader :wsdl

  def initialize(wsdl, logdev = nil)
    @logdev = logdev
    @wsdl = import(wsdl)
  end

  def create_driver(servicename = nil, portname = nil, opt = {})
    service = if servicename
	@wsdl.service(XSD::QName.new(@wsdl.targetnamespace, servicename))
      else
	@wsdl.services[0]
      end
    if service.nil?
      raise RuntimeError.new("Service #{ servicename } not found in WSDL.")
    end
    port = if portname
	service.ports[XSD::QName.new(@wsdl.targetnamespace, portname)]
      else
	service.ports[0]
      end
    if port.nil?
      raise RuntimeError.new("Port #{ portname } not found in WSDL.")
    end
    drv = WSDLDriver.new(@wsdl, port, @logdev, opt)
    complextypes = @wsdl.soap_complextypes(port.porttype)
    drv.wsdl_mapping_registry = Mapping::WSDLMappingRegistry.new(complextypes)
    drv
  end

  # Backward compatibility.
  alias createDriver create_driver

private
  
  def import(location)
    WSDL::Importer.import(location)
  end
end


class WSDLDriver
  include Devel::Logger::Severity
  include SOAP

public
  attr_accessor :logdev
  attr_accessor :mapping_registry
  attr_accessor :wsdl_mapping_registry
  attr_reader :opt
  attr_reader :endpoint_url
  attr_reader :wiredump_dev
  attr_reader :wiredump_file_base
  attr_reader :httpproxy

  attr_accessor :default_encodingstyle
  attr_accessor :allow_unqualified_element
  attr_accessor :generate_explicit_type

  def initialize(wsdl, port, logdev, opt)
    @wsdl = wsdl
    @port = port
    @logdev = logdev
    @mapping_registry = nil	# for unmarshal
    @wsdl_mapping_registry = nil	# for marshal
    @endpoint_url = nil
    @wiredump_dev = nil
    @wiredump_file_base = nil
    @httpproxy = ENV['http_proxy'] || ENV['HTTP_PROXY']

    @opt = opt.dup
    @decode_typemap = @wsdl.soap_complextypes(port.porttype)
    @default_encodingstyle = EncodingNamespace
    @allow_unqualified_element = true
    @generate_explicit_type = false

    create_handler
    @operations = {}
    # Convert a map which key is QName, to a Hash which key is String.
    @port.inputoperation_map.each do |op_name, op_info|
      @operations[op_name.name] = op_info
      add_method_interface(op_info.op_name.name, op_info.param_names)
    end
  end

  def endpoint_url=(endpoint_url)
    @endpoint_url = endpoint_url
    if @handler
      @handler.endpoint_url = @endpoint_url
      @handler.reset
    end
  end

  def wiredump_dev=(dev)
    @wiredump_dev = dev
    if @handler
      @handler.wiredump_dev = @wiredump_dev
      @handler.reset
    end
  end

  def wiredump_file_base=(base)
    @wiredump_file_base = base
  end

  def httpproxy=(httpproxy)
    @httpproxy = httpproxy
    if @handler
      @handler.proxy = @httpproxy
      @handler.reset
    end
  end

  def reset_stream
    @handler.reset
  end

  # Backward compatibility.
  alias generateEncodeType= generate_explicit_type=

private

  def create_handler
    unless @port.soap_address
      raise RuntimeError.new("soap:address element not found in WSDL.")
    end
    endpoint_url = @endpoint_url || @port.soap_address.location
    @handler = HTTPPostStreamHandler.new(endpoint_url, @httpproxy,
      Charset.encoding_label)
    @handler.wiredump_dev = @wiredump_dev
  end

  def create_method_obj(names, params)
    o = Object.new
    for idx in 0 ... params.length
      o.instance_eval("@#{ names[idx] } = params[idx]")
    end
    o
  end

  def call(method_name, *params)
    log(SEV_INFO) { "call: calling method '#{ method_name }'." }
    log(SEV_DEBUG) { "call: parameters '#{ params.inspect }'." }

    op_info = @operations[method_name]
    obj = create_method_obj(op_info.param_names, params)
    method = Mapping.obj2soap(obj, @wsdl_mapping_registry, op_info.msg_name)
    method.elename = op_info.op_name
    method.type = XSD::QName.new	# Request should not be typed.

    if @wiredump_file_base
      @handler.wiredump_file_base = @wiredump_file_base + '_' << method_name
    end

    begin
      header, body = invoke(nil, method, op_info.soapaction)
      unless body
	raise EmptyResponseError.new("Empty response.")
      end
    rescue SOAP::FaultError => e
      Mapping.fault2exception(e)
    end

    ret = body.response ?
      Mapping.soap2obj(body.response, @mapping_registry) : nil

    if body.outparams
      outparams = body.outparams.collect { |outparam|
	Mapping.soap2obj(outparam)
      }
      return [ret].concat(outparams)
    else
      return ret
    end
  end

  def invoke(headers, body, soapaction)
    send_string = marshal(headers, body)
    data = @handler.send(send_string, soapaction)
    return nil, nil if data.receive_string.empty?

    # Received charset might be different from request.
    res_charset = StreamHandler.parse_media_type(data.receive_contenttype)
    opt = options
    opt[:charset] = res_charset

    header, body = Processor.unmarshal(data.receive_string, opt)
    if body.fault
      raise SOAP::FaultError.new(body.fault)
    end

    return header, body
  end

  def marshal(headers, body)
    header = SOAPHeader.new()
    if headers
      headers.each do |content, must_understand, encodingstyle|
        header.add(SOAPHeaderItem.new(content, must_understand, encodingstyle))
      end
    end
    body = SOAPBody.new(body)
    Processor.marshal(header, body, options)
  end

  def add_method_interface(name, param_names)
    i = 0
    param_names = param_names.collect { |param_name|
      i += 1
      "arg#{ i }"
    }
    callparam_str = if param_names.empty?
	""
      else
	", " << param_names.join(", ")
      end
    self.instance_eval <<-EOS
      def #{ name }(#{ param_names.join(", ") })
	call("#{ name }"#{ callparam_str })
      end
    EOS
=begin
    To use default argument value.

    self.instance_eval <<-EOS
      def #{ name }(*arg)
	call("#{ name }", *arg)
      end
    EOS
=end
  end

  def options
    opt = @opt.dup
    opt[:decode_typemap] = @decode_typemap
    opt[:default_encodingstyle] = @default_encodingstyle
    opt[:allow_unqualified_element] = @allow_unqualified_element
    opt[:generate_explicit_type] = @generate_explicit_type
    opt
  end

  def log(sev)
    @logdev.add(sev, nil, self.type) { yield } if @logdev
  end
end


end


