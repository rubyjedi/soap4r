# WSDL4R - Creating driver code from WSDL.
# Copyright (C) 2002, 2003  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/soap/mappingRegistryCreator'
require 'wsdl/soap/methodDefCreator'
require 'wsdl/soap/classDefCreatorSupport'
require 'wsdl/soap/methodDefCreatorSupport'


module WSDL
module SOAP


class DriverCreator
  include ClassDefCreatorSupport
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
require 'soap/rpc/driver'

class #{ create_class_name(name) } < SOAP::RPC::Driver
  MappingRegistry = ::SOAP::Mapping::Registry.new

#{ mr_creator.dump(types).gsub(/^/, "  ").chomp }
  Methods = [
#{ methoddef.gsub(/^/, "    ") }
  ]

  DefaultEndpointUrl = "#{ addresses[0] }"

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = MappingRegistry
    init_methods
  end

private 

  def init_methods
    Methods.each do |name_as, name, params, soapaction, namespace|
      qname = XSD::QName.new(namespace, name_as)
      @proxy.add_method(qname, soapaction, name, params)
      add_rpc_method_interface(name, params)
    end
  end
end
__EOD__
  end
end


end
end
