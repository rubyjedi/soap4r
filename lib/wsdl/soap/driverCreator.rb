=begin
WSDL4R - Creating driver code from WSDL.
Copyright (C) 2002 NAKAMURA Hiroshi.

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


require 'wsdl/info'
require 'wsdl/soap/mappingRegistryCreator'
require 'wsdl/soap/methodDefCreator'
require 'wsdl/soap/methodDefCreatorSupport'


module WSDL
  module SOAP


class DriverCreator
  include MethodDefCreatorSupport

  attr_reader :definitions

  def initialize(definitions)
    @definitions = definitions
  end

  def dump(porttype = nil)
    if porttype.nil?
      result = ""
      @definitions.porttypes.each do |type|
	result << dump_porttype(type.name)
	result << "\n"
      end
    else
      result = dump_porttype(porttype)
    end
    result
  end

private

  def dump_porttype(name)
    methoddef, types = MethodDefCreator.new(@definitions).dump(name)
    mr_creator = MappingRegistryCreator.new(@definitions)
    binding = @definitions.bindings.find { |item| item.type == name }
    addresses = @definitions.porttype(name).locations

    return <<__EOD__
require 'soap/proxy'
require 'soap/rpcUtils'
require 'soap/streamHandler'

class #{ create_class_name(name) }
  class EmptyResponseError < ::SOAP::Error; end

  MappingRegistry = ::SOAP::RPCUtils::MappingRegistry.new

#{ mr_creator.dump(types).gsub(/^/, "  ").chomp }
  Methods = [
#{ methoddef.gsub(/^/, "    ") }
  ]

  DefaultEndpointUrl = "#{ addresses[0] }"

  attr_accessor :mapping_registry
  attr_reader :endpoint_url
  attr_reader :wiredump_dev
  attr_reader :wiredump_file_base
  attr_reader :httpproxy

  def initialize(endpoint_url = DefaultEndpointUrl, httpproxy = nil)
    @endpoint_url = endpoint_url
    @mapping_registry = MappingRegistry
    @wiredump_dev = nil
    @wiredump_file_base = nil
    @httpproxy = ENV['http_proxy'] || ENV['HTTP_PROXY']
    @handler = ::SOAP::HTTPPostStreamHandler.new(@endpoint_url, @httpproxy,
      ::SOAP::Charset.encoding_label)
    @proxy = ::SOAP::SOAPProxy.new(@handler, @namespace)
    @proxy.allow_unqualified_element = true
    add_method
  end

  def endpoint_url=(endpoint_url)
    @endpoint_url = endpoint_url
    @handler.endpoint_url = @endpoint_url if @handler
  end

  def wiredump_dev=(dev)
    @wiredump_dev = dev
    @handler.wiredump_dev = @wiredump_dev if @handler
  end

  def wiredump_file_base=(base)
    @wiredump_file_base = base
  end

  def httpproxy=(httpproxy)
    @httpproxy = httpproxy
    @handler.proxy = @httpproxy if @handler
  end

  def default_encodingstyle=(encodingstyle)
    @proxy.default_encodingstyle = encodingstyle
  end

  def default_encodingstyle
    @proxy.default_encodingstyle
  end

  def call(name, *params)
    # Convert parameters: params array => SOAPArray => members array
    params = ::SOAP::RPCUtils.obj2soap(params, @mapping_registry).to_a
    header, body = @proxy.call(nil, name, *params)
    unless body
      raise EmptyResponseError.new("Empty response.")
    end

    # Check Fault.
    begin
      @proxy.check_fault(body)
    rescue ::SOAP::FaultError => e
      ::SOAP::RPCUtils.fault2exception(e)
    end

    ret = body.response ?
      ::SOAP::RPCUtils.soap2obj(body.response, @mapping_registry) : nil
    if body.outparams
      outparams = body.outparams.collect { |outparam|
	::SOAP::RPCUtils.soap2obj(outparam)
      }
      return [ret].concat(outparams)
    else
      return ret
    end
  end

private 

  def add_method
    Methods.each do |name_as, name, params, soapaction, namespace|
      @proxy.add_method(XSD::QName.new(namespace, name), soapaction, name_as, params)
      add_method_interface(name, params)
    end
  end

  def add_method_interface(name, params)
    self.instance_eval <<-EOD
      def \#{ name }(*params)
	call("\#{ name }", *params)
      end
    EOD
  end
end
__EOD__
  end
end


  end
end
