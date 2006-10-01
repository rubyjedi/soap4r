# WSDL4R - Creating MappingRegistry code from WSDL.
# Copyright (C) 2006  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/soap/classDefCreatorSupport'
require 'wsdl/soap/encodedMappingRegistryCreator'
require 'wsdl/soap/literalMappingRegistryCreator'


module WSDL
module SOAP


class MappingRegistryCreator
  include ClassDefCreatorSupport

  attr_reader :definitions

  def initialize(definitions, modulepath = nil)
    @definitions = definitions
    @modulepath = modulepath
  end

  def dump
    encoded_creator = EncodedMappingRegistryCreator.new(@definitions, @modulepath)
    literal_creator = LiteralMappingRegistryCreator.new(@definitions, @modulepath)
    wsdl_name = @definitions.name ? @definitions.name.name : 'default'
    module_name = safeconstname(wsdl_name + 'MappingRegistry')
    if @modulepath
      module_name = [@modulepath, module_name].join('::')
    end
    m = XSD::CodeGen::ModuleDef.new(module_name)
    m.def_require("soap/mapping")
    varname = 'EncodedRegistry'
    methodname = 'define_encoded_mapping'
    m.def_const(varname, '::SOAP::Mapping::EncodedRegistry.new')
    m.def_code(encoded_creator.dump(varname))
    varname = 'LiteralRegistry'
    methodname = 'define_literal_mapping'
    m.def_const(varname, '::SOAP::Mapping::LiteralRegistry.new')
    m.def_code(literal_creator.dump(varname))
    m.dump
  end
end


end
end
