require 'xsd/qname'

# {urn:mms_MizGIS}ArrayOfint
class ArrayOfint < ::Array
end

# {urn:mms_MizGIS}ArrayOfstring
class ArrayOfstring < ::Array
end

# {urn:mms_MizGIS}AccessCredentialsType
class AccessCredentialsType
  attr_accessor :name
  attr_accessor :password

  def initialize(name = nil, password = nil)
    @name = name
    @password = password
  end
end

# {urn:mms_MizGIS}AddressSearchType
class AddressSearchType
  attr_accessor :languageCode
  attr_accessor :countryCode
  attr_accessor :place
  attr_accessor :street
  attr_accessor :houseNumber

  def initialize(languageCode = nil, countryCode = nil, place = nil, street = nil, houseNumber = nil)
    @languageCode = languageCode
    @countryCode = countryCode
    @place = place
    @street = street
    @houseNumber = houseNumber
  end
end

# {urn:mms_MizGIS}CoordinatesType
class CoordinatesType
  attr_accessor :longitude
  attr_accessor :latitude

  def initialize(longitude = nil, latitude = nil)
    @longitude = longitude
    @latitude = latitude
  end
end

# {urn:mms_MizGIS}BoxType
class BoxType
  attr_accessor :bottomLeft
  attr_accessor :topRight

  def initialize(bottomLeft = nil, topRight = nil)
    @bottomLeft = bottomLeft
    @topRight = topRight
  end
end

# {urn:mms_MizGIS}AreaType
class AreaType
  attr_accessor :center
  attr_accessor :radius

  def initialize(center = nil, radius = nil)
    @center = center
    @radius = radius
  end
end

# {urn:mms_MizGIS}ArrayOfAreaType
class ArrayOfAreaType < ::Array
end

# {urn:mms_MizGIS}GeocodeType
class GeocodeType
  attr_accessor :areaId
  attr_accessor :streetNameId
  attr_accessor :lineId
  attr_accessor :position
  attr_accessor :direction
  attr_accessor :highway

  def initialize(areaId = nil, streetNameId = nil, lineId = nil, position = nil, direction = nil, highway = nil)
    @areaId = areaId
    @streetNameId = streetNameId
    @lineId = lineId
    @position = position
    @direction = direction
    @highway = highway
  end
end

# {urn:mms_MizGIS}ArrayOfGeocodeType
class ArrayOfGeocodeType < ::Array
end

# {urn:mms_MizGIS}AddressType
class AddressType
  attr_accessor :countryCode
  attr_accessor :languageCode
  attr_accessor :countryName
  attr_accessor :region
  attr_accessor :municipality
  attr_accessor :languageCodeDistrict
  attr_accessor :district
  attr_accessor :languageCodeStreetName
  attr_accessor :streetName
  attr_accessor :houseNumber
  attr_accessor :postCode
  attr_accessor :coordinates
  attr_accessor :geocode

  def initialize(countryCode = nil, languageCode = nil, countryName = nil, region = nil, municipality = nil, languageCodeDistrict = nil, district = nil, languageCodeStreetName = nil, streetName = nil, houseNumber = nil, postCode = nil, coordinates = nil, geocode = nil)
    @countryCode = countryCode
    @languageCode = languageCode
    @countryName = countryName
    @region = region
    @municipality = municipality
    @languageCodeDistrict = languageCodeDistrict
    @district = district
    @languageCodeStreetName = languageCodeStreetName
    @streetName = streetName
    @houseNumber = houseNumber
    @postCode = postCode
    @coordinates = coordinates
    @geocode = geocode
  end
end

# {urn:mms_MizGIS}ArrayOfAddressType
class ArrayOfAddressType < ::Array
end

# {urn:mms_MizGIS}PoiMacrocategoryType
class PoiMacrocategoryType
  attr_accessor :macrocategoryId
  attr_accessor :description

  def initialize(macrocategoryId = nil, description = nil)
    @macrocategoryId = macrocategoryId
    @description = description
  end
end

# {urn:mms_MizGIS}ArrayOfPoiMacrocategoryType
class ArrayOfPoiMacrocategoryType < ::Array
end

# {urn:mms_MizGIS}PoiCategoryType
class PoiCategoryType
  attr_accessor :categoryId
  attr_accessor :macrocategoryId
  attr_accessor :description
  attr_accessor :populated

  def initialize(categoryId = nil, macrocategoryId = nil, description = nil, populated = nil)
    @categoryId = categoryId
    @macrocategoryId = macrocategoryId
    @description = description
    @populated = populated
  end
