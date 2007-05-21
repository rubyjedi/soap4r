#!/usr/bin/env ruby
require 'defaultDriver.rb'

endpoint_url = ARGV.shift
obj = NdfdXMLPortType.new(endpoint_url)

# run ruby with -d to see SOAP wiredumps.
obj.wiredump_dev = STDERR if $DEBUG

# SYNOPSIS
#   NDFDgen(latitude, longitude, product, startTime, endTime, weatherParameters)
#
# ARGS
#   latitude        Decimal - {http://www.w3.org/2001/XMLSchema}decimal
#   longitude       Decimal - {http://www.w3.org/2001/XMLSchema}decimal
#   product         ProductType - {http://weather.gov/forecasts/xml/DWMLgen/schema/ndfdXML.xsd}productType
#   startTime       DateTime - {http://www.w3.org/2001/XMLSchema}dateTime
#   endTime         DateTime - {http://www.w3.org/2001/XMLSchema}dateTime
#   weatherParameters WeatherParametersType - {http://weather.gov/forecasts/xml/DWMLgen/schema/ndfdXML.xsd}weatherParametersType
#
# RETURNS
#   dwmlOut         C_String - {http://www.w3.org/2001/XMLSchema}string
#
latitude = longitude = product = startTime = endTime = weatherParameters = nil
puts obj.nDFDgen(latitude, longitude, product, startTime, endTime, weatherParameters)

# SYNOPSIS
#   NDFDgenByDay(latitude, longitude, startDate, numDays, format)
#
# ARGS
#   latitude        Decimal - {http://www.w3.org/2001/XMLSchema}decimal
#   longitude       Decimal - {http://www.w3.org/2001/XMLSchema}decimal
#   startDate       Date - {http://www.w3.org/2001/XMLSchema}date
#   numDays         C_Integer - {http://www.w3.org/2001/XMLSchema}integer
#   format          FormatType - {http://weather.gov/forecasts/xml/DWMLgen/schema/ndfdXML.xsd}formatType
#
# RETURNS
#   dwmlByDayOut    C_String - {http://www.w3.org/2001/XMLSchema}string
#
latitude = longitude = startDate = numDays = format = nil
puts obj.nDFDgenByDay(latitude, longitude, startDate, numDays, format)


