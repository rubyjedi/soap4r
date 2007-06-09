#!/usr/bin/env ruby
require 'mms_MizGISDriver.rb'

endpoint_url = ARGV.shift
obj = Mms_MizGISPortType.new(endpoint_url)

# run ruby with -d to see SOAP wiredumps.
obj.wiredump_dev = STDERR if $DEBUG

# SYNOPSIS
#   getVersion
#
# ARGS
#   N/A
#
# RETURNS
#   name            C_String - {http://www.w3.org/2001/XMLSchema}string
#   version         C_String - {http://www.w3.org/2001/XMLSchema}string
#   date            C_String - {http://www.w3.org/2001/XMLSchema}string
#   cartographyVersion C_String - {http://www.w3.org/2001/XMLSchema}string
#   poiCartographyVersion C_String - {http://www.w3.org/2001/XMLSchema}string
#

puts obj.getVersion

# SYNOPSIS
#   getAvailableCountries
#
# ARGS
#   N/A
#
# RETURNS
#   countries       ArrayOfstring - {urn:mms_MizGIS}ArrayOfstring
#

puts obj.getAvailableCountries

# SYNOPSIS
#   findAddress(addressSearch, maxResults, onlyMunicipalities)
#
# ARGS
#   addressSearch   AddressSearchType - {urn:mms_MizGIS}AddressSearchType
#   maxResults      Int - {http://www.w3.org/2001/XMLSchema}int
#   onlyMunicipalities Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   addresses       ArrayOfAddressType - {urn:mms_MizGIS}ArrayOfAddressType
#
addressSearch = maxResults = onlyMunicipalities = nil
puts obj.findAddress(addressSearch, maxResults, onlyMunicipalities)

# SYNOPSIS
#   getAddressFromGeocode(geocode, languageCode)
#
# ARGS
#   geocode         GeocodeType - {urn:mms_MizGIS}GeocodeType
#   languageCode    C_String - {http://www.w3.org/2001/XMLSchema}string
#
# RETURNS
#   address         AddressType - {urn:mms_MizGIS}AddressType
#
geocode = languageCode = nil
puts obj.getAddressFromGeocode(geocode, languageCode)

# SYNOPSIS
#   findGeocodeFromCoordinates(coordinates, vehicle)
#
# ARGS
#   coordinates     CoordinatesType - {urn:mms_MizGIS}CoordinatesType
#   vehicle         Int - {http://www.w3.org/2001/XMLSchema}int
#
# RETURNS
#   found           Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#   geocode         GeocodeType - {urn:mms_MizGIS}GeocodeType
#   distance        Double - {http://www.w3.org/2001/XMLSchema}double
#
coordinates = vehicle = nil
puts obj.findGeocodeFromCoordinates(coordinates, vehicle)

# SYNOPSIS
#   findAddressFromCoordinates(coordinates, vehicle, languageCode)
#
# ARGS
#   coordinates     CoordinatesType - {urn:mms_MizGIS}CoordinatesType
#   vehicle         Int - {http://www.w3.org/2001/XMLSchema}int
#   languageCode    C_String - {http://www.w3.org/2001/XMLSchema}string
#
# RETURNS
#   found           Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#   address         AddressType - {urn:mms_MizGIS}AddressType
#   distance        Double - {http://www.w3.org/2001/XMLSchema}double
#
coordinates = vehicle = languageCode = nil
puts obj.findAddressFromCoordinates(coordinates, vehicle, languageCode)

# SYNOPSIS
#   getListOfPoiMacrocategories(languageCode)
#
# ARGS
#   languageCode    C_String - {http://www.w3.org/2001/XMLSchema}string
#
# RETURNS
#   macrocategories ArrayOfPoiMacrocategoryType - {urn:mms_MizGIS}ArrayOfPoiMacrocategoryType
#
languageCode = nil
puts obj.getListOfPoiMacrocategories(languageCode)

# SYNOPSIS
#   getListOfPoiCategories(languageCode, onlyPopulated)
#
# ARGS
#   languageCode    C_String - {http://www.w3.org/2001/XMLSchema}string
#   onlyPopulated   Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   categories      ArrayOfPoiCategoryType - {urn:mms_MizGIS}ArrayOfPoiCategoryType
#
languageCode = onlyPopulated = nil
puts obj.getListOfPoiCategories(languageCode, onlyPopulated)

