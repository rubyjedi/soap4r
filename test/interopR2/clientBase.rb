$KCODE = 'EUC'

require 'soap/driver'

require 'soap/rpcUtils'
include SOAP::RPCUtils

require 'base'
include SOAPBuildersInterop
$soapAction = 'http://soapinterop.org/'
$proxy = ARGV.shift || nil

require 'interopResultBase'
$testResultServer = 'http://www.jin.gr.jp/~nahi/Ruby/SOAP4R/rwikiInteropServer.cgi'
$testResultProxy = nil

$testResultLog = Devel::Logger.new( STDERR )
$testResultLog.sevThreshold = Devel::Logger::SEV_INFO
$testResultDrv = SOAP::Driver.new( $testResultLog, 'SOAPBuildersInteropResult', SOAPBuildersInteropResult::InterfaceNS, $testResultServer, $testResultProxy, '' )

SOAPBuildersInteropResult::Methods.each do | methodName, *params |
  $testResultDrv.addMethod( methodName, params )
end
#$testResultDrv.setWireDumpDev( STDERR )

client = SOAPBuildersInteropResult::Endpoint.new
client.processorName = 'SOAP4R'
client.processorVersion = '1.4'
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
    "Expected = " << expected.inspect << "  //  Actual = " << actual.inspect
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

def getIdObj( obj )
  case obj
  when Array
    obj.collect { | ele |
      getIdObj( ele )
    }
  else
    # String#== compares content of args.
    "#{ obj.type }##{ obj.__id__ }"
  end
end

