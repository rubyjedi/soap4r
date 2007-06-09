require 'soap/rpc/standaloneServer'
require 'soap/attachment'

# Ruby test class for the EDD project to see if we can receive and
# send attachments on the server side.

class SwAService

    def initialize
        puts("EDD SOAP service (ruby) initialized.")
    end
    
    def LocationInfo(bottomLeft, topRight, startTime, endTime)
		puts("bottomLeft->wgs84Latitude : '#{bottomLeft.wgs84Latitude}'")
		puts("bottomLeft->wgs84Longitude: '#{bottomLeft.wgs84Longitude}'")
		puts("topRight->wgs84Latitude   : '#{topRight.wgs84Latitude}'")
		puts("topRight->wgs84Longitude  : '#{topRight.wgs84Longitude}'")
		puts("startTime  : '#{startTime}'")
		puts("endTime    : '#{endTime}'")
		
		# COMPUTE NETCDF HERE!
		cdffilename = 'drift.cdf'
		
		file = SOAP::Attachment.new(File.open(cdffilename))
		file.contenttype = "application/x-netcdf"
        return file
    end
	
	def MapInfo(mapArea, mapTime, mapOptions, driftPrediction)
		
        puts("mapArea.topRight.wgs84Longitude : #{mapArea.topRight.wgs84Longitude}")
        puts("mapArea.topRight.wgs84Latitude  : #{mapArea.topRight.wgs84Latitude}")
        puts("mapArea.bottomLeft.wgs84Longitude  : #{mapArea.bottomLeft.wgs84Longitude}")
        puts("mapArea.bottomLeft.wgs84Latitude : #{mapArea.bottomLeft.wgs84Latitude}")
        puts("mapArea.width : #{mapArea.width}")
        puts("mapArea.height : #{mapArea.height}")
        puts("mapTime  : #{mapTime}")
        puts("mapOptions.showCurrentData : #{mapOptions.showCurrentData}")
        puts("mapOptions.showWaveData : #{mapOptions.showWaveData}")
        puts("mapOptions.showWindData : #{mapOptions.showWindData}")
		puts("Received file:")
		puts(driftPrediction.to_s)

		# COMPUTE PNG IMAGE HERE!
		imagefilename = 'plaatje.png'

		file = SOAP::Attachment.new(File.open(imagefilename))
		file.contenttype = "image/png"
		file.contentid = "out"
		file
	end
end

# setup server object
server = SOAP::RPC::StandaloneServer.new('SwAServer',
                                         'urn:EDD:Edm',
                                         '0.0.0.0', 7000)

# add attachment functionality
server.add_servant(SwAService.new)

# run until interrupted
trap(:INT) do
    server.shutdown
end

# go
server.start
