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
require 'soap/mapping/wsdlRegistry'
require 'soap/rpc/rpc'
require 'soap/rpc/element'
require 'soap/processor'
require 'devel/logger'


module SOAP


class WSDLDriverFactory
  class FactoryError < StandardError; end

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
      raise FactoryError.new("Service #{ servicename } not found in WSDL.")
    end
    port = if portname
	service.ports[XSD::QName.new(@wsdl.targetnamespace, portname)]
      else
	service.ports[0]
      end
    if port.nil?
      raise FactoryError.new("Port #{ portname } not found in WSDL.")
    end
    if port.soap_address.nil?
      raise FactoryError.new("soap:address element not found in WSDL.")
    end
    drv = WSDLDriver.new(@wsdl, port, @logdev, opt)
    complextypes = @wsdl.soap_complextypes(port.porttype)
    drv.wsdl_mapping_registry = Mapping::WSDLRegistry.new(complextypes)
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
  class << self
    def __attr_proxy(symbol, assignable = false)
      name = symbol.to_s
      module_eval <<-EOD
       	def #{name}
	  @servant.#{name}
	end
      EOD
      if assignable
   	module_eval <<-EOD
	  def #{name}=(rhs)
	    @servant.#{name} = rhs
	  end
	EOD
      end
    end
  end

  __attr_proxy :opt
  __attr_proxy :logdev, true
  __attr_proxy :mapping_registry, true
  __attr_proxy :wsdl_mapping_registry, true
  __attr_proxy :endpoint_url, true
  __attr_proxy :wiredump_dev, true
  __attr_proxy :wiredump_file_base, true
  __attr_proxy :httpproxy, true

  __attr_proxy :default_encodingstyle, true
  __attr_proxy :allow_unqualified_element, true
  __attr_proxy :generate_explicit_type, true

  def reset_streadm
    @servant.reset_stream
  end

  # Backward compatibility.
  alias generateEncodeType= generate_explicit_type=

  class Servant
    include Devel::Logger::Severity
    include SOAP

    attr_reader :opt
    attr_accessor :logdev
    attr_accessor :mapping_registry
    attr_accessor :wsdl_mapping_registry
    attr_reader :endpoint_url
    attr_reader :wiredump_dev
    attr_reader :wiredump_file_base
    attr_reader :httpproxy

    attr_accessor :default_encodingstyle
    attr_accessor :allow_unqualified_element
    attr_accessor :generate_explicit_type

    def initialize(host, wsdl, port, logdev, opt)
      @host = host
      @wsdl = wsdl
      @port = port
      @logdev = logdev
      @mapping_registry = nil		# for unmarshal
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
	add_method_interface(op_info)
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

    def rpc_send(method_name, *params)
      log(SEV_INFO) { "call: calling method '#{ method_name }'." }
      log(SEV_DEBUG) { "call: parameters '#{ params.inspect }'." }

      op_info = @operations[method_name]
      obj = create_method_obj(op_info.param_names, params)
      method = Mapping.obj2soap(obj, @wsdl_mapping_registry, op_info.msg_name)
      method.elename = op_info.op_name
      method.type = XSD::QName.new	# Request should not be typed.
      req_header = nil
      req_body = SOAPBody.new(method)

      if @wiredump_file_base
	@handler.wiredump_file_base = @wiredump_file_base + '_' << method_name
      end

      begin
	res_header, res_body = invoke(req_header, req_body, op_info)
	if res_body.fault
	  raise SOAP::FaultError.new(res_body.fault)
	end
      rescue SOAP::FaultError => e
	Mapping.fault2exception(e)
      end

      ret = res_body.response ?
	Mapping.soap2obj(res_body.response, @mapping_registry) : nil

      if res_body.outparams
	outparams = res_body.outparams.collect { |outparam|
  	  Mapping.soap2obj(outparam)
   	}
    	return [ret].concat(outparams)
      else
      	return ret
      end
    end

    # req_header: [[element, must_understand, encodingstyle(QName/String)], ...]
    # req_body: SOAPBasetype/SOAPCompoundtype
    def document_send(name, header, body)
      log(SEV_INFO) { "send: sending document '#{ name }'." }

      op_info = @operations[name]
      #      body = Mapping.obj2soap(body, @wsdl_mapping_registry, op_info.msg_name)
      #body.elename = op_info.msg_name

      if header and !header.is_a?(SOAPHeader)
	header = create_header(header)
      end
      if !body.is_a?(SOAPBody)
	body = SOAPBody.new(body)
      end

      res_header, res_body = invoke(header, body, op_info)
      return res_header, res_body
    end

  private

    def create_handler
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

    # req_header: [[element, must_understand, encodingstyle(QName/String)], ...]
    # req_body: SOAPBasetype/SOAPCompoundtype
    def invoke(req_header, req_body, op_info)
      opt = create_options
      send_string = Processor.marshal(req_header, req_body, opt)
      data = @handler.send(send_string, op_info.soapaction)
      if data.receive_string.empty?
	return nil, nil
      end
      res_charset = StreamHandler.parse_media_type(data.receive_contenttype)
      opt = create_options
      opt[:charset] = res_charset
      res_header, res_body = Processor.unmarshal(data.receive_string, opt)
      return res_header, res_body
    end

    def create_header(headers)
      header = SOAPHeader.new()
      headers.each do |content, must_understand, encodingstyle|
	header.add(SOAPHeaderItem.new(content, must_understand, encodingstyle))
      end
      header
    end

    def add_method_interface(op_info)
      case op_info.style
      when :document
	add_document_method_interface(op_info.op_name.name)
      when :rpc
	add_rpc_method_interface(op_info.op_name.name, op_info.param_names)
      else
	raise RuntimeError.new("Unknown style: #{op_info.style}")
      end
    end

    def add_document_method_interface(name)
      @host.instance_eval <<-EOS
	def #{ name }(headers, body)
	  @servant.document_send(#{ name.dump }, headers, body)
	end
      EOS
    end

    def add_rpc_method_interface(name, param_names)
      i = 0
      param_names = param_names.collect { |orgname| i += 1; "arg#{ i }" }
      callparam_str = (param_names.collect { |pname| ", " + pname }).join
      @host.instance_eval <<-EOS
	def #{ name }(#{ param_names.join(", ") })
	  @servant.rpc_send(#{ name.dump }#{ callparam_str })
	end
      EOS
    end

    def create_options
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

  def initialize(wsdl, port, logdev, opt)
    @servant = Servant.new(self, wsdl, port, logdev, opt)
  end
end


end