end

# {urn:mms_MizGIS}ArrayOfPoiCategoryType
class ArrayOfPoiCategoryType < ::Array
end

# {urn:mms_MizGIS}PoiInfoType
class PoiInfoType
  attr_accessor :type
  attr_accessor :value

  def initialize(type = nil, value = nil)
    @type = type
    @value = value
  end
end

# {urn:mms_MizGIS}ArrayOfPoiInfoType
class ArrayOfPoiInfoType < ::Array
end

# {urn:mms_MizGIS}PoiType
class PoiType
  attr_accessor :poiId
  attr_accessor :categories
  attr_accessor :name
  attr_accessor :coordinates
  attr_accessor :geocode
  attr_accessor :address
  attr_accessor :postCode
  attr_accessor :place
  attr_accessor :country
  attr_accessor :info
  attr_accessor :distance

  def initialize(poiId = nil, categories = nil, name = nil, coordinates = nil, geocode = nil, address = nil, postCode = nil, place = nil, country = nil, info = nil, distance = nil)
    @poiId = poiId
    @categories = categories
    @name = name
    @coordinates = coordinates
    @geocode = geocode
    @address = address
    @postCode = postCode
    @place = place
    @country = country
    @info = info
    @distance = distance
  end
end

# {urn:mms_MizGIS}ArrayOfPoiType
class ArrayOfPoiType < ::Array
end

# {urn:mms_MizGIS}TmcIdType
class TmcIdType
  attr_accessor :cid
  attr_accessor :tabCd
  attr_accessor :lcd

  def initialize(cid = nil, tabCd = nil, lcd = nil)
    @cid = cid
    @tabCd = tabCd
    @lcd = lcd
  end
end

# {urn:mms_MizGIS}ArrayOfTmcIdType
class ArrayOfTmcIdType < ::Array
end

# {urn:mms_MizGIS}TmcRoadQueryType
class TmcRoadQueryType
  attr_accessor :cid
  attr_accessor :tabCd
  attr_accessor :roadLcds
  attr_accessor :roadCodes
  attr_accessor :roadTypes
  attr_accessor :roadName
  attr_accessor :status

  def initialize(cid = nil, tabCd = nil, roadLcds = nil, roadCodes = nil, roadTypes = nil, roadName = nil, status = nil)
    @cid = cid
    @tabCd = tabCd
    @roadLcds = roadLcds
    @roadCodes = roadCodes
    @roadTypes = roadTypes
    @roadName = roadName
    @status = status
  end
end

# {urn:mms_MizGIS}ArrayOfTmcRoadQueryType
class ArrayOfTmcRoadQueryType < ::Array
end

# {urn:mms_MizGIS}TmcRoadOptionsType
class TmcRoadOptionsType
  attr_accessor :provideBox
  attr_accessor :nameDirections
  attr_accessor :listPoints
  attr_accessor :minPointImportance

  def initialize(provideBox = nil, nameDirections = nil, listPoints = nil, minPointImportance = nil)
    @provideBox = provideBox
    @nameDirections = nameDirections
    @listPoints = listPoints
    @minPointImportance = minPointImportance
  end
end

# {urn:mms_MizGIS}TmcPointType
class TmcPointType
  attr_accessor :pointId
  attr_accessor :roadLcd
  attr_accessor :segmentLcd
  attr_accessor :areaLcd
  attr_accessor :coordinates
  attr_accessor :pointName
  attr_accessor :importance

  def initialize(pointId = nil, roadLcd = nil, segmentLcd = nil, areaLcd = nil, coordinates = nil, pointName = nil, importance = nil)
    @pointId = pointId
    @roadLcd = roadLcd
    @segmentLcd = segmentLcd
    @areaLcd = areaLcd
    @coordinates = coordinates
    @pointName = pointName
    @importance = importance
  end
end

# {urn:mms_MizGIS}ArrayOfTmcPointType
class ArrayOfTmcPointType < ::Array
end

# {urn:mms_MizGIS}TmcRoadType
class TmcRoadType
  attr_accessor :roadId
  attr_accessor :roadType
  attr_accessor :roadCode
  attr_accessor :roadName
  attr_accessor :box
  attr_accessor :status
  attr_accessor :positiveDirName
  attr_accessor :negativeDirName
  attr_accessor :points

  def initialize(roadId = nil, roadType = nil, roadCode = nil, roadName = nil, box = nil, status = nil, positiveDirName = nil, negativeDirName = nil, points = nil)
    @roadId = roadId
    @roadType = roadType
    @roadCode = roadCode
    @roadName = roadName
    @box = box
    @status = status
    @positiveDirName = positiveDirName
    @negativeDirName = negativeDirName
    @points = points
  end