# SYNOPSIS
#   findPois(area, box, maxResults, macroCategoryIds, categoryIds, provideInfo)
#
# ARGS
#   area            AreaType - {urn:mms_MizGIS}AreaType
#   box             BoxType - {urn:mms_MizGIS}BoxType
#   maxResults      Int - {http://www.w3.org/2001/XMLSchema}int
#   macroCategoryIds ArrayOfstring - {urn:mms_MizGIS}ArrayOfstring
#   categoryIds     ArrayOfstring - {urn:mms_MizGIS}ArrayOfstring
#   provideInfo     Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   pois            ArrayOfPoiType - {urn:mms_MizGIS}ArrayOfPoiType
#
area = box = maxResults = macroCategoryIds = categoryIds = provideInfo = nil
puts obj.findPois(area, box, maxResults, macroCategoryIds, categoryIds, provideInfo)

# SYNOPSIS
#   getPoiInfo(poiIds, provideInfo)
#
# ARGS
#   poiIds          ArrayOfint - {urn:mms_MizGIS}ArrayOfint
#   provideInfo     Boolean - {http://www.w3.org/2001/XMLSchema}boolean
#
# RETURNS
#   pois            ArrayOfPoiType - {urn:mms_MizGIS}ArrayOfPoiType
#
poiIds = provideInfo = nil
puts obj.getPoiInfo(poiIds, provideInfo)

# SYNOPSIS
#   getListOfRoads(roadQueries, roadOptions)
#
# ARGS
#   roadQueries     ArrayOfTmcRoadQueryType - {urn:mms_MizGIS}ArrayOfTmcRoadQueryType
#   roadOptions     TmcRoadOptionsType - {urn:mms_MizGIS}TmcRoadOptionsType
#
# RETURNS
#   roads           ArrayOfTmcRoadType - {urn:mms_MizGIS}ArrayOfTmcRoadType
#
roadQueries = roadOptions = nil
puts obj.getListOfRoads(roadQueries, roadOptions)

# SYNOPSIS
#   getTrafficInfo(trafficQuery, trafficOptions)
#
# ARGS
#   trafficQuery    TmcTrafficQueryType - {urn:mms_MizGIS}TmcTrafficQueryType
#   trafficOptions  TmcTrafficOptionsType - {urn:mms_MizGIS}TmcTrafficOptionsType
#
# RETURNS
#   info            ArrayOfTrafficInfoType - {urn:mms_MizGIS}ArrayOfTrafficInfoType
#
trafficQuery = trafficOptions = nil
puts obj.getTrafficInfo(trafficQuery, trafficOptions)

# SYNOPSIS
#   getTrafficStatus(areas)
#
# ARGS
#   areas           ArrayOfAreaType - {urn:mms_MizGIS}ArrayOfAreaType
#
# RETURNS
#   status          ArrayOfint - {urn:mms_MizGIS}ArrayOfint
#
areas = nil
puts obj.getTrafficStatus(areas)

# SYNOPSIS
#   findRoute(places, params)
#
# ARGS
#   places          ArrayOfGeocodeType - {urn:mms_MizGIS}ArrayOfGeocodeType
#   params          RouteParametersType - {urn:mms_MizGIS}RouteParametersType
#
# RETURNS
#   route           RouteType - {urn:mms_MizGIS}RouteType
#
places = params = nil
puts obj.findRoute(places, params)

# SYNOPSIS
#   getMap(imageSize, box, options)
#
# ARGS
#   imageSize       ImageSizeType - {urn:mms_MizGIS}ImageSizeType
#   box             BoxType - {urn:mms_MizGIS}BoxType
#   options         MapOptionsType - {urn:mms_MizGIS}MapOptionsType
#
# RETURNS
#   map             MapType - {urn:mms_MizGIS}MapType
#
imageSize = box = options = nil
puts obj.getMap(imageSize, box, options)

# SYNOPSIS
#   getMapAround(imageSize, center, radius, options)
#
# ARGS
#   imageSize       ImageSizeType - {urn:mms_MizGIS}ImageSizeType
#   center          CoordinatesType - {urn:mms_MizGIS}CoordinatesType
#   radius          Double - {http://www.w3.org/2001/XMLSchema}double
#   options         MapOptionsType - {urn:mms_MizGIS}MapOptionsType
#
# RETURNS
#   map             MapType - {urn:mms_MizGIS}MapType
#
imageSize = center = radius = options = nil
puts obj.getMapAround(imageSize, center, radius, options)


