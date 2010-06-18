# encoding: ASCII-8BIT
require 'enumsample_mapping_registry.rb'

class EnumsampleMapper < XSD::Mapping::Mapper
  def initialize
    super(EnumsampleMappingRegistry::Registry)
  end
end
