$KCODE = 'EUC'

require 'soap/driver'
require 'soap/xmlparser'

require 'soap/rpcUtils'
include SOAP::RPCUtils

require 'base'
include SOAPBuildersInterop


$server = nil
$soapAction = 'http://soapinterop.org/'

$proxy = ARGV.shift || nil


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
  SOAPBuildersInterop::MethodsBase.each do | methodName, params |
    drv.addMethodWithSOAPAction( methodName, soapAction + methodName, params )
  end
end

def methodDefGroupB( drv )
  SOAPBuildersInterop::MethodsGroupB.each do | methodName, *params |
    drv.addMethod( methodName, params )
  end
end

def methodDefWithSOAPActionGroupB( drv, soapAction )
  SOAPBuildersInterop::MethodsGroupB.each do | methodName, params |
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

def getWireDumpLogFile( postfix = "" )
  logFilename = File.basename( $0 ).sub( '\.rb$', '' ) << postfix << '.log'
  f = File.open( logFilename, 'w' )
  f << "File: #{ logFilename } - Wiredumps for SOAP4R client / #{ $serverName } server.\n"
  f << "Date: #{ Time.now }\n\n"
end

def getWireDumpLogFileBase( postfix = "" )
  File.basename( $0 ).sub( /\.rb$/, '' ) + postfix
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
  doTestBase( drv )
  doTestGroupB( drv )
end

def doTestBase( drv )
  dumpDev = getWireDumpLogFile( '_Base' )
  drv.setWireDumpDev( dumpDev )
