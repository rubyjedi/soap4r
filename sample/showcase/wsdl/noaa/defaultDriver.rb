require 'default.rb'
require 'defaultMappingRegistry.rb'
require 'soap/rpc/driver'

class NdfdXMLPortType < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://weather.gov/forecasts/xml/SOAP_server/ndfdXMLserver.php"

  Methods = [
    [ XSD::QName.new("http://weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl", "NDFDgen"),
      "http://weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl#NDFDgen",
      "nDFDgen",
      [ [:in, "latitude", ["::SOAP::SOAPDecimal"]],
        [:in, "longitude", ["::SOAP::SOAPDecimal"]],
        [:in, "product", [nil, "http://weather.gov/forecasts/xml/DWMLgen/schema/ndfdXML.xsd", "productType"]],
        [:in, "startTime", ["::SOAP::SOAPDateTime"]],
        [:in, "endTime", ["::SOAP::SOAPDateTime"]],
        [:in, "weatherParameters", ["WeatherParametersType", "http://weather.gov/forecasts/xml/DWMLgen/schema/ndfdXML.xsd", "weatherParametersType"]],
        [:retval, "dwmlOut", ["::SOAP::SOAPString"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("http://weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl", "NDFDgenByDay"),
      "http://weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl#NDFDgenByDay",
      "nDFDgenByDay",
      [ [:in, "latitude", ["::SOAP::SOAPDecimal"]],
        [:in, "longitude", ["::SOAP::SOAPDecimal"]],
        [:in, "startDate", ["::SOAP::SOAPDate"]],
        [:in, "numDays", ["::SOAP::SOAPInteger"]],
        [:in, "format", [nil, "http://weather.gov/forecasts/xml/DWMLgen/schema/ndfdXML.xsd", "formatType"]],
        [:retval, "dwmlByDayOut", ["::SOAP::SOAPString"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = DefaultMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = DefaultMappingRegistry::LiteralRegistry
    init_methods
  end

private

  def init_methods
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
  end
end