end

# {urn:mms_MizGIS}ArrayOfTmcRoadType
class ArrayOfTmcRoadType < ::Array
end

# {urn:mms_MizGIS}TmcTrafficQueryType
class TmcTrafficQueryType
  attr_accessor :area
  attr_accessor :box
  attr_accessor :roadIds
  attr_accessor :fromPoint
  attr_accessor :toPoint
  attr_accessor :traffIds

  def initialize(area = nil, box = nil, roadIds = nil, fromPoint = nil, toPoint = nil, traffIds = nil)
    @area = area
    @box = box
    @roadIds = roadIds
    @fromPoint = fromPoint
    @toPoint = toPoint
    @traffIds = traffIds
  end
end

# {urn:mms_MizGIS}ArrayOfTmcTrafficQueryType
class ArrayOfTmcTrafficQueryType < ::Array
end

# {urn:mms_MizGIS}TmcTrafficOptionsType
class TmcTrafficOptionsType
  attr_accessor :languageCode
  attr_accessor :maxResults
  attr_accessor :orderBySeverity

  def initialize(languageCode = nil, maxResults = nil, orderBySeverity = nil)
    @languageCode = languageCode
    @maxResults = maxResults
    @orderBySeverity = orderBySeverity
  end
end

# {urn:mms_MizGIS}TrafficInfoType
class TrafficInfoType
  attr_accessor :id
  attr_accessor :cat
  attr_accessor :dob
  attr_accessor :dob2
  attr_accessor :dateTime
  attr_accessor :coordinates
  attr_accessor :distance
  attr_accessor :road
  attr_accessor :roadName
  attr_accessor :directionName
  attr_accessor :segmentName
  attr_accessor :areaName
  attr_accessor :place
  attr_accessor :extraPlace
  attr_accessor :text
  attr_accessor :extraText
  attr_accessor :source

  def initialize(id = nil, cat = nil, dob = nil, dob2 = nil, dateTime = nil, coordinates = nil, distance = nil, road = nil, roadName = nil, directionName = nil, segmentName = nil, areaName = nil, place = nil, extraPlace = nil, text = nil, extraText = nil, source = nil)
    @id = id
    @cat = cat
    @dob = dob
    @dob2 = dob2
    @dateTime = dateTime
    @coordinates = coordinates
    @distance = distance
    @road = road
    @roadName = roadName
    @directionName = directionName
    @segmentName = segmentName
    @areaName = areaName
    @place = place
    @extraPlace = extraPlace
    @text = text
    @extraText = extraText
    @source = source
  end
end

# {urn:mms_MizGIS}ArrayOfTrafficInfoType
class ArrayOfTrafficInfoType < ::Array
end

# {urn:mms_MizGIS}RouteParametersType
class RouteParametersType
  attr_accessor :startingTime
  attr_accessor :arrivalTime
  attr_accessor :mode
  attr_accessor :optimization
  attr_accessor :realTime
  attr_accessor :descriptionLevel
  attr_accessor :descriptionLanguageCode
  attr_accessor :providePath
  attr_accessor :providePathPoints

  def initialize(startingTime = nil, arrivalTime = nil, mode = nil, optimization = nil, realTime = nil, descriptionLevel = nil, descriptionLanguageCode = nil, providePath = nil, providePathPoints = nil)
    @startingTime = startingTime
    @arrivalTime = arrivalTime
    @mode = mode
    @optimization = optimization
    @realTime = realTime
    @descriptionLevel = descriptionLevel
    @descriptionLanguageCode = descriptionLanguageCode
    @providePath = providePath
    @providePathPoints = providePathPoints
  end
end

# {urn:mms_MizGIS}RouteStepType
class RouteStepType
  attr_accessor :time
  attr_accessor :duration
  attr_accessor :distance
  attr_accessor :action
  attr_accessor :description

  def initialize(time = nil, duration = nil, distance = nil, action = nil, description = nil)
    @time = time
    @duration = duration
    @distance = distance
    @action = action
    @description = description
  end
end

# {urn:mms_MizGIS}ArrayOfRouteStepType
class ArrayOfRouteStepType < ::Array
end