#  drv.setWireDumpFileBase( getWireDumpLogFileBase( '_Base' ))
  drv.mappingRegistry = SOAPBuildersInterop::MappingRegistry

  dumpTitle( dumpDev, 'echoVoid' )
  begin
    var =  drv.echoVoid()
    dumpResult( dumpDev, var, nil )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoString' )
  begin
    arg = "SOAP4R Interoperability Test"
    var = drv.echoString( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoString(EUC encoded)' )
  begin
    arg = "Hello (日本語Japanese) こんにちは"
    var = drv.echoString( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoString (space)' )
  begin
    arg = ' '
    var = drv.echoString( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoString (whitespaces)' )
  begin
    arg = "\r\n\t\r\n\t"
    var = drv.echoString( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoStringArray' )
  begin
    arg = StringArray[ "SOAP4R", "Interoperability", "Test" ]
    var = drv.echoStringArray( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoInteger(Int: 2147483647)' )
  begin
    arg = 2147483647
    var = drv.echoInteger( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoInteger(Int: -2147483648)' )
  begin
    arg = -2147483648
    var = drv.echoInteger( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoIntegerArray' )
  begin
    arg = IntArray[ 1, 2, 3 ]
    var = drv.echoIntegerArray( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoIntegerArray with empty Array' )
  begin
    arg = SOAP::SOAPArray.new( XSD::IntLiteral )
    arg.typeNamespace = XSD::Namespace
    var = drv.echoIntegerArray( arg )
    dumpResult( dumpDev, [], var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoFloat' )
  begin
    arg = 3.14159265358979
    var = drv.echoFloat( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoFloatScientificNotation' )
  begin
    arg = 12.34e56
    var = drv.echoFloat( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoFloatArray' )
  begin
    nan = 0.0/0.0
    inf = 1.0/0.0
    inf_ = -1.0/0.0
    arg = FloatArray[ nan, inf, inf_ ]
    var = drv.echoFloatArray( arg )
    dumpResult( dumpDev, arg, var ) << "\n"
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoStruct' )
  begin
    arg = SOAPStruct.new( 1, 1.1, "a" )
    var = drv.echoStruct( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoAnyTypeArray' )
  begin
    s1 = SOAPStruct.new( 1, 1.1, "a" )
    s2 = SOAPStruct.new( 2, 2.2, "b" )
    s3 = SOAPStruct.new( 3, 3.3, "c" )
    arg = [ s1, s2, s3 ]
    var = drv.echoStructArray( arg )
    dumpResult( dumpDev, arg, var ) 
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoStructArray' )
  begin
    s1 = SOAPStruct.new( 1, 1.1, "a" )
    s2 = SOAPStruct.new( 2, 2.2, "b" )
    s3 = SOAPStruct.new( 3, 3.3, "c" )
    arg = SOAPStructArray[ s1, s2, s3 ]
    var = drv.echoStructArray( arg )
    dumpResult( dumpDev, arg, var ) 
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoDate' )
  begin
    t = Time.now.gmtime
    arg = Date.new3( t.year, t.mon, t.mday, t.hour, t.min, t.sec )
    var = drv.echoDate( arg )
    dumpResult( dumpDev, arg.to_s, var.to_s )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoDate(time precision)' )
  begin
    arg = SOAP::SOAPDateTime.new( '2001-06-16T18:13:40.0000000000123456789012345678900000000000' )
    argDate = arg.data
    var = drv.echoDate( arg )
    dumpResult( dumpDev, argDate, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoDate(TZ converted)' )
  begin
    arg = SOAP::SOAPDateTime.new( '2001-06-16T18:13:40-07:00' )
    argNormalized = Date.new3( 2001, 6, 17, 1, 13, 40 )
    var = drv.echoDate( arg )
    dumpResult( dumpDev, argNormalized.to_s, var.to_s )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoBase64(SOAP-ENC:base64)' )
  begin
    str = "Hello (日本語Japanese) こんにちは"
    arg = SOAP::SOAPBase64.new( str )
    var = drv.echoBase64( arg )
    dumpResult( dumpDev, str, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoBase64(xsd:base64Binary)' )
  begin
    str = "Hello (日本語Japanese) こんにちは"
    arg = SOAP::SOAPBase64.new( str )
    arg.asXSD	# Force xsd:base64Binary instead of soap-enc:base64
    var = drv.echoBase64( arg )
    dumpResult( dumpDev, str, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpDev.close
end


###
## Invoke methods.
#
def doTestGroupB( drv )
  dumpDev = getWireDumpLogFile( '_GroupB' )
  drv.setWireDumpDev( dumpDev )
#  drv.setWireDumpFileBase( getWireDumpLogFileBase( '_GroupB' ))
  drv.mappingRegistry = SOAPBuildersInterop::MappingRegistry

  dumpTitle( dumpDev, 'echoStructAsSimpleTypes' )
  begin
    arg = SOAPStruct.new( 1, 1.1, "a" )
    ret, out1, out2 = drv.echoStructAsSimpleTypes( arg )
    var = SOAPStruct.new( out1, out2, ret )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoSimpleTypesAsStruct' )
  begin
    arg = SOAPStruct.new( 1, 1.1, "a" )
    var = drv.echoSimpleTypesAsStruct( arg.varString, arg.varInt, arg.varFloat )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echo2DStringArray' )
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
    dumpResult( dumpDev, argNormalized, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echo2DStringArray(anyTypeArray)' )
  begin
    # ary2md converts Arry ((of Array)...) into M-D anyType Array
    arg = [
      [ 'r0c0', 'r0c1', 'r0c2' ],
      [ 'r1c0', 'r1c1', 'r1c2' ],
      [ 'r2c0', 'r0c1', 'r2c2' ],
    ]

    var = drv.echo2DStringArray( SOAP::RPCUtils.ary2md( arg, 2 ))
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echo2DStringArray(sparse)' )
  begin
    # ary2md converts Arry ((of Array)...) into M-D anyType Array
    arg = [
      [ 'r0c0', nil,    'r0c2' ],
      [ nil,    'r1c1', 'r1c2' ],
    ]
    md = SOAP::RPCUtils.ary2md( arg, 2 )
    md.sparse = true

    var = drv.echo2DStringArray( md )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoNestedStruct' )
  begin
    arg = SOAPStructStruct.new( 1, 1.1, "a",
      SOAPStruct.new( 2, 2.2, "b" )
    )
    var = drv.echoNestedStruct( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoNestedStruct(nil)' )
  begin
    arg = SOAPStructStruct.new( nil, nil, nil,
      SOAPStruct.new( nil, nil, nil )
    )
    var = drv.echoNestedStruct( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoNestedArray' )
  begin
    arg = SOAPArrayStruct.new( 1, 1.1, "a", StringArray[ "2", "2.2", "b" ] )
    var = drv.echoNestedArray( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoNestedArray(anyTypeArray)' )
  begin
    arg = SOAPArrayStruct.new( 1, 1.1, "a", [ "2", "2.2", "b" ] )
    var = drv.echoNestedArray( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoBoolean(true)' )
  begin
    arg = true
    var = drv.echoBoolean( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoBoolean(false)' )
  begin
    arg = false
    var = drv.echoBoolean( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

#  dumpTitle( dumpDev, 'echoDouble' )
#  begin
#    arg = 3.14159265358979
#    var = drv.echoDouble( arg )
#    dumpResult( dumpDev, arg, var )
#  rescue Exception
#    dumpException( dumpDev )
#  end

  dumpTitle( dumpDev, 'echoDecimal(123456)' )
  begin
    arg = "12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
    var = drv.echoDecimal( SOAP::SOAPDecimal.new( arg ))
    normalized = arg
    dumpResult( dumpDev, normalized, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoDecimal(+0.123)' )
  begin
    arg = "+0.12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
    var = drv.echoDecimal( SOAP::SOAPDecimal.new( arg ))
    normalized = arg.sub( /0$/, '' ).sub( /^\+/, '' )
    dumpResult( dumpDev, normalized, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoDecimal(.00000123)' )
  begin
    arg = ".0000012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
    var = drv.echoDecimal( SOAP::SOAPDecimal.new( arg ))
    normalized = '0' << arg.sub( /0$/, '' )
    dumpResult( dumpDev, normalized, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoDecimal(-123.456)' )
  begin
    arg = "-12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123.45678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
    var = drv.echoDecimal( SOAP::SOAPDecimal.new( arg ))
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoDecimal(-123.)' )
  begin
    arg = "-12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890."
    normalized = arg.sub( /\.$/, '' )
    var = drv.echoDecimal( SOAP::SOAPDecimal.new( arg ))
    dumpResult( dumpDev, normalized, var )
  rescue Exception
    dumpException( dumpDev )
  end

=begin
  dumpTitle( dumpDev, 'echoXSDDateTime' )
  begin
    arg = Date.new3( 1000, 1, 1, 1, 1, 1 )
    var = drv.echoXSDDateTime( arg )
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoXSDDate' )
  begin
    arg = Date.new3( 1000, 1, 1 )
    var = drv.echoXSDDate( SOAP::SOAPDate.new( arg ))
    dumpResult( dumpDev, arg, var )
  rescue Exception
    dumpException( dumpDev )
  end

  dumpTitle( dumpDev, 'echoXSDTime' )
  begin
    arg = Time.now.gmtime
    var = drv.echoXSDTime( SOAP::SOAPTime.new( arg ))
    dumpResult( dumpDev, SOAP::SOAPTime.new( arg ).to_s, SOAP::SOAPTime.new( var ).to_s )
  rescue Exception
    dumpException( dumpDev )
  end
=end

  dumpDev.close
end
