require 'soap/driver'
require 'base'
require 'methodDef'


$server = nil
$soapAction = nil

$proxy = ARGV.shift || nil


###
## Helper function
#
class Float
  Precision = 5

  def ==( rhs )
    if rhs.is_a?( Float )
      if self.nan? and rhs.nan?
	true
      elsif self.infinite? == rhs.infinite?
	true
      elsif ( rhs - self ).abs <= ( 10 ** ( - Precision ))
	true
      else
	false
      end
    else
      false
    end
  end
end

def assert( expected, actual )
  if expected == actual
    "OK"
  else
    "Expected = " << expected.inspect << " // Actual = " << actual.inspect
  end
end

def dump( var )
  if var.is_a?( Array )
    var.join( ", " )
  else
    var.to_s
  end
end

def getWireDumpLogFile
  logFilename = File.basename( $0 ) + '.log'
  f = File.open( logFilename, 'w' )
  f << "File: #{ logFilename } - Wiredumps for SOAP4R client / #{ $serverName } server.\n"
  f << "Date: #{ Time.now }\n\n"
end

def dumpTitle( dumpDev, str )
  dumpDev << "##########\n# " << str << "\n\n"
end

def dumpResult( dumpDev, expected, actual )
  dumpDev << 'Result: ' << assert( expected, actual ) << "\n\n\n"
end


###
## Invoke methods.
#
def doTest( drv )
  dumpDev = getWireDumpLogFile
  drv.setWireDumpDev( dumpDev )

#=begin
  dumpTitle( dumpDev, 'echoVoid' )
  var =  drv.echoVoid()
  dumpResult( dumpDev, var, nil )

  dumpTitle( dumpDev, 'echoString' )
  arg = "SOAP4R Interoperability Test"
  var = drv.echoString( arg )
  dumpResult( dumpDev, arg, var )

  dumpTitle( dumpDev, 'echoString (space)' )
  arg = ' '
  var = drv.echoString( arg )
  dumpResult( dumpDev, arg, var )

  dumpTitle( dumpDev, 'echoString (whitespaces)' )
  arg = "\r\n\t\r\n\t"
  var = drv.echoString( arg )
  dumpResult( dumpDev, arg, var )

  dumpTitle( dumpDev, 'echoStringArray' )
  arg = [ "SOAP4R", "Interoperability", "Test" ]
  var = drv.echoStringArray( arg )
  dumpResult( dumpDev, arg, var )

  dumpTitle( dumpDev, 'echoInteger' )
  arg = 1
  # arg = 4294967296
  var = drv.echoInteger( arg )
  dumpResult( dumpDev, arg, var )

  dumpTitle( dumpDev, 'echoIntegerArray' )
  arg = [ 1, 2, 3 ]
  # arg = [ 4294967295, 4294967296, 4294967297 ]
  var = drv.echoIntegerArray( arg )
  dumpResult( dumpDev, arg, var )

  dumpTitle( dumpDev, 'echoFloat' )
  arg = 3.14159265358979
  var = drv.echoFloat( arg )
  dumpResult( dumpDev, arg, var )

  dumpTitle( dumpDev, 'echoFloatArray' )
  nan = 0.0/0.0
  inf = 1.0/0.0
  inf_ = -1.0/0.0
  arg = [ nan, inf, inf_ ]
  var = drv.echoFloatArray( arg )
  dumpResult( dumpDev, arg, var ) << "\n"

  dumpTitle( dumpDev, 'echoStruct' )
  arg = SOAPStruct.new( 1, 1.1, "a" )
  var = drv.echoStruct( arg )
  dumpResult( dumpDev, arg, var )

  dumpTitle( dumpDev, 'echoStructArray' )
  s1 = SOAPStruct.new( 1, 1.1, "a" )
  s2 = SOAPStruct.new( 2, 2.2, "b" )
  s3 = SOAPStruct.new( 3, 3.3, "c" )
  arg = [ s1, s2, s3 ]
  var = drv.echoStructArray( arg )
  dumpResult( dumpDev, arg, var ) 

  dumpTitle( dumpDev, 'echoDate' )
  t = Time.now.gmtime
  arg = Date.new3( t.year, t.mon, t.mday, t.hour, t.min, t.sec )
  var = drv.echoDate( arg )
  dumpResult( dumpDev, arg, var )

  dumpTitle( dumpDev, 'echoBase64' )
  str = "Hello (日本語Japanese) こんにちは"
  arg = SOAP::SOAPBase64.new( str )
  var = drv.echoBase64( arg )
  dumpResult( dumpDev, str, var )
#=end

  dumpDev.close
end
