$KCODE = 'EUC'

require 'soap/driver'
require 'soap/xmlparser'

require 'soap/rpcUtils'
include SOAP::RPCUtils

require 'base'
include SOAPBuildersInterop
$soapAction = 'http://soapinterop.org/'
$proxy = ARGV.shift || nil

require 'interopResultBase'
$testResultServer = 'http://www.jin.gr.jp/~nahi/Ruby/SOAP4R/rwikiInteropServer.cgi'
$testResultProxy = nil

$testResultLog = Log.new( STDERR )
$testResultLog.sevThreshold = Log::SEV_INFO
$testResultDrv = SOAP::Driver.new( $testResultLog, 'SOAPBuildersInteropResult', SOAPBuildersInteropResult::InterfaceNS, $testResultServer, $testResultProxy, '' )

SOAPBuildersInteropResult::Methods.each do | methodName, *params |
  $testResultDrv.addMethod( methodName, params )
end

client = SOAPBuildersInteropResult::Endpoint.new
client.processorName = 'SOAP4R'
client.processorVersion = SOAP::Version
client.uri = '210.233.24.119:*'
client.wsdl = 'Not used.'

server = SOAPBuildersInteropResult::Endpoint.new
server.endpointName = $serverName
server.uri = $server || "#{ $serverBase }, #{ $serverGroupB }"
server.wsdl = 'Not used.'

$testResults = SOAPBuildersInteropResult::InteropResults.new( client, server )

$wireDumpDev = ''
def $wireDumpDev.close; end

$wireDumpLogFile = STDERR


###
## Method definition.
#
def methodDef( drv )
  methodDefBase( drv )
  methodDefGroupB( drv )
end

def methodDefWithSOAPAction( drv, soapAction )
  methodDefWithSOAPActionBase( drv, soapAction )
  methodDefWithSOAPActionGroupB( drv, soapAction )
end


def methodDefBase( drv )
  SOAPBuildersInterop::MethodsBase.each do | methodName, *params |
    drv.addMethod( methodName, params )
  end
end

def methodDefWithSOAPActionBase( drv, soapAction )
  SOAPBuildersInterop::MethodsBase.each do | methodName, *params |
    drv.addMethodWithSOAPAction( methodName, soapAction + methodName, params )
  end
end

def methodDefGroupB( drv )
  SOAPBuildersInterop::MethodsGroupB.each do | methodName, *params |
    drv.addMethod( methodName, params )
  end
end

def methodDefWithSOAPActionGroupB( drv, soapAction )
  SOAPBuildersInterop::MethodsGroupB.each do | methodName, *params |
    drv.addMethodWithSOAPAction( methodName, soapAction + methodName, params )
  end
end


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
    'OK'
  else
    "Expected = " << expected.inspect << "\nActual = " << actual.inspect
  end
end

def dump( var )
  if var.is_a?( Array )
    var.join( ", " )
  else
    var.to_s
  end
end

def setWireDumpLogFile( postfix = "" )
  logFilename = File.basename( $0 ).sub( '\.rb$', '' ) << postfix << '.log'
  f = File.open( logFilename, 'w' )
  f << "File: #{ logFilename } - Wiredumps for SOAP4R client / #{ $serverName } server.\n"
  f << "Date: #{ Time.now }\n\n"
  $wireDumpLogFile = f
end

def getWireDumpLogFileBase( postfix = "" )
  File.basename( $0 ).sub( /\.rb$/, '' ) + postfix
end

def dumpNormal( title, expected, actual )
  result = assert( expected, actual )
  if result == 'OK'
    dumpResult( title, true, nil )
  else
    dumpResult( title, false, result )
  end
end

def dumpException( title )
  result = "Exception: #{ $! } (#{ $!.type})\n" << $@.join( "\n" )
  dumpResult( title, false, result )
end

