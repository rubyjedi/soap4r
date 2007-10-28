require 'mms_MizGIS.rb'
require 'mms_MizGISMappingRegistry.rb'
require 'soap/rpc/driver'

class Mms_MizGISPortType < ::SOAP::RPC::Driver
  DefaultEndpointUrl = "http://www.verona.miz.it/mizgis-api/3.4/server"

  Methods = [
    [ XSD::QName.new("urn:mms_MizGIS", "getVersion"),
      "",
      "getVersion",
      [ [:retval, "name", ["::SOAP::SOAPString"]],
        [:out, "version", ["::SOAP::SOAPString"]],
        [:out, "date", ["::SOAP::SOAPString"]],
        [:out, "cartographyVersion", ["::SOAP::SOAPString"]],
        [:out, "poiCartographyVersion", ["::SOAP::SOAPString"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("urn:mms_MizGIS", "getAvailableCountries"),
      "",
      "getAvailableCountries",
      [ [:retval, "countries", ["C_String[]", "urn:mms_MizGIS", "ArrayOfstring"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("urn:mms_MizGIS", "findAddress"),
      "",
      "findAddress",
      [ [:in, "addressSearch", ["AddressSearchType", "urn:mms_MizGIS", "AddressSearchType"]],
        [:in, "maxResults", ["::SOAP::SOAPInt"]],
        [:in, "onlyMunicipalities", ["::SOAP::SOAPBoolean"]],
        [:retval, "addresses", ["AddressType[]", "urn:mms_MizGIS", "ArrayOfAddressType"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("urn:mms_MizGIS", "getAddressFromGeocode"),
      "",
      "getAddressFromGeocode",
      [ [:in, "geocode", ["GeocodeType", "urn:mms_MizGIS", "GeocodeType"]],
        [:in, "languageCode", ["::SOAP::SOAPString"]],
        [:retval, "address", ["AddressType", "urn:mms_MizGIS", "AddressType"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("urn:mms_MizGIS", "findGeocodeFromCoordinates"),
      "",
      "findGeocodeFromCoordinates",
      [ [:in, "coordinates", ["CoordinatesType", "urn:mms_MizGIS", "CoordinatesType"]],
        [:in, "vehicle", ["::SOAP::SOAPInt"]],
        [:retval, "found", ["::SOAP::SOAPBoolean"]],
        [:out, "geocode", ["GeocodeType", "urn:mms_MizGIS", "GeocodeType"]],
        [:out, "distance", ["::SOAP::SOAPDouble"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("urn:mms_MizGIS", "findAddressFromCoordinates"),
      "",
      "findAddressFromCoordinates",
      [ [:in, "coordinates", ["CoordinatesType", "urn:mms_MizGIS", "CoordinatesType"]],
        [:in, "vehicle", ["::SOAP::SOAPInt"]],
        [:in, "languageCode", ["::SOAP::SOAPString"]],
        [:retval, "found", ["::SOAP::SOAPBoolean"]],
        [:out, "address", ["AddressType", "urn:mms_MizGIS", "AddressType"]],
        [:out, "distance", ["::SOAP::SOAPDouble"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("urn:mms_MizGIS", "getListOfPoiMacrocategories"),
      "",
      "getListOfPoiMacrocategories",
      [ [:in, "languageCode", ["::SOAP::SOAPString"]],
        [:retval, "macrocategories", ["PoiMacrocategoryType[]", "urn:mms_MizGIS", "ArrayOfPoiMacrocategoryType"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("urn:mms_MizGIS", "getListOfPoiCategories"),
      "",
      "getListOfPoiCategories",
      [ [:in, "languageCode", ["::SOAP::SOAPString"]],
        [:in, "onlyPopulated", ["::SOAP::SOAPBoolean"]],
        [:retval, "categories", ["PoiCategoryType[]", "urn:mms_MizGIS", "ArrayOfPoiCategoryType"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("urn:mms_MizGIS", "findPois"),
      "",
      "findPois",
      [ [:in, "area", ["AreaType", "urn:mms_MizGIS", "AreaType"]],
        [:in, "box", ["BoxType", "urn:mms_MizGIS", "BoxType"]],
        [:in, "maxResults", ["::SOAP::SOAPInt"]],
        [:in, "macroCategoryIds", ["C_String[]", "urn:mms_MizGIS", "ArrayOfstring"]],
        [:in, "categoryIds", ["C_String[]", "urn:mms_MizGIS", "ArrayOfstring"]],
        [:in, "provideInfo", ["::SOAP::SOAPBoolean"]],
        [:retval, "pois", ["PoiType[]", "urn:mms_MizGIS", "ArrayOfPoiType"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("urn:mms_MizGIS", "getPoiInfo"),
      "",
      "getPoiInfo",
      [ [:in, "poiIds", ["Int[]", "urn:mms_MizGIS", "ArrayOfint"]],
        [:in, "provideInfo", ["::SOAP::SOAPBoolean"]],
        [:retval, "pois", ["PoiType[]", "urn:mms_MizGIS", "ArrayOfPoiType"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("urn:mms_MizGIS", "getListOfRoads"),
      "",
      "getListOfRoads",
      [ [:in, "roadQueries", ["TmcRoadQueryType[]", "urn:mms_MizGIS", "ArrayOfTmcRoadQueryType"]],
        [:in, "roadOptions", ["TmcRoadOptionsType", "urn:mms_MizGIS", "TmcRoadOptionsType"]],
        [:retval, "roads", ["TmcRoadType[]", "urn:mms_MizGIS", "ArrayOfTmcRoadType"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("urn:mms_MizGIS", "getTrafficInfo"),
      "",
      "getTrafficInfo",
      [ [:in, "trafficQuery", ["TmcTrafficQueryType", "urn:mms_MizGIS", "TmcTrafficQueryType"]],
        [:in, "trafficOptions", ["TmcTrafficOptionsType", "urn:mms_MizGIS", "TmcTrafficOptionsType"]],
        [:retval, "info", ["TrafficInfoType[]", "urn:mms_MizGIS", "ArrayOfTrafficInfoType"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("urn:mms_MizGIS", "getTrafficStatus"),
      "",
      "getTrafficStatus",
      [ [:in, "areas", ["AreaType[]", "urn:mms_MizGIS", "ArrayOfAreaType"]],
        [:retval, "status", ["Int[]", "urn:mms_MizGIS", "ArrayOfint"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("urn:mms_MizGIS", "findRoute"),
      "",
      "findRoute",
      [ [:in, "places", ["GeocodeType[]", "urn:mms_MizGIS", "ArrayOfGeocodeType"]],
        [:in, "params", ["RouteParametersType", "urn:mms_MizGIS", "RouteParametersType"]],
        [:retval, "route", ["RouteType", "urn:mms_MizGIS", "RouteType"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("urn:mms_MizGIS", "getMap"),
      "",
      "getMap",
      [ [:in, "imageSize", ["ImageSizeType", "urn:mms_MizGIS", "ImageSizeType"]],
        [:in, "box", ["BoxType", "urn:mms_MizGIS", "BoxType"]],
        [:in, "options", ["MapOptionsType", "urn:mms_MizGIS", "MapOptionsType"]],
        [:retval, "map", ["MapType", "urn:mms_MizGIS", "MapType"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ],
    [ XSD::QName.new("urn:mms_MizGIS", "getMapAround"),
      "",
      "getMapAround",
      [ [:in, "imageSize", ["ImageSizeType", "urn:mms_MizGIS", "ImageSizeType"]],
        [:in, "center", ["CoordinatesType", "urn:mms_MizGIS", "CoordinatesType"]],
        [:in, "radius", ["::SOAP::SOAPDouble"]],
        [:in, "options", ["MapOptionsType", "urn:mms_MizGIS", "MapOptionsType"]],
        [:retval, "map", ["MapType", "urn:mms_MizGIS", "MapType"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded,
        :faults => {} }
    ]
  ]

  def initialize(endpoint_url = nil)
    endpoint_url ||= DefaultEndpointUrl
    super(endpoint_url, nil)
    self.mapping_registry = Mms_MizGISMappingRegistry::EncodedRegistry
    self.literal_mapping_registry = Mms_MizGISMappingRegistry::LiteralRegistry
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

