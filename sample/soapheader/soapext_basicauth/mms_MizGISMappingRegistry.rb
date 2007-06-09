require 'mms_MizGIS.rb'
require 'soap/mapping'

module Mms_MizGISMappingRegistry
  EncodedRegistry = ::SOAP::Mapping::EncodedRegistry.new
  LiteralRegistry = ::SOAP::Mapping::LiteralRegistry.new

  EncodedRegistry.set(
    ArrayOfint,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("http://www.w3.org/2001/XMLSchema", "int") }
  )

  EncodedRegistry.set(
    ArrayOfstring,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("http://www.w3.org/2001/XMLSchema", "string") }
  )

  EncodedRegistry.register(
    :class => AccessCredentialsType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "AccessCredentialsType",
    :schema_element => [
      ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "Name")]],
      ["password", ["SOAP::SOAPString", XSD::QName.new(nil, "Password")]]
    ]
  )

  EncodedRegistry.register(
    :class => AddressSearchType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "AddressSearchType",
    :schema_element => [
      ["languageCode", ["SOAP::SOAPString", XSD::QName.new(nil, "languageCode")]],
      ["countryCode", ["SOAP::SOAPString", XSD::QName.new(nil, "countryCode")]],
      ["place", ["SOAP::SOAPString", XSD::QName.new(nil, "place")]],
      ["street", ["SOAP::SOAPString", XSD::QName.new(nil, "street")]],
      ["houseNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "houseNumber")]]
    ]
  )

  EncodedRegistry.register(
    :class => CoordinatesType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "CoordinatesType",
    :schema_element => [
      ["longitude", ["SOAP::SOAPDouble", XSD::QName.new(nil, "longitude")]],
      ["latitude", ["SOAP::SOAPDouble", XSD::QName.new(nil, "latitude")]]
    ]
  )

  EncodedRegistry.register(
    :class => BoxType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "BoxType",
    :schema_element => [
      ["bottomLeft", ["CoordinatesType", XSD::QName.new(nil, "bottomLeft")]],
      ["topRight", ["CoordinatesType", XSD::QName.new(nil, "topRight")]]
    ]
  )

  EncodedRegistry.register(
    :class => AreaType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "AreaType",
    :schema_element => [
      ["center", ["CoordinatesType", XSD::QName.new(nil, "center")]],
      ["radius", ["SOAP::SOAPDouble", XSD::QName.new(nil, "radius")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfAreaType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "AreaType") }
  )

  EncodedRegistry.register(
    :class => GeocodeType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "GeocodeType",
    :schema_element => [
      ["areaId", ["SOAP::SOAPInt", XSD::QName.new(nil, "areaId")]],
      ["streetNameId", ["SOAP::SOAPInt", XSD::QName.new(nil, "streetNameId")]],
      ["lineId", ["SOAP::SOAPInt", XSD::QName.new(nil, "lineId")]],
      ["position", ["SOAP::SOAPDouble", XSD::QName.new(nil, "position")]],
      ["direction", ["SOAP::SOAPInt", XSD::QName.new(nil, "direction")]],
      ["highway", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "highway")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfGeocodeType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "GeocodeType") }
  )

  EncodedRegistry.register(
    :class => AddressType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "AddressType",
    :schema_element => [
      ["countryCode", ["SOAP::SOAPString", XSD::QName.new(nil, "countryCode")]],
      ["languageCode", ["SOAP::SOAPString", XSD::QName.new(nil, "languageCode")]],
      ["countryName", ["SOAP::SOAPString", XSD::QName.new(nil, "countryName")]],
      ["region", ["SOAP::SOAPString", XSD::QName.new(nil, "region")]],
      ["municipality", ["SOAP::SOAPString", XSD::QName.new(nil, "municipality")]],
      ["languageCodeDistrict", ["SOAP::SOAPString", XSD::QName.new(nil, "languageCodeDistrict")]],
      ["district", ["SOAP::SOAPString", XSD::QName.new(nil, "district")]],
      ["languageCodeStreetName", ["SOAP::SOAPString", XSD::QName.new(nil, "languageCodeStreetName")]],
      ["streetName", ["SOAP::SOAPString", XSD::QName.new(nil, "streetName")]],
      ["houseNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "houseNumber")]],
      ["postCode", ["SOAP::SOAPString", XSD::QName.new(nil, "postCode")]],
      ["coordinates", ["CoordinatesType", XSD::QName.new(nil, "coordinates")]],
      ["geocode", ["GeocodeType", XSD::QName.new(nil, "geocode")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfAddressType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "AddressType") }
  )

  EncodedRegistry.register(
    :class => PoiMacrocategoryType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "PoiMacrocategoryType",
    :schema_element => [
      ["macrocategoryId", ["SOAP::SOAPString", XSD::QName.new(nil, "macrocategoryId")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(nil, "description")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfPoiMacrocategoryType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "PoiMacrocategoryType") }
  )

  EncodedRegistry.register(
    :class => PoiCategoryType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "PoiCategoryType",
    :schema_element => [
      ["categoryId", ["SOAP::SOAPString", XSD::QName.new(nil, "categoryId")]],
      ["macrocategoryId", ["SOAP::SOAPString", XSD::QName.new(nil, "macrocategoryId")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(nil, "description")]],
      ["populated", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "populated")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfPoiCategoryType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "PoiCategoryType") }
  )

  EncodedRegistry.register(
    :class => PoiInfoType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "PoiInfoType",
    :schema_element => [
      ["type", ["SOAP::SOAPInt", XSD::QName.new(nil, "type")]],
      ["value", ["SOAP::SOAPString", XSD::QName.new(nil, "value")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfPoiInfoType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "PoiInfoType") }
  )

  EncodedRegistry.register(
    :class => PoiType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "PoiType",
    :schema_element => [
      ["poiId", ["SOAP::SOAPInt", XSD::QName.new(nil, "poiId")]],
      ["categories", ["ArrayOfstring", XSD::QName.new(nil, "categories")]],
      ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "name")]],
      ["coordinates", ["CoordinatesType", XSD::QName.new(nil, "coordinates")]],
      ["geocode", ["GeocodeType", XSD::QName.new(nil, "geocode")]],
      ["address", ["SOAP::SOAPString", XSD::QName.new(nil, "address")]],
      ["postCode", ["SOAP::SOAPString", XSD::QName.new(nil, "postCode")]],
      ["place", ["SOAP::SOAPString", XSD::QName.new(nil, "place")]],
      ["country", ["SOAP::SOAPString", XSD::QName.new(nil, "country")]],
      ["info", ["ArrayOfPoiInfoType", XSD::QName.new(nil, "info")]],
      ["distance", ["SOAP::SOAPDouble", XSD::QName.new(nil, "distance")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfPoiType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "PoiType") }
  )

  EncodedRegistry.register(
    :class => TmcIdType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TmcIdType",
    :schema_element => [
      ["cid", ["SOAP::SOAPInt", XSD::QName.new(nil, "cid")]],
      ["tabCd", ["SOAP::SOAPInt", XSD::QName.new(nil, "tabCd")]],
      ["lcd", ["SOAP::SOAPInt", XSD::QName.new(nil, "lcd")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfTmcIdType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "TmcIdType") }
  )

  EncodedRegistry.register(
    :class => TmcRoadQueryType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TmcRoadQueryType",
    :schema_element => [
      ["cid", ["SOAP::SOAPInt", XSD::QName.new(nil, "cid")]],
      ["tabCd", ["SOAP::SOAPInt", XSD::QName.new(nil, "tabCd")]],
      ["roadLcds", ["ArrayOfint", XSD::QName.new(nil, "roadLcds")]],
      ["roadCodes", ["ArrayOfstring", XSD::QName.new(nil, "roadCodes")]],
      ["roadTypes", ["ArrayOfint", XSD::QName.new(nil, "roadTypes")]],
      ["roadName", ["SOAP::SOAPString", XSD::QName.new(nil, "roadName")]],
      ["status", ["SOAP::SOAPInt", XSD::QName.new(nil, "status")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfTmcRoadQueryType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "TmcRoadQueryType") }
  )

  EncodedRegistry.register(
    :class => TmcRoadOptionsType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TmcRoadOptionsType",
    :schema_element => [
      ["provideBox", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "provideBox")]],
      ["nameDirections", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "nameDirections")]],
      ["listPoints", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "listPoints")]],
      ["minPointImportance", ["SOAP::SOAPInt", XSD::QName.new(nil, "minPointImportance")]]
    ]
  )

  EncodedRegistry.register(
    :class => TmcPointType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TmcPointType",
    :schema_element => [
      ["pointId", ["TmcIdType", XSD::QName.new(nil, "pointId")]],
      ["roadLcd", ["SOAP::SOAPInt", XSD::QName.new(nil, "roadLcd")]],
      ["segmentLcd", ["SOAP::SOAPInt", XSD::QName.new(nil, "segmentLcd")]],
      ["areaLcd", ["SOAP::SOAPInt", XSD::QName.new(nil, "areaLcd")]],
      ["coordinates", ["CoordinatesType", XSD::QName.new(nil, "coordinates")]],
      ["pointName", ["SOAP::SOAPString", XSD::QName.new(nil, "pointName")]],
      ["importance", ["SOAP::SOAPInt", XSD::QName.new(nil, "importance")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfTmcPointType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "TmcPointType") }
  )

  EncodedRegistry.register(
    :class => TmcRoadType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TmcRoadType",
    :schema_element => [
      ["roadId", ["TmcIdType", XSD::QName.new(nil, "roadId")]],
      ["roadType", ["SOAP::SOAPInt", XSD::QName.new(nil, "roadType")]],
      ["roadCode", ["SOAP::SOAPString", XSD::QName.new(nil, "roadCode")]],
      ["roadName", ["SOAP::SOAPString", XSD::QName.new(nil, "roadName")]],
      ["box", ["BoxType", XSD::QName.new(nil, "box")]],
      ["status", ["SOAP::SOAPInt", XSD::QName.new(nil, "status")]],
      ["positiveDirName", ["SOAP::SOAPString", XSD::QName.new(nil, "positiveDirName")]],
      ["negativeDirName", ["SOAP::SOAPString", XSD::QName.new(nil, "negativeDirName")]],
      ["points", ["ArrayOfTmcPointType", XSD::QName.new(nil, "points")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfTmcRoadType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "TmcRoadType") }
  )

  EncodedRegistry.register(
    :class => TmcTrafficQueryType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TmcTrafficQueryType",
    :schema_element => [
      ["area", ["AreaType", XSD::QName.new(nil, "area")]],
      ["box", ["BoxType", XSD::QName.new(nil, "box")]],
      ["roadIds", ["ArrayOfTmcIdType", XSD::QName.new(nil, "roadIds")]],
      ["fromPoint", ["TmcIdType", XSD::QName.new(nil, "fromPoint")]],
      ["toPoint", ["TmcIdType", XSD::QName.new(nil, "toPoint")]],
      ["traffIds", ["ArrayOfstring", XSD::QName.new(nil, "traffIds")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfTmcTrafficQueryType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "TmcTrafficQueryType") }
  )

  EncodedRegistry.register(
    :class => TmcTrafficOptionsType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TmcTrafficOptionsType",
    :schema_element => [
      ["languageCode", ["SOAP::SOAPString", XSD::QName.new(nil, "languageCode")]],
      ["maxResults", ["SOAP::SOAPInt", XSD::QName.new(nil, "maxResults")]],
      ["orderBySeverity", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "orderBySeverity")]]
    ]
  )

  EncodedRegistry.register(
    :class => TrafficInfoType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TrafficInfoType",
    :schema_element => [
      ["id", ["SOAP::SOAPString", XSD::QName.new(nil, "id")]],
      ["cat", ["SOAP::SOAPInt", XSD::QName.new(nil, "cat")]],
      ["dob", ["SOAP::SOAPString", XSD::QName.new(nil, "dob")]],
      ["dob2", ["SOAP::SOAPString", XSD::QName.new(nil, "dob2")]],
      ["dateTime", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "dateTime")]],
      ["coordinates", ["CoordinatesType", XSD::QName.new(nil, "coordinates")]],
      ["distance", ["SOAP::SOAPDouble", XSD::QName.new(nil, "distance")]],
      ["road", ["TmcRoadType", XSD::QName.new(nil, "road")]],
      ["roadName", ["SOAP::SOAPString", XSD::QName.new(nil, "roadName")]],
      ["directionName", ["SOAP::SOAPString", XSD::QName.new(nil, "directionName")]],
      ["segmentName", ["SOAP::SOAPString", XSD::QName.new(nil, "segmentName")]],
      ["areaName", ["SOAP::SOAPString", XSD::QName.new(nil, "areaName")]],
      ["place", ["SOAP::SOAPString", XSD::QName.new(nil, "place")]],
      ["extraPlace", ["SOAP::SOAPString", XSD::QName.new(nil, "extraPlace")]],
      ["text", ["SOAP::SOAPString", XSD::QName.new(nil, "text")]],
      ["extraText", ["SOAP::SOAPString", XSD::QName.new(nil, "extraText")]],
      ["source", ["SOAP::SOAPString", XSD::QName.new(nil, "source")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfTrafficInfoType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "TrafficInfoType") }
  )

  EncodedRegistry.register(
    :class => RouteParametersType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "RouteParametersType",
    :schema_element => [
      ["startingTime", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "startingTime")]],
      ["arrivalTime", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "arrivalTime")]],
      ["mode", ["SOAP::SOAPInt", XSD::QName.new(nil, "mode")]],
      ["optimization", ["SOAP::SOAPInt", XSD::QName.new(nil, "optimization")]],
      ["realTime", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "realTime")]],
      ["descriptionLevel", ["SOAP::SOAPInt", XSD::QName.new(nil, "descriptionLevel")]],
      ["descriptionLanguageCode", ["SOAP::SOAPString", XSD::QName.new(nil, "descriptionLanguageCode")]],
      ["providePath", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "providePath")]],
      ["providePathPoints", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "providePathPoints")]]
    ]
  )

  EncodedRegistry.register(
    :class => RouteStepType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "RouteStepType",
    :schema_element => [
      ["time", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "time")]],
      ["duration", ["SOAP::SOAPInt", XSD::QName.new(nil, "duration")]],
      ["distance", ["SOAP::SOAPDouble", XSD::QName.new(nil, "distance")]],
      ["action", ["SOAP::SOAPInt", XSD::QName.new(nil, "action")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(nil, "description")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfRouteStepType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "RouteStepType") }
  )

  EncodedRegistry.register(
    :class => RouteSegmentType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "RouteSegmentType",
    :schema_element => [
      ["origin", ["GeocodeType", XSD::QName.new(nil, "origin")]],
      ["destination", ["GeocodeType", XSD::QName.new(nil, "destination")]],
      ["startingTime", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "startingTime")]],
      ["duration", ["SOAP::SOAPInt", XSD::QName.new(nil, "duration")]],
      ["distance", ["SOAP::SOAPDouble", XSD::QName.new(nil, "distance")]],
      ["vehicle", ["SOAP::SOAPInt", XSD::QName.new(nil, "vehicle")]],
      ["steps", ["ArrayOfRouteStepType", XSD::QName.new(nil, "steps")]],
      ["path", ["SOAP::SOAPString", XSD::QName.new(nil, "path")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfRouteSegmentType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "RouteSegmentType") }
  )

  EncodedRegistry.register(
    :class => RoutePartType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "RoutePartType",
    :schema_element => [
      ["origin", ["GeocodeType", XSD::QName.new(nil, "origin")]],
      ["destination", ["GeocodeType", XSD::QName.new(nil, "destination")]],
      ["startingTime", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "startingTime")]],
      ["duration", ["SOAP::SOAPInt", XSD::QName.new(nil, "duration")]],
      ["distance", ["SOAP::SOAPDouble", XSD::QName.new(nil, "distance")]],
      ["segments", ["ArrayOfRouteSegmentType", XSD::QName.new(nil, "segments")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfRoutePartType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "RoutePartType") }
  )

  EncodedRegistry.register(
    :class => RouteType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "RouteType",
    :schema_element => [
      ["routeId", ["SOAP::SOAPString", XSD::QName.new(nil, "routeId")]],
      ["origin", ["GeocodeType", XSD::QName.new(nil, "origin")]],
      ["destination", ["GeocodeType", XSD::QName.new(nil, "destination")]],
      ["startingTime", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "startingTime")]],
      ["duration", ["SOAP::SOAPInt", XSD::QName.new(nil, "duration")]],
      ["distance", ["SOAP::SOAPDouble", XSD::QName.new(nil, "distance")]],
      ["parts", ["ArrayOfRoutePartType", XSD::QName.new(nil, "parts")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfRouteType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "RouteType") }
  )

  EncodedRegistry.register(
    :class => ImagePointType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ImagePointType",
    :schema_element => [
      ["x", ["SOAP::SOAPInt", XSD::QName.new(nil, "x")]],
      ["y", ["SOAP::SOAPInt", XSD::QName.new(nil, "y")]]
    ]
  )

  EncodedRegistry.register(
    :class => ImageSizeType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ImageSizeType",
    :schema_element => [
      ["width", ["SOAP::SOAPInt", XSD::QName.new(nil, "width")]],
      ["height", ["SOAP::SOAPInt", XSD::QName.new(nil, "height")]]
    ]
  )

  EncodedRegistry.register(
    :class => MapIconType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "MapIconType",
    :schema_element => [
      ["iconId", ["SOAP::SOAPString", XSD::QName.new(nil, "iconId")]],
      ["iconType", ["SOAP::SOAPString", XSD::QName.new(nil, "iconType")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(nil, "description")]],
      ["dimmed", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "dimmed")]],
      ["minimize", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "minimize")]],
      ["coordinates", ["CoordinatesType", XSD::QName.new(nil, "coordinates")]],
      ["point", ["ImagePointType", XSD::QName.new(nil, "point")]]
    ]
  )

  EncodedRegistry.set(
    ArrayOfMapIconType,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::EncodedRegistry::TypedArrayFactory,
    { :type => XSD::QName.new("urn:mms_MizGIS", "MapIconType") }
  )

  EncodedRegistry.register(
    :class => MapOptionsType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "MapOptionsType",
    :schema_element => [
      ["format", ["SOAP::SOAPString", XSD::QName.new(nil, "format")]],
      ["showTrafficEvents", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "showTrafficEvents")]],
      ["trafficIconPrefix", ["SOAP::SOAPString", XSD::QName.new(nil, "trafficIconPrefix")]],
      ["trafficIconsDimmed", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "trafficIconsDimmed")]],
      ["roadId", ["TmcIdType", XSD::QName.new(nil, "roadId")]],
      ["routeId", ["SOAP::SOAPString", XSD::QName.new(nil, "routeId")]],
      ["poiIds", ["ArrayOfint", XSD::QName.new(nil, "poiIds")]],
      ["trafficInfoIds", ["ArrayOfstring", XSD::QName.new(nil, "trafficInfoIds")]],
      ["icons", ["ArrayOfMapIconType", XSD::QName.new(nil, "icons")]],
      ["routeIds", ["ArrayOfstring", XSD::QName.new(nil, "routeIds")]],
      ["showBasicPois", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "showBasicPois")]]
    ]
  )

  EncodedRegistry.register(
    :class => MapType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "MapType",
    :schema_element => [
      ["imageSize", ["ImageSizeType", XSD::QName.new(nil, "imageSize")]],
      ["box", ["BoxType", XSD::QName.new(nil, "box")]],
      ["width", ["SOAP::SOAPDouble", XSD::QName.new(nil, "width")]],
      ["height", ["SOAP::SOAPDouble", XSD::QName.new(nil, "height")]],
      ["imageUrl", ["SOAP::SOAPString", XSD::QName.new(nil, "imageUrl")]],
      ["icons", ["ArrayOfMapIconType", XSD::QName.new(nil, "icons")]]
    ]
  )

  EncodedRegistry.register(
    :class => ModeType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ModeType"
  )

  EncodedRegistry.register(
    :class => VehicleType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "VehicleType"
  )

  EncodedRegistry.register(
    :class => OptimizationType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "OptimizationType"
  )

  EncodedRegistry.register(
    :class => DescriptionLevelType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "DescriptionLevelType"
  )

  EncodedRegistry.register(
    :class => StepActionType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "StepActionType"
  )

  EncodedRegistry.register(
    :class => TmcRoadTypeType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TmcRoadTypeType"
  )

  LiteralRegistry.register(
    :class => ArrayOfint,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfint",
    :schema_element => [
      ["item", ["SOAP::SOAPInt[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfstring,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfstring",
    :schema_element => [
      ["item", ["SOAP::SOAPString[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => AccessCredentialsType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "AccessCredentialsType",
    :schema_qualified => false,
    :schema_element => [
      ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "Name")]],
      ["password", ["SOAP::SOAPString", XSD::QName.new(nil, "Password")]]
    ]
  )

  LiteralRegistry.register(
    :class => AddressSearchType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "AddressSearchType",
    :schema_qualified => false,
    :schema_element => [
      ["languageCode", ["SOAP::SOAPString", XSD::QName.new(nil, "languageCode")]],
      ["countryCode", ["SOAP::SOAPString", XSD::QName.new(nil, "countryCode")]],
      ["place", ["SOAP::SOAPString", XSD::QName.new(nil, "place")]],
      ["street", ["SOAP::SOAPString", XSD::QName.new(nil, "street")]],
      ["houseNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "houseNumber")]]
    ]
  )

  LiteralRegistry.register(
    :class => CoordinatesType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "CoordinatesType",
    :schema_qualified => false,
    :schema_element => [
      ["longitude", ["SOAP::SOAPDouble", XSD::QName.new(nil, "longitude")]],
      ["latitude", ["SOAP::SOAPDouble", XSD::QName.new(nil, "latitude")]]
    ]
  )

  LiteralRegistry.register(
    :class => BoxType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "BoxType",
    :schema_qualified => false,
    :schema_element => [
      ["bottomLeft", ["CoordinatesType", XSD::QName.new(nil, "bottomLeft")]],
      ["topRight", ["CoordinatesType", XSD::QName.new(nil, "topRight")]]
    ]
  )

  LiteralRegistry.register(
    :class => AreaType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "AreaType",
    :schema_qualified => false,
    :schema_element => [
      ["center", ["CoordinatesType", XSD::QName.new(nil, "center")]],
      ["radius", ["SOAP::SOAPDouble", XSD::QName.new(nil, "radius")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfAreaType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfAreaType",
    :schema_element => [
      ["item", ["AreaType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => GeocodeType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "GeocodeType",
    :schema_qualified => false,
    :schema_element => [
      ["areaId", ["SOAP::SOAPInt", XSD::QName.new(nil, "areaId")]],
      ["streetNameId", ["SOAP::SOAPInt", XSD::QName.new(nil, "streetNameId")]],
      ["lineId", ["SOAP::SOAPInt", XSD::QName.new(nil, "lineId")]],
      ["position", ["SOAP::SOAPDouble", XSD::QName.new(nil, "position")]],
      ["direction", ["SOAP::SOAPInt", XSD::QName.new(nil, "direction")]],
      ["highway", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "highway")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfGeocodeType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfGeocodeType",
    :schema_element => [
      ["item", ["GeocodeType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => AddressType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "AddressType",
    :schema_qualified => false,
    :schema_element => [
      ["countryCode", ["SOAP::SOAPString", XSD::QName.new(nil, "countryCode")]],
      ["languageCode", ["SOAP::SOAPString", XSD::QName.new(nil, "languageCode")]],
      ["countryName", ["SOAP::SOAPString", XSD::QName.new(nil, "countryName")]],
      ["region", ["SOAP::SOAPString", XSD::QName.new(nil, "region")]],
      ["municipality", ["SOAP::SOAPString", XSD::QName.new(nil, "municipality")]],
      ["languageCodeDistrict", ["SOAP::SOAPString", XSD::QName.new(nil, "languageCodeDistrict")]],
      ["district", ["SOAP::SOAPString", XSD::QName.new(nil, "district")]],
      ["languageCodeStreetName", ["SOAP::SOAPString", XSD::QName.new(nil, "languageCodeStreetName")]],
      ["streetName", ["SOAP::SOAPString", XSD::QName.new(nil, "streetName")]],
      ["houseNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "houseNumber")]],
      ["postCode", ["SOAP::SOAPString", XSD::QName.new(nil, "postCode")]],
      ["coordinates", ["CoordinatesType", XSD::QName.new(nil, "coordinates")]],
      ["geocode", ["GeocodeType", XSD::QName.new(nil, "geocode")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfAddressType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfAddressType",
    :schema_element => [
      ["item", ["AddressType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => PoiMacrocategoryType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "PoiMacrocategoryType",
    :schema_qualified => false,
    :schema_element => [
      ["macrocategoryId", ["SOAP::SOAPString", XSD::QName.new(nil, "macrocategoryId")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(nil, "description")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfPoiMacrocategoryType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfPoiMacrocategoryType",
    :schema_element => [
      ["item", ["PoiMacrocategoryType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => PoiCategoryType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "PoiCategoryType",
    :schema_qualified => false,
    :schema_element => [
      ["categoryId", ["SOAP::SOAPString", XSD::QName.new(nil, "categoryId")]],
      ["macrocategoryId", ["SOAP::SOAPString", XSD::QName.new(nil, "macrocategoryId")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(nil, "description")]],
      ["populated", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "populated")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfPoiCategoryType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfPoiCategoryType",
    :schema_element => [
      ["item", ["PoiCategoryType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => PoiInfoType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "PoiInfoType",
    :schema_qualified => false,
    :schema_element => [
      ["type", ["SOAP::SOAPInt", XSD::QName.new(nil, "type")]],
      ["value", ["SOAP::SOAPString", XSD::QName.new(nil, "value")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfPoiInfoType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfPoiInfoType",
    :schema_element => [
      ["item", ["PoiInfoType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => PoiType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "PoiType",
    :schema_qualified => false,
    :schema_element => [
      ["poiId", ["SOAP::SOAPInt", XSD::QName.new(nil, "poiId")]],
      ["categories", ["ArrayOfstring", XSD::QName.new(nil, "categories")]],
      ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "name")]],
      ["coordinates", ["CoordinatesType", XSD::QName.new(nil, "coordinates")]],
      ["geocode", ["GeocodeType", XSD::QName.new(nil, "geocode")]],
      ["address", ["SOAP::SOAPString", XSD::QName.new(nil, "address")]],
      ["postCode", ["SOAP::SOAPString", XSD::QName.new(nil, "postCode")]],
      ["place", ["SOAP::SOAPString", XSD::QName.new(nil, "place")]],
      ["country", ["SOAP::SOAPString", XSD::QName.new(nil, "country")]],
      ["info", ["ArrayOfPoiInfoType", XSD::QName.new(nil, "info")]],
      ["distance", ["SOAP::SOAPDouble", XSD::QName.new(nil, "distance")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfPoiType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfPoiType",
    :schema_element => [
      ["item", ["PoiType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => TmcIdType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TmcIdType",
    :schema_qualified => false,
    :schema_element => [
      ["cid", ["SOAP::SOAPInt", XSD::QName.new(nil, "cid")]],
      ["tabCd", ["SOAP::SOAPInt", XSD::QName.new(nil, "tabCd")]],
      ["lcd", ["SOAP::SOAPInt", XSD::QName.new(nil, "lcd")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfTmcIdType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfTmcIdType",
    :schema_element => [
      ["item", ["TmcIdType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => TmcRoadQueryType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TmcRoadQueryType",
    :schema_qualified => false,
    :schema_element => [
      ["cid", ["SOAP::SOAPInt", XSD::QName.new(nil, "cid")]],
      ["tabCd", ["SOAP::SOAPInt", XSD::QName.new(nil, "tabCd")]],
      ["roadLcds", ["ArrayOfint", XSD::QName.new(nil, "roadLcds")]],
      ["roadCodes", ["ArrayOfstring", XSD::QName.new(nil, "roadCodes")]],
      ["roadTypes", ["ArrayOfint", XSD::QName.new(nil, "roadTypes")]],
      ["roadName", ["SOAP::SOAPString", XSD::QName.new(nil, "roadName")]],
      ["status", ["SOAP::SOAPInt", XSD::QName.new(nil, "status")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfTmcRoadQueryType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfTmcRoadQueryType",
    :schema_element => [
      ["item", ["TmcRoadQueryType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => TmcRoadOptionsType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TmcRoadOptionsType",
    :schema_qualified => false,
    :schema_element => [
      ["provideBox", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "provideBox")]],
      ["nameDirections", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "nameDirections")]],
      ["listPoints", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "listPoints")]],
      ["minPointImportance", ["SOAP::SOAPInt", XSD::QName.new(nil, "minPointImportance")]]
    ]
  )

  LiteralRegistry.register(
    :class => TmcPointType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TmcPointType",
    :schema_qualified => false,
    :schema_element => [
      ["pointId", ["TmcIdType", XSD::QName.new(nil, "pointId")]],
      ["roadLcd", ["SOAP::SOAPInt", XSD::QName.new(nil, "roadLcd")]],
      ["segmentLcd", ["SOAP::SOAPInt", XSD::QName.new(nil, "segmentLcd")]],
      ["areaLcd", ["SOAP::SOAPInt", XSD::QName.new(nil, "areaLcd")]],
      ["coordinates", ["CoordinatesType", XSD::QName.new(nil, "coordinates")]],
      ["pointName", ["SOAP::SOAPString", XSD::QName.new(nil, "pointName")]],
      ["importance", ["SOAP::SOAPInt", XSD::QName.new(nil, "importance")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfTmcPointType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfTmcPointType",
    :schema_element => [
      ["item", ["TmcPointType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => TmcRoadType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TmcRoadType",
    :schema_qualified => false,
    :schema_element => [
      ["roadId", ["TmcIdType", XSD::QName.new(nil, "roadId")]],
      ["roadType", ["SOAP::SOAPInt", XSD::QName.new(nil, "roadType")]],
      ["roadCode", ["SOAP::SOAPString", XSD::QName.new(nil, "roadCode")]],
      ["roadName", ["SOAP::SOAPString", XSD::QName.new(nil, "roadName")]],
      ["box", ["BoxType", XSD::QName.new(nil, "box")]],
      ["status", ["SOAP::SOAPInt", XSD::QName.new(nil, "status")]],
      ["positiveDirName", ["SOAP::SOAPString", XSD::QName.new(nil, "positiveDirName")]],
      ["negativeDirName", ["SOAP::SOAPString", XSD::QName.new(nil, "negativeDirName")]],
      ["points", ["ArrayOfTmcPointType", XSD::QName.new(nil, "points")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfTmcRoadType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfTmcRoadType",
    :schema_element => [
      ["item", ["TmcRoadType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => TmcTrafficQueryType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TmcTrafficQueryType",
    :schema_qualified => false,
    :schema_element => [
      ["area", ["AreaType", XSD::QName.new(nil, "area")]],
      ["box", ["BoxType", XSD::QName.new(nil, "box")]],
      ["roadIds", ["ArrayOfTmcIdType", XSD::QName.new(nil, "roadIds")]],
      ["fromPoint", ["TmcIdType", XSD::QName.new(nil, "fromPoint")]],
      ["toPoint", ["TmcIdType", XSD::QName.new(nil, "toPoint")]],
      ["traffIds", ["ArrayOfstring", XSD::QName.new(nil, "traffIds")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfTmcTrafficQueryType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfTmcTrafficQueryType",
    :schema_element => [
      ["item", ["TmcTrafficQueryType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => TmcTrafficOptionsType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TmcTrafficOptionsType",
    :schema_qualified => false,
    :schema_element => [
      ["languageCode", ["SOAP::SOAPString", XSD::QName.new(nil, "languageCode")]],
      ["maxResults", ["SOAP::SOAPInt", XSD::QName.new(nil, "maxResults")]],
      ["orderBySeverity", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "orderBySeverity")]]
    ]
  )

  LiteralRegistry.register(
    :class => TrafficInfoType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TrafficInfoType",
    :schema_qualified => false,
    :schema_element => [
      ["id", ["SOAP::SOAPString", XSD::QName.new(nil, "id")]],
      ["cat", ["SOAP::SOAPInt", XSD::QName.new(nil, "cat")]],
      ["dob", ["SOAP::SOAPString", XSD::QName.new(nil, "dob")]],
      ["dob2", ["SOAP::SOAPString", XSD::QName.new(nil, "dob2")]],
      ["dateTime", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "dateTime")]],
      ["coordinates", ["CoordinatesType", XSD::QName.new(nil, "coordinates")]],
      ["distance", ["SOAP::SOAPDouble", XSD::QName.new(nil, "distance")]],
      ["road", ["TmcRoadType", XSD::QName.new(nil, "road")]],
      ["roadName", ["SOAP::SOAPString", XSD::QName.new(nil, "roadName")]],
      ["directionName", ["SOAP::SOAPString", XSD::QName.new(nil, "directionName")]],
      ["segmentName", ["SOAP::SOAPString", XSD::QName.new(nil, "segmentName")]],
      ["areaName", ["SOAP::SOAPString", XSD::QName.new(nil, "areaName")]],
      ["place", ["SOAP::SOAPString", XSD::QName.new(nil, "place")]],
      ["extraPlace", ["SOAP::SOAPString", XSD::QName.new(nil, "extraPlace")]],
      ["text", ["SOAP::SOAPString", XSD::QName.new(nil, "text")]],
      ["extraText", ["SOAP::SOAPString", XSD::QName.new(nil, "extraText")]],
      ["source", ["SOAP::SOAPString", XSD::QName.new(nil, "source")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfTrafficInfoType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfTrafficInfoType",
    :schema_element => [
      ["item", ["TrafficInfoType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => RouteParametersType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "RouteParametersType",
    :schema_qualified => false,
    :schema_element => [
      ["startingTime", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "startingTime")]],
      ["arrivalTime", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "arrivalTime")]],
      ["mode", ["SOAP::SOAPInt", XSD::QName.new(nil, "mode")]],
      ["optimization", ["SOAP::SOAPInt", XSD::QName.new(nil, "optimization")]],
      ["realTime", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "realTime")]],
      ["descriptionLevel", ["SOAP::SOAPInt", XSD::QName.new(nil, "descriptionLevel")]],
      ["descriptionLanguageCode", ["SOAP::SOAPString", XSD::QName.new(nil, "descriptionLanguageCode")]],
      ["providePath", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "providePath")]],
      ["providePathPoints", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "providePathPoints")]]
    ]
  )

  LiteralRegistry.register(
    :class => RouteStepType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "RouteStepType",
    :schema_qualified => false,
    :schema_element => [
      ["time", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "time")]],
      ["duration", ["SOAP::SOAPInt", XSD::QName.new(nil, "duration")]],
      ["distance", ["SOAP::SOAPDouble", XSD::QName.new(nil, "distance")]],
      ["action", ["SOAP::SOAPInt", XSD::QName.new(nil, "action")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(nil, "description")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfRouteStepType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfRouteStepType",
    :schema_element => [
      ["item", ["RouteStepType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => RouteSegmentType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "RouteSegmentType",
    :schema_qualified => false,
    :schema_element => [
      ["origin", ["GeocodeType", XSD::QName.new(nil, "origin")]],
      ["destination", ["GeocodeType", XSD::QName.new(nil, "destination")]],
      ["startingTime", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "startingTime")]],
      ["duration", ["SOAP::SOAPInt", XSD::QName.new(nil, "duration")]],
      ["distance", ["SOAP::SOAPDouble", XSD::QName.new(nil, "distance")]],
      ["vehicle", ["SOAP::SOAPInt", XSD::QName.new(nil, "vehicle")]],
      ["steps", ["ArrayOfRouteStepType", XSD::QName.new(nil, "steps")]],
      ["path", ["SOAP::SOAPString", XSD::QName.new(nil, "path")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfRouteSegmentType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfRouteSegmentType",
    :schema_element => [
      ["item", ["RouteSegmentType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => RoutePartType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "RoutePartType",
    :schema_qualified => false,
    :schema_element => [
      ["origin", ["GeocodeType", XSD::QName.new(nil, "origin")]],
      ["destination", ["GeocodeType", XSD::QName.new(nil, "destination")]],
      ["startingTime", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "startingTime")]],
      ["duration", ["SOAP::SOAPInt", XSD::QName.new(nil, "duration")]],
      ["distance", ["SOAP::SOAPDouble", XSD::QName.new(nil, "distance")]],
      ["segments", ["ArrayOfRouteSegmentType", XSD::QName.new(nil, "segments")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfRoutePartType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfRoutePartType",
    :schema_element => [
      ["item", ["RoutePartType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => RouteType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "RouteType",
    :schema_qualified => false,
    :schema_element => [
      ["routeId", ["SOAP::SOAPString", XSD::QName.new(nil, "routeId")]],
      ["origin", ["GeocodeType", XSD::QName.new(nil, "origin")]],
      ["destination", ["GeocodeType", XSD::QName.new(nil, "destination")]],
      ["startingTime", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "startingTime")]],
      ["duration", ["SOAP::SOAPInt", XSD::QName.new(nil, "duration")]],
      ["distance", ["SOAP::SOAPDouble", XSD::QName.new(nil, "distance")]],
      ["parts", ["ArrayOfRoutePartType", XSD::QName.new(nil, "parts")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfRouteType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfRouteType",
    :schema_element => [
      ["item", ["RouteType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => ImagePointType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ImagePointType",
    :schema_qualified => false,
    :schema_element => [
      ["x", ["SOAP::SOAPInt", XSD::QName.new(nil, "x")]],
      ["y", ["SOAP::SOAPInt", XSD::QName.new(nil, "y")]]
    ]
  )

  LiteralRegistry.register(
    :class => ImageSizeType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ImageSizeType",
    :schema_qualified => false,
    :schema_element => [
      ["width", ["SOAP::SOAPInt", XSD::QName.new(nil, "width")]],
      ["height", ["SOAP::SOAPInt", XSD::QName.new(nil, "height")]]
    ]
  )

  LiteralRegistry.register(
    :class => MapIconType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "MapIconType",
    :schema_qualified => false,
    :schema_element => [
      ["iconId", ["SOAP::SOAPString", XSD::QName.new(nil, "iconId")]],
      ["iconType", ["SOAP::SOAPString", XSD::QName.new(nil, "iconType")]],
      ["description", ["SOAP::SOAPString", XSD::QName.new(nil, "description")]],
      ["dimmed", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "dimmed")]],
      ["minimize", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "minimize")]],
      ["coordinates", ["CoordinatesType", XSD::QName.new(nil, "coordinates")]],
      ["point", ["ImagePointType", XSD::QName.new(nil, "point")]]
    ]
  )

  LiteralRegistry.register(
    :class => ArrayOfMapIconType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ArrayOfMapIconType",
    :schema_element => [
      ["item", ["MapIconType[]", XSD::QName.new(nil, "item")]]
    ]
  )

  LiteralRegistry.register(
    :class => MapOptionsType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "MapOptionsType",
    :schema_qualified => false,
    :schema_element => [
      ["format", ["SOAP::SOAPString", XSD::QName.new(nil, "format")]],
      ["showTrafficEvents", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "showTrafficEvents")]],
      ["trafficIconPrefix", ["SOAP::SOAPString", XSD::QName.new(nil, "trafficIconPrefix")]],
      ["trafficIconsDimmed", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "trafficIconsDimmed")]],
      ["roadId", ["TmcIdType", XSD::QName.new(nil, "roadId")]],
      ["routeId", ["SOAP::SOAPString", XSD::QName.new(nil, "routeId")]],
      ["poiIds", ["ArrayOfint", XSD::QName.new(nil, "poiIds")]],
      ["trafficInfoIds", ["ArrayOfstring", XSD::QName.new(nil, "trafficInfoIds")]],
      ["icons", ["ArrayOfMapIconType", XSD::QName.new(nil, "icons")]],
      ["routeIds", ["ArrayOfstring", XSD::QName.new(nil, "routeIds")]],
      ["showBasicPois", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "showBasicPois")]]
    ]
  )

  LiteralRegistry.register(
    :class => MapType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "MapType",
    :schema_qualified => false,
    :schema_element => [
      ["imageSize", ["ImageSizeType", XSD::QName.new(nil, "imageSize")]],
      ["box", ["BoxType", XSD::QName.new(nil, "box")]],
      ["width", ["SOAP::SOAPDouble", XSD::QName.new(nil, "width")]],
      ["height", ["SOAP::SOAPDouble", XSD::QName.new(nil, "height")]],
      ["imageUrl", ["SOAP::SOAPString", XSD::QName.new(nil, "imageUrl")]],
      ["icons", ["ArrayOfMapIconType", XSD::QName.new(nil, "icons")]]
    ]
  )

  LiteralRegistry.register(
    :class => ModeType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "ModeType"
  )

  LiteralRegistry.register(
    :class => VehicleType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "VehicleType"
  )

  LiteralRegistry.register(
    :class => OptimizationType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "OptimizationType"
  )

  LiteralRegistry.register(
    :class => DescriptionLevelType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "DescriptionLevelType"
  )

  LiteralRegistry.register(
    :class => StepActionType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "StepActionType"
  )

  LiteralRegistry.register(
    :class => TmcRoadTypeType,
    :schema_ns => "urn:mms_MizGIS",
    :schema_type => "TmcRoadTypeType"
  )
end