def dumpResult( title, result, resultStr )
  $wireDumpLogFile << "##########\n# " << title << "\n\n"
  $testResults.add(
    SOAPBuildersInteropResult::TestResult.new(
      title,
      result,
      resultStr,
      $wireDumpDev.dup
    )
  )
  $wireDumpLogFile << "Result: #{ resultStr || 'OK' }\n\n"
  $wireDumpLogFile << $wireDumpDev
  $wireDumpLogFile << "\n"

  $wireDumpDev.replace( '' )
end

def submitTestResult
  load 'soap/XMLSchemaDatatypes.rb'
  $testResultDrv.add( $testResults )
end


###
## Invoke methods.
#
def doTest( drv )
  doTestBase( drv )
  doTestGroupB( drv )
end

def doTestBase( drv )
  setWireDumpLogFile( '_Base' )
  drv.setWireDumpDev( $wireDumpDev )

#  drv.setWireDumpFileBase( getWireDumpLogFileBase( '_Base' ))
  drv.mappingRegistry = SOAPBuildersInterop::MappingRegistry

  title = 'echoVoid'
  begin
    var =  drv.echoVoid()
    dumpNormal( title, nil, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoString'
  begin
    arg = "SOAP4R Interoperability Test"
    var = drv.echoString( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoString (Leading and trailing whitespace)'
  begin
    arg = "   SOAP4R\nInteroperability\nTest   "
    var = drv.echoString( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoString (EUC encoded)'
  begin
    arg = "Hello (日本語Japanese) こんにちは"
    var = drv.echoString( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoString (EUC encoded) again'
  begin
    arg = "Hello (日本語Japanese) こんにちは"
    var = drv.echoString( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoString (empty)'
  begin
    arg = ''
    var = drv.echoString( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoString (space)'
  begin
    arg = ' '
    var = drv.echoString( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoString (whitespaces:\r \n \t \r \n \t)'
  begin
    arg = "\r \n \t \r \n \t"
    var = drv.echoString( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoStringArray'
  begin
    arg = StringArray[ "SOAP4R\n", " Interoperability ", "\tTest\t" ]
    var = drv.echoStringArray( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoInteger (Int: 123)'
  begin
    arg = 123
    var = drv.echoInteger( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoInteger (Int: 2147483647)'
  begin
    arg = 2147483647
    var = drv.echoInteger( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoInteger (Int: -2147483648)'
  begin
    arg = -2147483648
    var = drv.echoInteger( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoIntegerArray'
  begin
    arg = IntArray[ 1, 2, 3 ]
    var = drv.echoIntegerArray( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

#  title = 'echoIntegerArray (nil)'
#  begin
#    arg = IntArray[ nil, nil, nil ]
#    var = drv.echoIntegerArray( arg )
#    dumpNormal( title, arg, var )
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echoIntegerArray (empty)'
  begin
    arg = SOAP::SOAPArray.new( XSD::IntLiteral )
    arg.typeNamespace = XSD::Namespace
    var = drv.echoIntegerArray( arg )
    dumpNormal( title, [], var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoFloat'
  begin
    arg = 3.14159265358979
    var = drv.echoFloat( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoFloat (scientific notation)'
  begin
    arg = 12.34e36
    var = drv.echoFloat( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoFloatArray'
  begin
    arg = FloatArray[ 0.0001, 1000.0, 0.0 ]
    var = drv.echoFloatArray( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoFloatArray (special values: NaN, INF, -INF)'
  begin
    nan = 0.0/0.0
    inf = 1.0/0.0
    inf_ = -1.0/0.0
    arg = FloatArray[ nan, inf, inf_ ]
    var = drv.echoFloatArray( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoStruct'
  begin
    arg = SOAPStruct.new( 1, 1.1, "a" )
    var = drv.echoStruct( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

#  title = 'echoStruct (nil members)'
#  begin
#    arg = SOAPStruct.new( nil, nil, nil )
#    var = drv.echoStruct( arg )
#    dumpNormal( title, arg, var )
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echoStructArray'
  begin
    s1 = SOAPStruct.new( 1, 1.1, "a" )
    s2 = SOAPStruct.new( 2, 2.2, "b" )
    s3 = SOAPStruct.new( 3, 3.3, "c" )
    arg = SOAPStructArray[ s1, s2, s3 ]
    var = drv.echoStructArray( arg )
    dumpNormal( title, arg, var ) 
  rescue Exception
    dumpException( title )
  end

  title = 'echoStructArray (anyType Array)'
  begin
    s1 = SOAPStruct.new( 1, 1.1, "a" )
    s2 = SOAPStruct.new( 2, 2.2, "b" )
    s3 = SOAPStruct.new( 3, 3.3, "c" )
    arg = [ s1, s2, s3 ]
    var = drv.echoStructArray( arg )
    dumpNormal( title, arg, var ) 
  rescue Exception
    dumpException( title )
  end

  title = 'echoDate (now)'
  begin
    t = Time.now.gmtime
    arg = Date.new3( t.year, t.mon, t.mday, t.hour, t.min, t.sec )
    var = drv.echoDate( arg )
    dumpNormal( title, arg.to_s, var.to_s )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDate (before 1970: 1-01-01T00:00:00Z)'
  begin
    t = Time.now.gmtime
    arg = Date.new3( 1, 1, 1, 0, 0, 0 )
    var = drv.echoDate( arg )
    dumpNormal( title, arg.to_s, var.to_s )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDate (after 2038: 2038-12-31T00:00:00Z)'
  begin
    t = Time.now.gmtime
    arg = Date.new3( 2038, 12, 31, 0, 0, 0 )
    var = drv.echoDate( arg )
    dumpNormal( title, arg.to_s, var.to_s )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDate (negative: -10-01-01T00:00:00Z)'
  begin
    t = Time.now.gmtime
    arg = Date.new3( -10, 1, 1, 0, 0, 0 )
    var = drv.echoDate( arg )
    dumpNormal( title, arg.to_s, var.to_s )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDate (time precision: msec)'
  begin
    arg = SOAP::SOAPDateTime.new( '2001-06-16T18:13:40.012' )
    argDate = arg.data
    var = drv.echoDate( arg )
    dumpNormal( title, argDate, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDate (time precision: long)'
  begin
    arg = SOAP::SOAPDateTime.new( '2001-06-16T18:13:40.0000000000123456789012345678900000000000' )
    argDate = arg.data
    var = drv.echoDate( arg )
    dumpNormal( title, argDate, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDate (client side TZ conversion)'
  begin
    arg = SOAP::SOAPDateTime.new( '2001-06-16T18:13:40-07:00' )
    argNormalized = Date.new3( 2001, 6, 17, 1, 13, 40 )
    var = drv.echoDate( arg )
    dumpNormal( title, argNormalized.to_s, var.to_s )
  rescue Exception
    dumpException( title )
  end

  title = 'echoBase64 (xsd:base64Binary)'
  begin
    str = "Hello (日本語Japanese) こんにちは"
    arg = SOAP::SOAPBase64.new( str )
    arg.asXSD	# Force xsd:base64Binary instead of soap-enc:base64
    var = drv.echoBase64( arg )
    dumpNormal( title, str, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoBase64 (xsd:base64Binary, empty)'
  begin
    str = ""
    arg = SOAP::SOAPBase64.new( str )
    arg.asXSD	# Force xsd:base64Binary instead of soap-enc:base64
    var = drv.echoBase64( arg )
    dumpNormal( title, str, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoBase64 (SOAP-ENC:base64)'
  begin
    str = "Hello (日本語Japanese) こんにちは"
    arg = SOAP::SOAPBase64.new( str )
    var = drv.echoBase64( arg )
    dumpNormal( title, str, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoHexBinary'
  begin
    str = "Hello (日本語Japanese) こんにちは"
    arg = SOAP::SOAPHexBinary.new( str )
    var = drv.echoHexBinary( arg )
    dumpNormal( title, str, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoHexBinary(empty)'
  begin
    str = ""
    arg = SOAP::SOAPHexBinary.new( str )
    var = drv.echoHexBinary( arg )
    dumpNormal( title, str, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoBoolean (true)'
  begin
    arg = true
    var = drv.echoBoolean( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoBoolean (false)'
  begin
    arg = false
    var = drv.echoBoolean( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

#  title = 'echoDouble'
#  begin
#    arg = 3.14159265358979
#    var = drv.echoDouble( arg )
#    dumpNormal( title, arg, var )
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echoDecimal (123456)'
  begin
    arg = "12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
    var = drv.echoDecimal( SOAP::SOAPDecimal.new( arg ))
    normalized = arg
    dumpNormal( title, normalized, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDecimal (+0.123)'
  begin
    arg = "+0.12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
    var = drv.echoDecimal( SOAP::SOAPDecimal.new( arg ))
    normalized = arg.sub( /0$/, '' ).sub( /^\+/, '' )
    dumpNormal( title, normalized, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDecimal (.00000123)'
  begin
    arg = ".0000012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
    var = drv.echoDecimal( SOAP::SOAPDecimal.new( arg ))
    normalized = '0' << arg.sub( /0$/, '' )
    dumpNormal( title, normalized, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDecimal (-123.456)'
  begin
    arg = "-12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123.45678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
    var = drv.echoDecimal( SOAP::SOAPDecimal.new( arg ))
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDecimal (-123.)'
  begin
    arg = "-12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890."
    normalized = arg.sub( /\.$/, '' )
    var = drv.echoDecimal( SOAP::SOAPDecimal.new( arg ))
    dumpNormal( title, normalized, var )
  rescue Exception
    dumpException( title )
  end

if $test_echoMap

  title = 'echoMap'
  begin
    arg = { "a" => 1, "b" => 2 }
    var = drv.echoMap( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoMap (boolean, base64, nil, float)'
  begin
    arg = { true => "\0", "\0" => nil, nil => 0.0001, 0.0001 => false }
    var = drv.echoMap( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoMap (multibyte char)'
    arg = { "Hello (日本語Japanese) こんにちは" => 1, 1 => "Hello (日本語Japanese) こんにちは" }
  begin
    var = drv.echoMap( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end
end

end


###
## Invoke methods.
#
def doTestGroupB( drv )
  setWireDumpLogFile( '_GroupB' )
  drv.setWireDumpDev( $wireDumpDev )

#  drv.setWireDumpFileBase( getWireDumpLogFileBase( '_GroupB' ))
  drv.mappingRegistry = SOAPBuildersInterop::MappingRegistry

  title = 'echoStructAsSimpleTypes'
  begin
    arg = SOAPStruct.new( 1, 1.1, "a" )
    ret, out1, out2 = drv.echoStructAsSimpleTypes( arg )
    var = SOAPStruct.new( out1, out2, ret )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

#  title = 'echoStructAsSimpleTypes (nil)'
#  begin
#    arg = SOAPStruct.new( nil, nil, nil )
#    ret, out1, out2 = drv.echoStructAsSimpleTypes( arg )
#    var = SOAPStruct.new( out1, out2, ret )
#    dumpNormal( title, arg, var )
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echoSimpleTypesAsStruct'
  begin
    arg = SOAPStruct.new( 1, 1.1, "a" )
    var = drv.echoSimpleTypesAsStruct( arg.varString, arg.varInt, arg.varFloat )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

#  title = 'echoSimpleTypesAsStruct (nil)'
#  begin
#    arg = SOAPStruct.new( nil, nil, nil )
#    var = drv.echoSimpleTypesAsStruct( arg.varString, arg.varInt, arg.varFloat )
#    dumpNormal( title, arg, var )
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echo2DStringArray'
  begin

#    arg = SOAP::SOAPArray.new( 'string', 2 )
#    arg.typeNamespace = XSD::Namespace
#    arg[ 0, 0 ] = obj2soap( 'r0c0' )
#    arg[ 1, 0 ] = obj2soap( 'r1c0' )
#    arg[ 2, 0 ] = obj2soap( 'r2c0' )
#    arg[ 0, 1 ] = obj2soap( 'r0c1' )
#    arg[ 1, 1 ] = obj2soap( 'r1c1' )
#    arg[ 2, 1 ] = obj2soap( 'r2c1' )
#    arg[ 0, 2 ] = obj2soap( 'r0c2' )
#    arg[ 1, 2 ] = obj2soap( 'r1c2' )
#    arg[ 2, 2 ] = obj2soap( 'r2c2' )

    arg = SOAP::SOAPArray.new( 'string', 2 )
    arg.typeNamespace = XSD::Namespace
    arg.size = [ 3, 3 ]
    arg.sizeFixed = true
    arg.add( SOAP::RPCUtils.obj2soap( 'r0c0' ))
    arg.add( SOAP::RPCUtils.obj2soap( 'r1c0' ))
    arg.add( SOAP::RPCUtils.obj2soap( 'r2c0' ))
    arg.add( SOAP::RPCUtils.obj2soap( 'r0c1' ))
    arg.add( SOAP::RPCUtils.obj2soap( 'r1c1' ))
    arg.add( SOAP::RPCUtils.obj2soap( 'r2c1' ))
    arg.add( SOAP::RPCUtils.obj2soap( 'r0c2' ))
    arg.add( SOAP::RPCUtils.obj2soap( 'r1c2' ))
    arg.add( SOAP::RPCUtils.obj2soap( 'r2c2' ))
    argNormalized = [
      [ 'r0c0', 'r1c0', 'r2c0' ],
      [ 'r0c1', 'r1c1', 'r2c1' ],
      [ 'r0c2', 'r1c2', 'r2c2' ],
    ]

    var = drv.echo2DStringArray( arg )
    dumpNormal( title, argNormalized, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echo2DStringArray (anyType array)'
  begin
    # ary2md converts Arry ((of Array)...) into M-D anyType Array
    arg = [
      [ 'r0c0', 'r0c1', 'r0c2' ],
      [ 'r1c0', 'r1c1', 'r1c2' ],
      [ 'r2c0', 'r0c1', 'r2c2' ],
    ]

    var = drv.echo2DStringArray( SOAP::RPCUtils.ary2md( arg, 2 ))
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echo2DStringArray (sparse)'
  begin
    # ary2md converts Arry ((of Array)...) into M-D anyType Array
    arg = [
      [ 'r0c0', nil,    'r0c2' ],
      [ nil,    'r1c1', 'r1c2' ],
    ]
    md = SOAP::RPCUtils.ary2md( arg, 2 )
    md.sparse = true

    var = drv.echo2DStringArray( md )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoNestedStruct'
  begin
    arg = SOAPStructStruct.new( 1, 1.1, "a",
      SOAPStruct.new( 2, 2.2, "b" )
    )
    var = drv.echoNestedStruct( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

#  title = 'echoNestedStruct (nil)'
#  begin
#    arg = SOAPStructStruct.new( nil, nil, nil,
#      SOAPStruct.new( nil, nil, nil )
#    )
#    var = drv.echoNestedStruct( arg )
#    dumpNormal( title, arg, var )
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echoNestedArray'
  begin
    arg = SOAPArrayStruct.new( 1, 1.1, "a", StringArray[ "2", "2.2", "b" ] )
    var = drv.echoNestedArray( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoNestedArray (anyType array)'
  begin
    arg = SOAPArrayStruct.new( 1, 1.1, "a", [ "2", "2.2", "b" ] )
    var = drv.echoNestedArray( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

=begin
  title = 'echoXSDDateTime'
  begin
    arg = Date.new3( 1000, 1, 1, 1, 1, 1 )
    var = drv.echoXSDDateTime( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoXSDDate'
  begin
    arg = Date.new3( 1000, 1, 1 )
    var = drv.echoXSDDate( SOAP::SOAPDate.new( arg ))
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoXSDTime'
  begin
    arg = Time.now.gmtime
    var = drv.echoXSDTime( SOAP::SOAPTime.new( arg ))
    dumpNormal( title, SOAP::SOAPTime.new( arg ).to_s, SOAP::SOAPTime.new( var ).to_s )
  rescue Exception
    dumpException( title )
  end
=end

end
