require 'default.rb'
require 'soap/mapping'

module DefaultMappingRegistry
  EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
  LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new

  EncodedRegistry.register(
    :class => WeatherParametersType,
    :schema_ns => "http://weather.gov/forecasts/xml/DWMLgen/schema/ndfdXML.xsd",
    :schema_type => "weatherParametersType",
    :schema_element => [
      ["maxt", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "maxt")]],
      ["mint", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "mint")]],
      ["temp", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "temp")]],
      ["dew", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "dew")]],
      ["pop12", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "pop12")]],
      ["qpf", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "qpf")]],
      ["sky", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "sky")]],
      ["snow", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "snow")]],
      ["wspd", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "wspd")]],
      ["wdir", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "wdir")]],
      ["wx", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "wx")]],
      ["waveh", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "waveh")]],
      ["icons", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "icons")]]
    ]
  )

  EncodedRegistry.register(
    :class => FormatType,
    :schema_ns => "http://weather.gov/forecasts/xml/DWMLgen/schema/ndfdXML.xsd",
    :schema_type => "formatType"
  )

  EncodedRegistry.register(
    :class => ProductType,
    :schema_ns => "http://weather.gov/forecasts/xml/DWMLgen/schema/ndfdXML.xsd",
    :schema_type => "productType"
  )

  LiteralRegistry.register(
    :class => WeatherParametersType,
    :schema_ns => "http://weather.gov/forecasts/xml/DWMLgen/schema/ndfdXML.xsd",
    :schema_type => "weatherParametersType",
    :schema_qualified => false,
    :schema_element => [
      ["maxt", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "maxt")]],
      ["mint", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "mint")]],
      ["temp", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "temp")]],
      ["dew", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "dew")]],
      ["pop12", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "pop12")]],
      ["qpf", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "qpf")]],
      ["sky", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "sky")]],
      ["snow", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "snow")]],
      ["wspd", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "wspd")]],
      ["wdir", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "wdir")]],
      ["wx", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "wx")]],
      ["waveh", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "waveh")]],
      ["icons", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "icons")]]
    ]
  )

  LiteralRegistry.register(
    :class => FormatType,
    :schema_ns => "http://weather.gov/forecasts/xml/DWMLgen/schema/ndfdXML.xsd",
    :schema_type => "formatType"
  )

  LiteralRegistry.register(
    :class => ProductType,
    :schema_ns => "http://weather.gov/forecasts/xml/DWMLgen/schema/ndfdXML.xsd",
    :schema_type => "productType"
  )
end
