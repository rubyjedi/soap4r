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

def getWireDumpLogFileBase
  File.basename( $0 ).sub( /\.rb$/, '' )
end

def dumpTitle( dumpDev, str )
  dumpDev << "##########\n# " << str << "\n\n"
end

def dumpResult( dumpDev, expected, actual )
  dumpDev << 'Result: ' << assert( expected, actual ) << "\n\n\n"
end

def dumpException( dumpDev )
  dumpDev << "Result: #{ $! } (#{ $!.type})\n" << $@.join( "\n" ) << "\n\n\n"
end


###
## Invoke methods.
#
def doTest( drv )
  dumpDev = getWireDumpLogFile
#  drv.setWireDumpDev( dumpDev )
  drv.setWireDumpFileBase( getWireDumpLogFileBase )

  dumpTitle( dumpDev, 'echoVoid' )
  begin
    var =  drv.echoVoid()
    dumpResult( dumpDev, var, nil )
  rescue
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoString' )
  begin
    arg = "SOAP4R Interoperability Test"
    var = drv.echoString( arg )
    dumpResult( dumpDev, arg, var )
  rescue
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoString (space)' )
  begin
    arg = ' '
    var = drv.echoString( arg )
    dumpResult( dumpDev, arg, var )
  rescue
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoString (whitespaces)' )
  begin
    arg = "\r\n\t\r\n\t"
    var = drv.echoString( arg )
    dumpResult( dumpDev, arg, var )
  rescue
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoStringArray' )
  begin
    arg = [ "SOAP4R", "Interoperability", "Test" ]
    var = drv.echoStringArray( arg )
    dumpResult( dumpDev, arg, var )
  rescue
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoInteger' )
  begin
    arg = 1
    # arg = 4294967296
    var = drv.echoInteger( arg )
    dumpResult( dumpDev, arg, var )
  rescue
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoIntegerArray' )
  begin
    arg = [ 1, 2, 3 ]
    # arg = [ 4294967295, 4294967296, 4294967297 ]
    var = drv.echoIntegerArray( arg )
    dumpResult( dumpDev, arg, var )
  rescue
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoIntegerArray with empty Array' )
  begin
    arg = SOAP::SOAPArray.new( XSD::IntLiteral )
    arg.typeNamespace = XSD::Namespace
    var = drv.echoIntegerArray( arg )
    dumpResult( dumpDev, [], var )
  rescue
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoFloat' )
  begin
    arg = 3.14159265358979
    var = drv.echoFloat( arg )
    dumpResult( dumpDev, arg, var )
  rescue
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoFloatArray' )
  begin
    nan = 0.0/0.0
    inf = 1.0/0.0
    inf_ = -1.0/0.0
    arg = [ nan, inf, inf_ ]
    var = drv.echoFloatArray( arg )
    dumpResult( dumpDev, arg, var ) << "\n"
  rescue
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoStruct' )
  begin
    arg = SOAPStruct.new( 1, 1.1, "a" )
    var = drv.echoStruct( arg )
    dumpResult( dumpDev, arg, var )
  rescue
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoStructArray' )
  begin
    s1 = SOAPStruct.new( 1, 1.1, "a" )
    s2 = SOAPStruct.new( 2, 2.2, "b" )
    s3 = SOAPStruct.new( 3, 3.3, "c" )
    arg = [ s1, s2, s3 ]
    var = drv.echoStructArray( arg )
    dumpResult( dumpDev, arg, var ) 
  rescue
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoDate' )
  begin
    t = Time.now.gmtime
    arg = Date.new3( t.year, t.mon, t.mday, t.hour, t.min, t.sec )
    var = drv.echoDate( arg )
    dumpResult( dumpDev, arg, var )
  rescue
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoBase64' )
  begin
    str = "Hello (日本語Japanese) こんにちは"
    arg = SOAP::SOAPBase64.new( str )
    var = drv.echoBase64( arg )
    dumpResult( dumpDev, str, var )
  rescue
    dumpException( dumpDev )
  end

  dumpDev.close
end