# {urn:mms_MizGIS}RouteSegmentType
class RouteSegmentType
  attr_accessor :origin
  attr_accessor :destination
  attr_accessor :startingTime
  attr_accessor :duration
  attr_accessor :distance
  attr_accessor :vehicle
  attr_accessor :steps
  attr_accessor :path

  def initialize(origin = nil, destination = nil, startingTime = nil, duration = nil, distance = nil, vehicle = nil, steps = nil, path = nil)
    @origin = origin
    @destination = destination
    @startingTime = startingTime
    @duration = duration
    @distance = distance
    @vehicle = vehicle
    @steps = steps
    @path = path
  end
end

# {urn:mms_MizGIS}ArrayOfRouteSegmentType
class ArrayOfRouteSegmentType < ::Array
end

# {urn:mms_MizGIS}RoutePartType
class RoutePartType
  attr_accessor :origin
  attr_accessor :destination
  attr_accessor :startingTime
  attr_accessor :duration
  attr_accessor :distance
  attr_accessor :segments

  def initialize(origin = nil, destination = nil, startingTime = nil, duration = nil, distance = nil, segments = nil)
    @origin = origin
    @destination = destination
    @startingTime = startingTime
    @duration = duration
    @distance = distance
    @segments = segments
  end
end

# {urn:mms_MizGIS}ArrayOfRoutePartType
class ArrayOfRoutePartType < ::Array
end

# {urn:mms_MizGIS}RouteType
class RouteType
  attr_accessor :routeId
  attr_accessor :origin
  attr_accessor :destination
  attr_accessor :startingTime
  attr_accessor :duration
  attr_accessor :distance
  attr_accessor :parts

  def initialize(routeId = nil, origin = nil, destination = nil, startingTime = nil, duration = nil, distance = nil, parts = nil)
    @routeId = routeId
    @origin = origin
    @destination = destination
    @startingTime = startingTime
    @duration = duration
    @distance = distance
    @parts = parts
  end
end

# {urn:mms_MizGIS}ArrayOfRouteType
class ArrayOfRouteType < ::Array
end

# {urn:mms_MizGIS}ImagePointType
class ImagePointType
  attr_accessor :x
  attr_accessor :y

  def initialize(x = nil, y = nil)
    @x = x
    @y = y
  end
end

# {urn:mms_MizGIS}ImageSizeType
class ImageSizeType
  attr_accessor :width
  attr_accessor :height

  def initialize(width = nil, height = nil)
    @width = width
    @height = height
  end
end

# {urn:mms_MizGIS}MapIconType
class MapIconType
  attr_accessor :iconId
  attr_accessor :iconType
  attr_accessor :description
  attr_accessor :dimmed
  attr_accessor :minimize
  attr_accessor :coordinates
  attr_accessor :point

  def initialize(iconId = nil, iconType = nil, description = nil, dimmed = nil, minimize = nil, coordinates = nil, point = nil)
    @iconId = iconId
    @iconType = iconType
    @description = description
    @dimmed = dimmed
    @minimize = minimize
    @coordinates = coordinates
    @point = point
  end
end

# {urn:mms_MizGIS}ArrayOfMapIconType
class ArrayOfMapIconType < ::Array
end

# {urn:mms_MizGIS}MapOptionsType
class MapOptionsType
  attr_accessor :format
  attr_accessor :showTrafficEvents
  attr_accessor :trafficIconPrefix
  attr_accessor :trafficIconsDimmed
  attr_accessor :roadId
  attr_accessor :routeId
  attr_accessor :poiIds
  attr_accessor :trafficInfoIds
  attr_accessor :icons
  attr_accessor :routeIds
  attr_accessor :showBasicPois

  def initialize(format = nil, showTrafficEvents = nil, trafficIconPrefix = nil, trafficIconsDimmed = nil, roadId = nil, routeId = nil, poiIds = nil, trafficInfoIds = nil, icons = nil, routeIds = nil, showBasicPois = nil)
    @format = format
    @showTrafficEvents = showTrafficEvents
    @trafficIconPrefix = trafficIconPrefix
    @trafficIconsDimmed = trafficIconsDimmed
    @roadId = roadId
    @routeId = routeId
    @poiIds = poiIds
    @trafficInfoIds = trafficInfoIds
    @icons = icons
    @routeIds = routeIds
    @showBasicPois = showBasicPois
  end
end

# {urn:mms_MizGIS}MapType
class MapType
  attr_accessor :imageSize
  attr_accessor :box
  attr_accessor :width
  attr_accessor :height
  attr_accessor :imageUrl
  attr_accessor :icons

  def initialize(imageSize = nil, box = nil, width = nil, height = nil, imageUrl = nil, icons = nil)
    @imageSize = imageSize
    @box = box
    @width = width
    @height = height
    @imageUrl = imageUrl
    @icons = icons
  end
