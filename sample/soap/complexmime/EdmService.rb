require 'xsd/qname'

# {urn:EDD:Edm}LocationInfo
class LocationInfo
  @@schema_type = "LocationInfo"
  @@schema_ns = "urn:EDD:Edm"
  @@schema_element = [["bottomLeft", ["Coordinates", XSD::QName.new(nil, "bottomLeft")]], ["topRight", ["Coordinates", XSD::QName.new(nil, "topRight")]], ["startTime", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "startTime")]], ["endTime", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "endTime")]]]

  attr_accessor :bottomLeft
  attr_accessor :topRight
  attr_accessor :startTime
  attr_accessor :endTime

  def initialize(bottomLeft = nil, topRight = nil, startTime = nil, endTime = nil)
    @bottomLeft = bottomLeft
    @topRight = topRight
    @startTime = startTime
    @endTime = endTime
  end
end

# {urn:EDD:Edm}MapInfo
class MapInfo
  @@schema_type = "MapInfo"
  @@schema_ns = "urn:EDD:Edm"
  @@schema_element = [["mapArea", ["MapArea", XSD::QName.new(nil, "mapArea")]], ["mapTime", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "mapTime")]], ["mapOptions", ["MapOptions", XSD::QName.new(nil, "mapOptions")]]]

  attr_accessor :mapArea
  attr_accessor :mapTime
  attr_accessor :mapOptions

  def initialize(mapArea = nil, mapTime = nil, mapOptions = nil)
    @mapArea = mapArea
    @mapTime = mapTime
    @mapOptions = mapOptions
  end
end

# {urn:EDD}ObjectIdentification
class ObjectIdentification
  @@schema_type = "ObjectIdentification"
  @@schema_ns = "urn:EDD"
  @@schema_element = [["mmsiNumber", ["SOAP::SOAPString", XSD::QName.new(nil, "mmsiNumber")]], ["weight", ["SOAP::SOAPLong", XSD::QName.new(nil, "weight")]], ["length", ["SOAP::SOAPLong", XSD::QName.new(nil, "length")]], ["width", ["SOAP::SOAPLong", XSD::QName.new(nil, "width")]], ["draught", ["SOAP::SOAPLong", XSD::QName.new(nil, "draught")]]]

  attr_accessor :mmsiNumber
  attr_accessor :weight
  attr_accessor :length
  attr_accessor :width
  attr_accessor :draught

  def initialize(mmsiNumber = nil, weight = nil, length = nil, width = nil, draught = nil)
    @mmsiNumber = mmsiNumber
    @weight = weight
    @length = length
    @width = width
    @draught = draught
  end
end

# {urn:EDD}Coordinates
class Coordinates
  @@schema_type = "Coordinates"
  @@schema_ns = "urn:EDD"
  @@schema_element = [["wgs84Latitude", ["SOAP::SOAPDouble", XSD::QName.new(nil, "wgs84Latitude")]], ["wgs84Longitude", ["SOAP::SOAPDouble", XSD::QName.new(nil, "wgs84Longitude")]]]

  attr_accessor :wgs84Latitude
  attr_accessor :wgs84Longitude

  def initialize(wgs84Latitude = nil, wgs84Longitude = nil)
    @wgs84Latitude = wgs84Latitude
    @wgs84Longitude = wgs84Longitude
  end
end

# {urn:EDD}LastKnownPosition
class LastKnownPosition
  @@schema_type = "LastKnownPosition"
  @@schema_ns = "urn:EDD"
  @@schema_element = [["location", ["Coordinates", XSD::QName.new(nil, "location")]], ["timestamp", ["SOAP::SOAPDateTime", XSD::QName.new(nil, "timestamp")]]]

  attr_accessor :location
  attr_accessor :timestamp

  def initialize(location = nil, timestamp = nil)
    @location = location
    @timestamp = timestamp
  end
end

# {urn:EDD}MapArea
class MapArea
  @@schema_type = "MapArea"
  @@schema_ns = "urn:EDD"
  @@schema_element = [["bottomLeft", ["Coordinates", XSD::QName.new(nil, "bottomLeft")]], ["topRight", ["Coordinates", XSD::QName.new(nil, "topRight")]], ["width", ["SOAP::SOAPLong", XSD::QName.new(nil, "width")]], ["height", ["SOAP::SOAPLong", XSD::QName.new(nil, "height")]]]

  attr_accessor :bottomLeft
  attr_accessor :topRight
  attr_accessor :width
  attr_accessor :height

  def initialize(bottomLeft = nil, topRight = nil, width = nil, height = nil)
    @bottomLeft = bottomLeft
    @topRight = topRight
    @width = width
    @height = height
  end
end

# {urn:EDD}MapOptions
class MapOptions
  @@schema_type = "MapOptions"
  @@schema_ns = "urn:EDD"
  @@schema_element = [["showCurrentData", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "showCurrentData")]], ["showWaveData", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "showWaveData")]], ["showWindData", ["SOAP::SOAPBoolean", XSD::QName.new(nil, "showWindData")]]]

  attr_accessor :showCurrentData
  attr_accessor :showWaveData
  attr_accessor :showWindData

  def initialize(showCurrentData = nil, showWaveData = nil, showWindData = nil)
    @showCurrentData = showCurrentData
    @showWaveData = showWaveData
    @showWindData = showWindData
  end
end
