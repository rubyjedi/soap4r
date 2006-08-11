require 'soap/rpc/driver'
require 'soap/attachment'
require 'EdmService'

# test script for the EDD service in ruby, to see if we can send and
# receive attachments.

# set up the server parameters
server = 'http://localhost:7000/'
driver = SOAP::RPC::Driver.new(server, 'urn:EDD:Edm')

# debugging?
driver.wiredump_dev = STDERR

# add methods
driver.add_method('MapInfo', 'mapArea', 'mapTime', 'mapOptions', 'driftPrediction')
driver.add_method('LocationInfo', 'bottomLeft', 'topRight', 'startTime', 'endTime')

# LocationInfo
bottomLeft = Coordinates.new
bottomLeft.wgs84Latitude = 0.12
bottomLeft.wgs84Longitude = 3.45

topRight = Coordinates.new
topRight.wgs84Latitude = 1.23
topRight.wgs84Longitude = 4.56

startTime = '2006-07-13T14:39:25.459Z'
endTime   = '2006-07-13T14:55:25.459Z'

result = driver.LocationInfo(bottomLeft, topRight, startTime, endTime)
puts("LocationInfo result: #{result}")

# MapInfo
mapArea = MapArea.new
mapArea.bottomLeft = Coordinates.new
mapArea.topRight = Coordinates.new
mapArea.bottomLeft.wgs84Latitude = 2.34
mapArea.bottomLeft.wgs84Longitude = 5.67
mapArea.topRight.wgs84Latitude = 3.45
mapArea.topRight.wgs84Longitude = 6.78
mapArea.width = 4.56
mapArea.height = 7.89

mapTime = SOAP::SOAPDateTime.new('2006-07-13T14:39:25.459Z')

mapOptions = MapOptions.new
mapOptions.showCurrentData = true
mapOptions.showWaveData = false
mapOptions.showWindData = true

driftPrediction = SOAP::Attachment.new(File.open('drift.cdf'))
driftPrediction.contenttype = "application/x-netcdf"

result = driver.MapInfo(mapArea, mapTime, mapOptions, driftPrediction)
puts("MapInfo result: #{result}")

