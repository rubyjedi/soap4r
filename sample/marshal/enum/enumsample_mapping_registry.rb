require 'xsd/mapping'
require 'enumsample.rb'

module EnumsampleMappingRegistry
  Registry = ::SOAP::Mapping::LiteralRegistry.new

  Registry.register(
    :class => HobbitType,
    :schema_ns => "urn:org.example.enumsample",
    :schema_type => "hobbit.type",
    :schema_qualified => false,
    :schema_element => [
      ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "name")]],
      ["age", ["SOAP::SOAPInt", XSD::QName.new(nil, "age")]]
    ]
  )

  Registry.register(
    :class => HobbitNameType,
    :schema_ns => "urn:org.example.enumsample",
    :schema_type => "hobbit.name.type"
  )
end