def dumpTitle( title )
  $wireDumpLogFile << "##########\n# " << title << "\n\n"
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
  dumpTitle( title )
  begin
    var =  drv.echoVoid()
    dumpNormal( title, nil, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoString'
  dumpTitle( title )
  begin
    arg = "SOAP4R Interoperability Test"
    var = drv.echoString( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoString (Entity reference)'
  dumpTitle( title )
  begin
    arg = "<>\"& &lt;&gt;&quot;&amp; &amp&amp;><<<"
    var = drv.echoString( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoString (Character reference)'
  dumpTitle( title )
  begin
    arg = "\x20&#x20;\040&#32;\x7f&#x7f;\177&#127;"
    tobe = "    \177\177\177\177"
    var = drv.echoString( SOAP::SOAPRawString.new( arg ))
    dumpNormal( title, tobe, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoString (Leading and trailing whitespace)'
  dumpTitle( title )
  begin
    arg = "   SOAP4R\nInteroperability\nTest   "
    var = drv.echoString( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoString (EUC encoded)'
  dumpTitle( title )
  begin
    arg = "Hello (日本語Japanese) こんにちは"
    var = drv.echoString( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoString (EUC encoded) again'
  dumpTitle( title )
  begin
    arg = "Hello (日本語Japanese) こんにちは"
    var = drv.echoString( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoString (empty)'
  dumpTitle( title )
  begin
    arg = ''
    var = drv.echoString( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoString (space)'
  dumpTitle( title )
  begin
    arg = ' '
    var = drv.echoString( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoString (whitespaces:\r \n \t \r \n \t)'
  dumpTitle( title )
  begin
    arg = "\r \n \t \r \n \t"
    var = drv.echoString( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoStringArray'
  dumpTitle( title )
  begin
    arg = StringArray[ "SOAP4R\n", " Interoperability ", "\tTest\t" ]
    var = drv.echoStringArray( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

#  title = 'echoStringArray (sparse)'
#  dumpTitle( title )
#  begin
#    arg = [ nil, "SOAP4R\n", nil, " Interoperability ", nil, "\tTest\t", nil ]
#    soapAry = SOAP::RPCUtils.ary2soap( arg, XSD::Namespace, XSD::StringLiteral, SOAPBuildersInterop::MappingRegistry )
#    soapAry.sparse = true
#    var = drv.echoStringArray( soapAry )
#    dumpNormal( title, arg, var )
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echoStringArray (multi-ref)'
  dumpTitle( title )
  begin
    str1 = "SOAP4R"
    str2 = "SOAP4R"
    arg = StringArray[ str1, str2, str1 ]
    var = drv.echoStringArray( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoStringArray (multi-ref: elem1 == elem3)'
  dumpTitle( title )
  begin
    str1 = "SOAP4R"
    str2 = "SOAP4R"
    arg = StringArray[ str1, str2, str1 ]
    var = drv.echoStringArray( arg )
    dumpNormal( title, getIdObj( var[0] ), getIdObj( var[2] ))
  rescue Exception
    dumpException( title )
  end

  title = 'echoStringArray (empty, multi-ref: elem1 == elem3)'
  dumpTitle( title )
  begin
    str1 = ""
    str2 = ""
    arg = StringArray[ str1, str2, str1 ]
    var = drv.echoStringArray( arg )
    dumpNormal( title, getIdObj( var[0] ), getIdObj( var[2] ))
  rescue Exception
    dumpException( title )
  end

#  title = 'echoStringArray (sparse, multi-ref)'
#  dumpTitle( title )
#  begin
#    str = "SOAP4R"
#    arg = StringArray[ nil, nil, nil, nil, nil, str, nil, str ]
#    soapAry = SOAP::RPCUtils.ary2soap( arg, XSD::Namespace, XSD::StringLiteral, SOAPBuildersInterop::MappingRegistry )
#    soapAry.sparse = true
#    var = drv.echoStringArray( soapAry )
#    dumpNormal( title, arg, var )
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echoInteger (Int: 123)'
  dumpTitle( title )
  begin
    arg = 123
    var = drv.echoInteger( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoInteger (Int: 2147483647)'
  dumpTitle( title )
  begin
    arg = 2147483647
    var = drv.echoInteger( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoInteger (Int: -2147483648)'
  dumpTitle( title )
  begin
    arg = -2147483648
    var = drv.echoInteger( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoIntegerArray'
  dumpTitle( title )
  begin
    arg = IntArray[ 1, 2, 3 ]
    var = drv.echoIntegerArray( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoIntegerArray (nil)'
  dumpTitle( title )
  begin
    arg = IntArray[ nil, nil, nil ]
    var = drv.echoIntegerArray( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoIntegerArray (empty)'
  dumpTitle( title )
  begin
    arg = SOAP::SOAPArray.new( XSD::IntLiteral )
    arg.typeNamespace = XSD::Namespace
    var = drv.echoIntegerArray( arg )
    dumpNormal( title, [], var )
  rescue Exception
    dumpException( title )
  end

#  title = 'echoIntegerArray (sparse)'
#  dumpTitle( title )
#  begin
#    arg = [ nil, 1, nil, 2, nil, 3, nil ]
#    soapAry = SOAP::RPCUtils.ary2soap( arg, XSD::Namespace, XSD::IntLiteral, SOAPBuildersInterop::MappingRegistry )
#    soapAry.sparse = true
#    var = drv.echoIntegerArray( soapAry )
#    dumpNormal( title, arg, var )
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echoFloat'
  dumpTitle( title )
  begin
    arg = 3.14159265358979
    var = drv.echoFloat( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoFloat (scientific notation)'
  dumpTitle( title )
  begin
    arg = 12.34e36
    var = drv.echoFloat( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoFloat (positive lower boundary)'
  dumpTitle( title )
  begin
    arg = 1.4e-45
    var = drv.echoFloat( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoFloat (negative lower boundary)'
  dumpTitle( title )
  begin
    arg = -1.4e-45
    var = drv.echoFloat( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoFloat (special values: NaN)'
  dumpTitle( title )
  begin
    arg = 0.0/0.0
    var = drv.echoFloat( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoFloat (special values: INF)'
  dumpTitle( title )
  begin
    arg = 1.0/0.0
    var = drv.echoFloat( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoFloat (special values: -INF)'
  dumpTitle( title )
  begin
    arg = -1.0/0.0
    var = drv.echoFloat( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoFloatArray'
  dumpTitle( title )
  begin
    arg = FloatArray[ 0.0001, 1000.0, 0.0 ]
    var = drv.echoFloatArray( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoFloatArray (special values: NaN, INF, -INF)'
  dumpTitle( title )
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

#  title = 'echoFloatArray (sparse)'
#  dumpTitle( title )
#  begin
#    arg = [ nil, nil, 0.0001, 1000.0, 0.0, nil, nil ]
#    soapAry = SOAP::RPCUtils.ary2soap( arg, XSD::Namespace, XSD::FloatLiteral, SOAPBuildersInterop::MappingRegistry ) 
#    soapAry.sparse = true
#    var = drv.echoFloatArray( soapAry )
#    dumpNormal( title, arg, var )
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echoStruct'
  dumpTitle( title )
  begin
    arg = SOAPStruct.new( 1, 1.1, "a" )
    var = drv.echoStruct( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoStruct (nil members)'
  dumpTitle( title )
  begin
    arg = SOAPStruct.new( nil, nil, nil )
    var = drv.echoStruct( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoStructArray'
  dumpTitle( title )
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
  dumpTitle( title )
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

#  title = 'echoStructArray (sparse)'
#  dumpTitle( title )
#  begin
#    s1 = SOAPStruct.new( 1, 1.1, "a" )
#    s2 = SOAPStruct.new( 2, 2.2, "b" )
#    s3 = SOAPStruct.new( 3, 3.3, "c" )
#    arg = [ nil, s1, s2, s3 ]
#    soapAry = SOAP::RPCUtils.ary2soap( arg, TypeNS, "SOAPStruct", SOAPBuildersInterop::MappingRegistry ) 
#    soapAry.sparse = true
#    var = drv.echoStructArray( soapAry )
#    dumpNormal( title, arg, var ) 
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echoStructArray (multi-ref)'
  dumpTitle( title )
  begin
    s1 = SOAPStruct.new( 1, 1.1, "a" )
    s2 = SOAPStruct.new( 2, 2.2, "b" )
    arg = SOAPStructArray[ s1, s1, s2 ]
    var = drv.echoStructArray( arg )
    dumpNormal( title, arg, var ) 
  rescue Exception
    dumpException( title )
  end

  title = 'echoStructArray (multi-ref: elem1 == elem2)'
  dumpTitle( title )
  begin
    s1 = SOAPStruct.new( 1, 1.1, "a" )
    s2 = SOAPStruct.new( 2, 2.2, "b" )
    arg = SOAPStructArray[ s1, s1, s2 ]
    var = drv.echoStructArray( arg )
    dumpNormal( title, getIdObj( var[0] ), getIdObj( var[1] )) 
  rescue Exception
    dumpException( title )
  end

  title = 'echoStructArray (anyType Array, multi-ref: elem2 == elem3)'
  dumpTitle( title )
  begin
    s1 = SOAPStruct.new( 1, 1.1, "a" )
    s2 = SOAPStruct.new( 2, 2.2, "b" )
    arg = [ s1, s2, s2 ]
    var = drv.echoStructArray( arg )
    dumpNormal( title, getIdObj( var[1] ), getIdObj( var[2] )) 
  rescue Exception
    dumpException( title )
  end

#  title = 'echoStructArray (sparse, multi-ref)'
#  dumpTitle( title )
#  begin
#    s1 = SOAPStruct.new( 1, 1.1, "a" )
#    s2 = SOAPStruct.new( 2, 2.2, "b" )
#    arg = [ nil, s1, nil, nil, s2, nil, s2 ]
#    soapAry = SOAP::RPCUtils.ary2soap( arg, TypeNS, "SOAPStruct", SOAPBuildersInterop::MappingRegistry ) 
#    soapAry.sparse = true
#    var = drv.echoStructArray( soapAry )
#    dumpNormal( title, arg, var ) 
#  rescue Exception
#    dumpException( title )
#  end

#  title = 'echoStructArray (sparse, multi-ref: elem5 == elem7)'
#  dumpTitle( title )
#  begin
#    s1 = SOAPStruct.new( 1, 1.1, "a" )
#    s2 = SOAPStruct.new( 2, 2.2, "b" )
#    arg = [ nil, s1, nil, nil, s2, nil, s2 ]
#    soapAry = SOAP::RPCUtils.ary2soap( arg, TypeNS, "SOAPStruct", SOAPBuildersInterop::MappingRegistry ) 
#    soapAry.sparse = true
#    var = drv.echoStructArray( soapAry )
#    dumpNormal( title, getIdObj( var[4] ), getIdObj( var[6] )) 
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echoStructArray (multi-ref: varString of elem1 == varString of elem2)'
  dumpTitle( title )
  begin
    str1 = "a"
    str2 = "a"
    s1 = SOAPStruct.new( 1, 1.1, str1 )
    s2 = SOAPStruct.new( 2, 2.2, str1 )
    s3 = SOAPStruct.new( 3, 3.3, str2 )
    arg = SOAPStructArray[ s1, s2, s3 ]
    var = drv.echoStructArray( arg )
    dumpNormal( title, getIdObj( var[0].varString ), getIdObj( var[1].varString )) 
  rescue Exception
    dumpException( title )
  end

  title = 'echoStructArray (anyType Array, multi-ref: varString of elem2 == varString of elem3)'
  dumpTitle( title )
  begin
    str1 = "b"
    str2 = "b"
    s1 = SOAPStruct.new( 1, 1.1, str2 )
    s2 = SOAPStruct.new( 2, 2.2, str1 )
    s3 = SOAPStruct.new( 3, 3.3, str1 )
    arg = [ s1, s2, s3 ]
    var = drv.echoStructArray( arg )
    dumpNormal( title, getIdObj( var[1].varString ), getIdObj( var[2].varString )) 
  rescue Exception
    dumpException( title )
  end

#  title = 'echoStructArray (sparse, multi-ref: varString of elem5 == varString of elem7)'
#  dumpTitle( title )
#  begin
#    str1 = "c"
#    str2 = "c"
#    s1 = SOAPStruct.new( 1, 1.1, str2 )
#    s2 = SOAPStruct.new( 2, 2.2, str1 )
#    s3 = SOAPStruct.new( 3, 3.3, str1 )
#    arg = [ nil, s1, nil, nil, s2, nil, s3 ]
#    soapAry = SOAP::RPCUtils.ary2soap( arg, TypeNS, "SOAPStruct", SOAPBuildersInterop::MappingRegistry ) 
#    soapAry.sparse = true
#    var = drv.echoStructArray( soapAry )
#    dumpNormal( title, getIdObj( var[4].varString ), getIdObj( var[6].varString )) 
#  rescue Exception
#    dumpException( title )
#  end

#  title = 'echoStructArray (2D Array)'
#  dumpTitle( title )
#  begin
#    s1 = SOAPStruct.new( 1, 1.1, "a" )
#    s2 = SOAPStruct.new( 2, 2.2, "b" )
#    s3 = SOAPStruct.new( 3, 3.3, "c" )
#    arg = [
#      [ s1, nil, s2 ],
#      [ nil, s2, s3 ],
#    ]
#    md = SOAP::RPCUtils.ary2md( arg, 2, XSD::Namespace, XSD::AnyTypeLiteral, SOAPBuildersInterop::MappingRegistry )
#
#    var = drv.echoStructArray( md )
#    dumpNormal( title, arg, var ) 
#  rescue Exception
#    dumpException( title )
#  end
#
#  title = 'echoStructArray (2D Array, sparse)'
#  dumpTitle( title )
#  begin
#    s1 = SOAPStruct.new( 1, 1.1, "a" )
#    s2 = SOAPStruct.new( 2, 2.2, "b" )
#    s3 = SOAPStruct.new( 3, 3.3, "c" )
#    arg = [
#      [ s1, nil, s2 ],
#      [ nil, s2, s3 ],
#    ]
#    md = SOAP::RPCUtils.ary2md( arg, 2, TypeNS, "SOAPStruct", SOAPBuildersInterop::MappingRegistry )
##    md.sparse = true
#
#    var = drv.echoStructArray( md )
#    dumpNormal( title, arg, var ) 
#  rescue Exception
#    dumpException( title )
#  end
#
#  title = 'echoStructArray (anyType, 2D Array, sparse)'
#  dumpTitle( title )
#  begin
#    s1 = SOAPStruct.new( 1, 1.1, "a" )
#    s2 = SOAPStruct.new( 2, 2.2, "b" )
#    s3 = SOAPStruct.new( 3, 3.3, "c" )
#    arg = [
#      [ s1, nil, s2 ],
#      [ nil, s2, s3 ],
#    ]
#    md = SOAP::RPCUtils.ary2md( arg, 2, XSD::Namespace, XSD::AnyTypeLiteral, SOAPBuildersInterop::MappingRegistry )
#    md.sparse = true
#
#    var = drv.echoStructArray( md )
#    dumpNormal( title, arg, var ) 
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echoDate (now)'
  dumpTitle( title )
  begin
    t = Time.now.gmtime
    arg = DateTime.new( t.year, t.mon, t.mday, t.hour, t.min, t.sec )
    var = drv.echoDate( arg )
    dumpNormal( title, arg.to_s, var.to_s )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDate (before 1970: 1-01-01T00:00:00Z)'
  dumpTitle( title )
  begin
    t = Time.now.gmtime
    arg = DateTime.new( 1, 1, 1, 0, 0, 0 )
    var = drv.echoDate( arg )
    dumpNormal( title, arg.to_s, var.to_s )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDate (after 2038: 2038-12-31T00:00:00Z)'
  dumpTitle( title )
  begin
    t = Time.now.gmtime
    arg = DateTime.new( 2038, 12, 31, 0, 0, 0 )
    var = drv.echoDate( arg )
    dumpNormal( title, arg.to_s, var.to_s )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDate (negative: -10-01-01T00:00:00Z)'
  dumpTitle( title )
  begin
    t = Time.now.gmtime
    arg = DateTime.new( -10, 1, 1, 0, 0, 0 )
    var = drv.echoDate( arg )
    dumpNormal( title, arg.to_s, var.to_s )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDate (time precision: msec)'
  dumpTitle( title )
  begin
    arg = SOAP::SOAPDateTime.new( '2001-06-16T18:13:40.012' )
    argDate = arg.data
    var = drv.echoDate( arg )
    dumpNormal( title, argDate, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDate (time precision: long)'
  dumpTitle( title )
  begin
    arg = SOAP::SOAPDateTime.new( '2001-06-16T18:13:40.0000000000123456789012345678900000000000' )
    argDate = arg.data
    var = drv.echoDate( arg )
    dumpNormal( title, argDate, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDate (client side TZ conversion)'
  dumpTitle( title )
  begin
    arg = SOAP::SOAPDateTime.new( '2001-06-16T18:13:40-07:00' )
    argNormalized = DateTime.new( 2001, 6, 17, 1, 13, 40 )
    var = drv.echoDate( arg )
    dumpNormal( title, argNormalized.to_s, var.to_s )
  rescue Exception
    dumpException( title )
  end

  title = 'echoBase64 (xsd:base64Binary)'
  dumpTitle( title )
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
  dumpTitle( title )
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
  dumpTitle( title )
  begin
    str = "Hello (日本語Japanese) こんにちは"
    arg = SOAP::SOAPBase64.new( str )
    var = drv.echoBase64( arg )
    dumpNormal( title, str, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoHexBinary'
  dumpTitle( title )
  begin
    str = "Hello (日本語Japanese) こんにちは"
    arg = SOAP::SOAPHexBinary.new( str )
    var = drv.echoHexBinary( arg )
    dumpNormal( title, str, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoHexBinary(empty)'
  dumpTitle( title )
  begin
    str = ""
    arg = SOAP::SOAPHexBinary.new( str )
    var = drv.echoHexBinary( arg )
    dumpNormal( title, str, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoBoolean (true)'
  dumpTitle( title )
  begin
    arg = true
    var = drv.echoBoolean( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoBoolean (false)'
  dumpTitle( title )
  begin
    arg = false
    var = drv.echoBoolean( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

#  title = 'echoDouble'
#  dumpTitle( title )
#  begin
#    arg = 3.14159265358979
#    var = drv.echoDouble( arg )
#    dumpNormal( title, arg, var )
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echoDecimal (123456)'
  dumpTitle( title )
  begin
    arg = "12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
    var = drv.echoDecimal( SOAP::SOAPDecimal.new( arg ))
    normalized = arg
    dumpNormal( title, normalized, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDecimal (+0.123)'
  dumpTitle( title )
  begin
    arg = "+0.12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
    var = drv.echoDecimal( SOAP::SOAPDecimal.new( arg ))
    normalized = arg.sub( /0$/, '' ).sub( /^\+/, '' )
    dumpNormal( title, normalized, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDecimal (.00000123)'
  dumpTitle( title )
  begin
    arg = ".0000012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
    var = drv.echoDecimal( SOAP::SOAPDecimal.new( arg ))
    normalized = '0' << arg.sub( /0$/, '' )
    dumpNormal( title, normalized, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDecimal (-123.456)'
  dumpTitle( title )
  begin
    arg = "-12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123.45678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789"
    var = drv.echoDecimal( SOAP::SOAPDecimal.new( arg ))
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoDecimal (-123.)'
  dumpTitle( title )
  begin
    arg = "-12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890."
    normalized = arg.sub( /\.$/, '' )
    var = drv.echoDecimal( SOAP::SOAPDecimal.new( arg ))
    dumpNormal( title, normalized, var )
  rescue Exception
    dumpException( title )
  end


unless $noEchoMap

  title = 'echoMap'
  dumpTitle( title )
  begin
    arg = { "a" => 1, "b" => 2 }
    var = drv.echoMap( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoMap (boolean, base64, nil, float)'
  dumpTitle( title )
  begin
    arg = { true => "\0", "\0" => nil, nil => 0.0001, 0.0001 => false }
    var = drv.echoMap( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoMap (multibyte char)'
  dumpTitle( title )
  begin
    arg = { "Hello (日本語Japanese) こんにちは" => 1, 1 => "Hello (日本語Japanese) こんにちは" }
    var = drv.echoMap( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoMap (Struct)'
  dumpTitle( title )
  begin
    obj = SOAPStruct.new( 1, 1.1, "a" )
    arg = { 1 => obj, 2 => obj }
    var = drv.echoMap( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoMap (multi-ref: value for key "a" == value for key "b")'
  dumpTitle( title )
  begin
    value = "c"
    arg = { "a" => value, "b" => value }
    var = drv.echoMap( arg )
    dumpNormal( title, getIdObj( var["a"] ), getIdObj( var["b"] ))
  rescue Exception
    dumpException( title )
  end

  title = 'echoMap (Struct, multi-ref: varString of a key == varString of a value)'
  dumpTitle( title )
  begin
    str = ""
    obj = SOAPStruct.new( 1, 1.1, str )
    arg = { obj => "1", "1" => obj }
    var = drv.echoMap( arg )
    dumpNormal( title, getIdObj( var.index("1").varString ), getIdObj( var.fetch("1").varString ))
  rescue Exception
    dumpException( title )
  end

  title = 'echoMapArray'
  dumpTitle( title )
  begin
    map1 = { "a" => 1, "b" => 2 }
    map2 = { "a" => 1, "b" => 2 }
    map3 = { "a" => 1, "b" => 2 }
    arg = [ map1, map2, map3 ]
    var = drv.echoMapArray( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoMapArray (boolean, base64, nil, float)'
  dumpTitle( title )
  begin
    map1 = { true => "\0", "\0" => nil, nil => 0.0001, 0.0001 => false }
    map2 = { true => "\0", "\0" => nil, nil => 0.0001, 0.0001 => false }
    map3 = { true => "\0", "\0" => nil, nil => 0.0001, 0.0001 => false }
    arg = [ map1, map2, map3 ]
    var = drv.echoMapArray( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

#  title = 'echoMapArray (sparse)'
#  dumpTitle( title )
#  begin
#    map1 = { "a" => 1, "b" => 2 }
#    map2 = { "a" => 1, "b" => 2 }
#    map3 = { "a" => 1, "b" => 2 }
#    arg = [ nil, nil, map1, nil, map2, nil, map3, nil, nil ]
#    soapAry = SOAP::RPCUtils.ary2soap( arg, ApacheNS, "Map", SOAPBuildersInterop::MappingRegistry ) 
#    soapAry.sparse = true
#    var = drv.echoMapArray( soapAry )
#    dumpNormal( title, arg, var )
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echoMapArray (multibyte char)'
  dumpTitle( title )
  begin
    map1 = { "Hello (日本語Japanese) こんにちは" => 1, 1 => "Hello (日本語Japanese) こんにちは" }
    map2 = { "Hello (日本語Japanese) こんにちは" => 1, 1 => "Hello (日本語Japanese) こんにちは" }
    map3 = { "Hello (日本語Japanese) こんにちは" => 1, 1 => "Hello (日本語Japanese) こんにちは" }
    arg = [ map1, map2, map3 ]
    var = drv.echoMapArray( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

#  title = 'echoMapArray (sparse, multi-ref)'
#  dumpTitle( title )
#  begin
#    map1 = { "a" => 1, "b" => 2 }
#    map2 = { "a" => 1, "b" => 2 }
#    arg = [ nil, nil, map1, nil, map2, nil, map1, nil, nil ]
#    soapAry = SOAP::RPCUtils.ary2soap( arg, ApacheNS, "Map", SOAPBuildersInterop::MappingRegistry ) 
#    soapAry.sparse = true
#    var = drv.echoMapArray( soapAry )
#    dumpNormal( title, arg, var )
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echoMapArray (multi-ref: elem1 == elem2)'
  dumpTitle( title )
  begin
    map1 = { "a" => 1, "b" => 2 }
    map2 = { "a" => 1, "b" => 2 }
    arg = [ map1, map1, map2 ]
    var = drv.echoMapArray( arg )
    dumpNormal( title, getIdObj( var[0] ), getIdObj( var[1] ))
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
  dumpTitle( title )
  begin
    arg = SOAPStruct.new( 1, 1.1, "a" )
    ret, out1, out2 = drv.echoStructAsSimpleTypes( arg )
    var = SOAPStruct.new( out1, out2, ret )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoStructAsSimpleTypes (nil)'
  dumpTitle( title )
  begin
    arg = SOAPStruct.new( nil, nil, nil )
    ret, out1, out2 = drv.echoStructAsSimpleTypes( arg )
    var = SOAPStruct.new( out1, out2, ret )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoSimpleTypesAsStruct'
  dumpTitle( title )
  begin
    arg = SOAPStruct.new( 1, 1.1, "a" )
    var = drv.echoSimpleTypesAsStruct( arg.varString, arg.varInt, arg.varFloat )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoSimpleTypesAsStruct (nil)'
  dumpTitle( title )
  begin
    arg = SOAPStruct.new( nil, nil, nil )
    var = drv.echoSimpleTypesAsStruct( arg.varString, arg.varInt, arg.varFloat )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echo2DStringArray'
  dumpTitle( title )
  begin

#    arg = SOAP::SOAPArray.new( XSD::StringLiteral, 2 )
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

    arg = SOAP::SOAPArray.new( XSD::StringLiteral, 2 )
    arg.typeNamespace = XSD::Namespace
    arg.size = [ 3, 3 ]
    arg.sizeFixed = true
    arg.add( SOAP::RPCUtils.obj2soap( 'r0c0', SOAPBuildersInterop::MappingRegistry ))
    arg.add( SOAP::RPCUtils.obj2soap( 'r1c0', SOAPBuildersInterop::MappingRegistry ))
    arg.add( SOAP::RPCUtils.obj2soap( 'r2c0', SOAPBuildersInterop::MappingRegistry ))
    arg.add( SOAP::RPCUtils.obj2soap( 'r0c1', SOAPBuildersInterop::MappingRegistry ))
    arg.add( SOAP::RPCUtils.obj2soap( 'r1c1', SOAPBuildersInterop::MappingRegistry ))
    arg.add( SOAP::RPCUtils.obj2soap( 'r2c1', SOAPBuildersInterop::MappingRegistry ))
    arg.add( SOAP::RPCUtils.obj2soap( 'r0c2', SOAPBuildersInterop::MappingRegistry ))
    arg.add( SOAP::RPCUtils.obj2soap( 'r1c2', SOAPBuildersInterop::MappingRegistry ))
    arg.add( SOAP::RPCUtils.obj2soap( 'r2c2', SOAPBuildersInterop::MappingRegistry ))
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
  dumpTitle( title )
  begin
    # ary2md converts Arry ((of Array)...) into M-D anyType Array
    arg = [
      [ 'r0c0', 'r0c1', 'r0c2' ],
      [ 'r1c0', 'r1c1', 'r1c2' ],
      [ 'r2c0', 'r0c1', 'r2c2' ],
    ]

    var = drv.echo2DStringArray( SOAP::RPCUtils.ary2md( arg, 2, XSD::Namespace, XSD::AnyTypeLiteral, SOAPBuildersInterop::MappingRegistry ))
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

#  title = 'echo2DStringArray (sparse)'
#  dumpTitle( title )
#  begin
#    # ary2md converts Arry ((of Array)...) into M-D anyType Array
#    arg = [
#      [ 'r0c0', nil,    'r0c2' ],
#      [ nil,    'r1c1', 'r1c2' ],
#    ]
#    md = SOAP::RPCUtils.ary2md( arg, 2, XSD::Namespace, XSD::StringLiteral, SOAPBuildersInterop::MappingRegistry )
#    md.sparse = true
#
#    var = drv.echo2DStringArray( md )
#    dumpNormal( title, arg, var )
#  rescue Exception
#    dumpException( title )
#  end

#  title = 'echo2DStringArray (anyType, sparse)'
#  dumpTitle( title )
#  begin
#    # ary2md converts Arry ((of Array)...) into M-D anyType Array
#    arg = [
#      [ 'r0c0', nil,    'r0c2' ],
#      [ nil,    'r1c1', 'r1c2' ],
#    ]
#    md = SOAP::RPCUtils.ary2md( arg, 2, XSD::Namespace, XSD::StringLiteral, SOAPBuildersInterop::MappingRegistry )
#    md.sparse = true
#
#    var = drv.echo2DStringArray( md )
#    dumpNormal( title, arg, var )
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echo2DStringArray (multi-ref)'
  dumpTitle( title )
  begin
    arg = SOAP::SOAPArray.new( XSD::StringLiteral, 2 )
    arg.typeNamespace = XSD::Namespace
    arg.size = [ 3, 3 ]
    arg.sizeFixed = true

    item = 'item'
    arg.add( 'r0c0' )
    arg.add( 'r1c0' )
    arg.add( item )
    arg.add( 'r0c1' )
    arg.add( 'r1c1' )
    arg.add( 'r2c1' )
    arg.add( item )
    arg.add( 'r1c2' )
    arg.add( 'r2c2' )
    argNormalized = [
      [ 'r0c0', 'r1c0', 'item' ],
      [ 'r0c1', 'r1c1', 'r2c1' ],
      [ 'item', 'r1c2', 'r2c2' ],
    ]

    var = drv.echo2DStringArray( arg )
    dumpNormal( title, argNormalized, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echo2DStringArray (multi-ref: ele[2, 0] == ele[0, 2])'
  dumpTitle( title )
  begin
    arg = SOAP::SOAPArray.new( XSD::StringLiteral, 2 )
    arg.typeNamespace = XSD::Namespace
    arg.size = [ 3, 3 ]
    arg.sizeFixed = true

    item = 'item'
    arg.add( 'r0c0' )
    arg.add( 'r1c0' )
    arg.add( item )
    arg.add( 'r0c1' )
    arg.add( 'r1c1' )
    arg.add( 'r2c1' )
    arg.add( item )
    arg.add( 'r1c2' )
    arg.add( 'r2c2' )

    var = drv.echo2DStringArray( arg )
    dumpNormal( title, getIdObj( var[ 2 ][ 0 ] ), getIdObj( var[ 0 ][ 2 ] ))
  rescue Exception
    dumpException( title )
  end

#  title = 'echo2DStringArray (sparse, multi-ref)'
#  dumpTitle( title )
#  begin
#    # ary2md converts Arry ((of Array)...) into M-D anyType Array
#    str = "BANG!"
#    arg = [
#      [ 'r0c0', nil, str    ],
#      [ nil,    str, 'r1c2' ],
#    ]
#    md = SOAP::RPCUtils.ary2md( arg, 2, XSD::Namespace, XSD::StringLiteral, SOAPBuildersInterop::MappingRegistry )
#    md.sparse = true
#
#    var = drv.echo2DStringArray( md )
#    dumpNormal( title, arg, var )
#  rescue Exception
#    dumpException( title )
#  end

  title = 'echoNestedStruct'
  dumpTitle( title )
  begin
    arg = SOAPStructStruct.new( 1, 1.1, "a",
      SOAPStruct.new( 2, 2.2, "b" )
    )
    var = drv.echoNestedStruct( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoNestedStruct (nil)'
  dumpTitle( title )
  begin
    arg = SOAPStructStruct.new( nil, nil, nil,
      SOAPStruct.new( nil, nil, nil )
    )
    var = drv.echoNestedStruct( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoNestedStruct (multi-ref: varString of StructStruct == varString of Struct)'
  dumpTitle( title )
  begin
    str1 = ""
    arg = SOAPStructStruct.new( 1, 1.1, str1,
      SOAPStruct.new( 2, 2.2, str1 )
    )
    var = drv.echoNestedStruct( arg )
    dumpNormal( title, getIdObj( var.varString ), getIdObj( var.varStruct.varString ))
  rescue Exception
    dumpException( title )
  end

  title = 'echoNestedArray'
  dumpTitle( title )
  begin
    arg = SOAPArrayStruct.new( 1, 1.1, "a", StringArray[ "2", "2.2", "b" ] )
    var = drv.echoNestedArray( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoNestedArray (anyType array)'
  dumpTitle( title )
  begin
    arg = SOAPArrayStruct.new( 1, 1.1, "a", [ "2", "2.2", "b" ] )
    var = drv.echoNestedArray( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoNestedArray (multi-ref)'
  dumpTitle( title )
  begin
    str = ""
    arg = SOAPArrayStruct.new( 1, 1.1, str, StringArray[ "2", str, "b" ] )
    var = drv.echoNestedArray( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoNestedArray (multi-ref: varString == varArray[1])'
  dumpTitle( title )
  begin
    str = ""
    arg = SOAPArrayStruct.new( 1, 1.1, str, StringArray[ "2", str, "b" ] )
    var = drv.echoNestedArray( arg )
    dumpNormal( title, getIdObj( var.varString ), getIdObj( var.varArray[1] ))
  rescue Exception
    dumpException( title )
  end

#  title = 'echoNestedArray (sparse, multi-ref)'
#  dumpTitle( title )
#  begin
#    str = "!"
#    subAry = [ nil, nil, str, nil, str, nil ]
#    ary = SOAP::RPCUtils.ary2soap( subAry, XSD::Namespace, XSD::StringLiteral, SOAPBuildersInterop::MappingRegistry ) 
#    ary.sparse = true
#    arg = SOAPArrayStruct.new( 1, 1.1, str, ary )
#    argNormalized = SOAPArrayStruct.new( 1, 1.1, str, subAry )
#    var = drv.echoNestedArray( arg )
#    dumpNormal( title, argNormalized, var )
#  rescue Exception
#    dumpException( title )
#  end

=begin
  title = 'echoXSDDateTime'
  dumpTitle( title )
  begin
    arg = DateTime.new( 1000, 1, 1, 1, 1, 1 )
    var = drv.echoXSDDateTime( arg )
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoXSDDate'
  dumpTitle( title )
  begin
    arg = DateTime.new( 1000, 1, 1 )
    var = drv.echoXSDDate( SOAP::SOAPDate.new( arg ))
    dumpNormal( title, arg, var )
  rescue Exception
    dumpException( title )
  end

  title = 'echoXSDTime'
  dumpTitle( title )
  begin
    arg = Time.now.gmtime
    var = drv.echoXSDTime( SOAP::SOAPTime.new( arg ))
    dumpNormal( title, SOAP::SOAPTime.new( arg ).to_s, SOAP::SOAPTime.new( var ).to_s )
  rescue Exception
    dumpException( title )
  end
=end

end
