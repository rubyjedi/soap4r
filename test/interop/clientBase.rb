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
    if ( rhs - self ).abs <= ( 10 ** ( - Precision ))
      true
    else
      false
    end
  end
end

def assert( expected, actual )
  if expected == actual
    "OK"
  else
    "Expected = " << dump( expected ) << " // Actual = " << dump( actual )
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

  dumpTitle( dumpDev, 'echoVoid' )
  var =  drv.echoVoid()
  dumpResult( dumpDev, var, nil )

  dumpTitle( dumpDev, 'echoString' )
  arg = "SOAP4R Interoperability Test"
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
  arg = [ 3.14159265358979, 3.14159265358979, 3.14159265358979 ]
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

  dumpDev.close
end
