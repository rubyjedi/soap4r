# WSDL4R - Creating driver code from WSDL.
# Copyright (C) 2002, 2003, 2005, 2006  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/soap/mappingRegistryCreator'
require 'wsdl/soap/literalMappingRegistryCreator'
require 'wsdl/soap/methodDefCreator'
require 'wsdl/soap/classDefCreatorSupport'
require 'xsd/codegen'


module WSDL
module SOAP


class DriverCreator
  include ClassDefCreatorSupport

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

  def dump_porttype(porttype)
    class_name = create_class_name(porttype)
    methoddef, methodtypes = MethodDefCreator.new(@definitions).dump(porttype)
    mr_creator = MappingRegistryCreator.new(@definitions)
    literal_mr_creator = LiteralMappingRegistryCreator.new(@definitions)
    binding = @definitions.bindings.find { |item| item.type == porttype }
    if binding.nil? or binding.soapbinding.nil?
      # not bind or not a SOAP binding
      return ''
    end
    address = @definitions.porttype(porttype).locations[0]

    c = XSD::CodeGen::ClassDef.new(class_name, "::SOAP::RPC::Driver")
    c.def_require("soap/rpc/driver")
    #c.def_const("EncodedMappingRegistry", "::SOAP::Mapping::EncodedRegistry.new")
    c.def_const("MappingRegistry", "::SOAP::Mapping::EncodedRegistry.new")
    #c.def_const("LiteralMappingRegistry", "::SOAP::Mapping::LiteralRegistry.new")
    c.def_const("DefaultEndpointUrl", ndq(address))
    c.def_code(mr_creator.dump(methodtypes))
    #c.def_code(literal_mr_creator.dump)
    c.def_code <<-EOD
Methods = [
#{methoddef.gsub(/^/, "  ")}
]
    EOD
        #self.literal_mapping_registry = LiteralMappingRegistry
    c.def_method("initialize", "endpoint_url = nil") do
      <<-EOD
        endpoint_url ||= DefaultEndpointUrl
        super(endpoint_url, nil)
        self.mapping_registry = MappingRegistry
        init_methods
      EOD
    end
    c.def_privatemethod("init_methods") do
      <<-EOD
        Methods.each do |definitions|
          opt = definitions.last
          if opt[:request_style] == :document
            add_document_operation(*definitions)
          else
            add_rpc_operation(*definitions)
            qname = definitions[0]
            name = definitions[2]
            if qname.name != name and qname.name.capitalize == name.capitalize
              ::SOAP::Mapping.define_singleton_method(self, qname.name) do |*arg|
                __send__(name, *arg)
              end
            end
          end
        end
      EOD
    end
    c.dump
  end
end


end
end