end

# {urn:mms_MizGIS}ModeType
class ModeType < ::String
  RmCAR = ModeType.new("rmCAR")
  RmONFOOT = ModeType.new("rmONFOOT")
  RmPT = ModeType.new("rmPT")
end

# {urn:mms_MizGIS}VehicleType
class VehicleType < ::String
  VtAIRPLANE = VehicleType.new("vtAIRPLANE")
  VtANY = VehicleType.new("vtANY")
  VtBICYCLE = VehicleType.new("vtBICYCLE")
  VtBUS = VehicleType.new("vtBUS")
  VtCAR = VehicleType.new("vtCAR")
  VtDELIVERYTRUCK = VehicleType.new("vtDELIVERY-TRUCK")
  VtEMERGENCYVEHICLE = VehicleType.new("vtEMERGENCY-VEHICLE")
  VtMETRO = VehicleType.new("vtMETRO")
  VtNULL = VehicleType.new("vtNULL")
  VtPEDESTRIAN = VehicleType.new("vtPEDESTRIAN")
  VtPUBLICBUS = VehicleType.new("vtPUBLIC-BUS")
  VtRESIDENTIALVEHICLE = VehicleType.new("vtRESIDENTIAL-VEHICLE")
  VtTAXI = VehicleType.new("vtTAXI")
  VtTRAIN = VehicleType.new("vtTRAIN")
  VtTRAM = VehicleType.new("vtTRAM")
end

# {urn:mms_MizGIS}OptimizationType
class OptimizationType < ::String
  OtCHEAPEST = OptimizationType.new("otCHEAPEST")
  OtFASTEST = OptimizationType.new("otFASTEST")
  OtSHORTEST = OptimizationType.new("otSHORTEST")
end

# {urn:mms_MizGIS}DescriptionLevelType
class DescriptionLevelType < ::String
  DlBRIEF = DescriptionLevelType.new("dlBRIEF")
  DlNONE = DescriptionLevelType.new("dlNONE")
  DlNORMAL = DescriptionLevelType.new("dlNORMAL")
end

# {urn:mms_MizGIS}StepActionType
class StepActionType < ::String
  SaARRIVE = StepActionType.new("saARRIVE")
  SaCHANGECOUNTRY = StepActionType.new("saCHANGECOUNTRY")
  SaCONTINUE = StepActionType.new("saCONTINUE")
  SaFERRY = StepActionType.new("saFERRY")
  SaMOTORWAYBEGIN = StepActionType.new("saMOTORWAYBEGIN")
  SaMOTORWAYCHANGE = StepActionType.new("saMOTORWAYCHANGE")
  SaMOTORWAYCONTINUE = StepActionType.new("saMOTORWAYCONTINUE")
  SaMOTORWAYEND = StepActionType.new("saMOTORWAYEND")
  SaMOTORWAYENTER = StepActionType.new("saMOTORWAYENTER")
  SaMOTORWAYLEAVE = StepActionType.new("saMOTORWAYLEAVE")
  SaNULL = StepActionType.new("saNULL")
  SaONFOOTARRIVE = StepActionType.new("saONFOOTARRIVE")
  SaONFOOTSTART = StepActionType.new("saONFOOTSTART")
  SaPTTRAVEL = StepActionType.new("saPTTRAVEL")
  SaPTWAIT = StepActionType.new("saPTWAIT")
  SaSTART = StepActionType.new("saSTART")
  SaSTOP = StepActionType.new("saSTOP")
  SaTURNLEFT = StepActionType.new("saTURNLEFT")
  SaTURNRIGHT = StepActionType.new("saTURNRIGHT")
end

# {urn:mms_MizGIS}TmcRoadTypeType
class TmcRoadTypeType < ::String
  RtITAAUTOS = TmcRoadTypeType.new("rtITA-AUTOS")
  RtITADIR = TmcRoadTypeType.new("rtITA-DIR")
  RtITARACC = TmcRoadTypeType.new("rtITA-RACC")
  RtITASGC = TmcRoadTypeType.new("rtITA-SGC")
  RtITASS = TmcRoadTypeType.new("rtITA-SS")
  RtITATANG = TmcRoadTypeType.new("rtITA-TANG")
  RtITATRAF = TmcRoadTypeType.new("rtITA-TRAF")
  RtNLDA = TmcRoadTypeType.new("rtNLD-A")
  RtNLDN = TmcRoadTypeType.new("rtNLD-N")
  RtUNDEF = TmcRoadTypeType.new("rtUNDEF")
end
