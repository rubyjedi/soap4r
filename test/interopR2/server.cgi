#!/usr/bin/env ruby

$KCODE = "UTF8"      # Set $KCODE before loading 'soap/xmlparser'.

require 'soap/cgistub'
require 'soap/rpcUtils'
require 'base'

LogFile = './log'

class InteropApp < SOAP::CGIStub
  include RPCUtils

  def initialize( *arg )
    super( *arg )
    setLog( LogFile, 'weekly' )
    @router.mappingRegistry = SOAPBuildersInterop::MappingRegistry
  end

  def methodDef
    ( SOAPBuildersInterop::MethodsBase + SOAPBuildersInterop::MethodsGroupB ).each do | methodName, *params |
      addMethod( self, methodName, params )
    end
  end
  
  # In echoVoid, 'retval' is not defined.  So nothing will be returned.
  def echoVoid
    # SOAP::RPCUtils::SOAPVoid.new
    return "Hello"
  end

  def echoString( inputString )
    inputString.clone
  end

  def echoStringArray( inputStringArray )
    inputStringArray.clone
  end

  def echoInteger( inputInteger )
    SOAP::SOAPInt.new( inputInteger.clone )
  end

  def echoIntegerArray( inputIntegerArray )
    inputIntegerArray.clone
  end

  def echoFloat( inputFloat )
    SOAPFloat.new( inputFloat )
  end

  def echoFloatArray( inputFloatArray )
    outArray = SOAPBuildersInterop::FloatArray.new
    inputFloatArray.each do | f |
      outArray << SOAPFloat.new( f )
    end
    outArray
  end

  def echoStruct( inputStruct )
    inputStruct.clone
  end

  def echoStructArray( inputStructArray )
    inputStructArray.clone
  end

  def echoDate( inputDate )
    inputDate.clone
  end

  def echoBase64( inputBase64String )
    o = SOAP::SOAPBase64.new( inputBase64String.clone )
    o.asXSD
    o
  end

  def echoDouble( inputDouble )
    SOAP::SOAPDouble.new( inputDouble )
  end

  # for Round 2 group B
  def echoStructAsSimpleTypes( inputStruct )
    outputString = inputStruct.varString
    outputInteger = inputStruct.varInt
    outputFloat = inputStruct.varFloat
    return outputString, outputInteger, outputFloat
  end

  def echoSimpleTypesAsStruct( inputString, inputInt, inputFloat )
    SOAPBuildersInterop::SOAPStruct.new( inputInt, inputFloat, inputString )
  end

  def echo2DStringArray( ary )
    # In Ruby, M-D Array is converted to Array of Array now.
    mdary = SOAP::RPCUtils.ary2md( ary, 2 )
    if mdary.include?( nil )
      mdary.sparse = true
    end
    mdary
  end

  def echoNestedStruct( inputStruct )
    inputStruct.clone
  end

  def echoNestedArray( inputStruct )
    inputStruct.clone
  end

  def echoBoolean( inputBoolean )
    inputBoolean
  end

  def echoDouble( inputDouble )
    # inputDouble.is_a? Float
    inputDouble.dup
  end

  def echoDecimal( inputDecimal )
    # inputDecimal.is_a? String
    SOAP::SOAPDecimal.new( inputDecimal.to_s )
  end

  def echoXSDDateTime( inputXSDDateTime )
    inputXSDDateTime.dup
  end

  def echoXSDDate( inputXSDDate )
    SOAP::SOAPDate.new( inputXSDDate.dup )
  end

  def echoXSDTime( inputXSDTime )
    SOAP::SOAPTime.new( inputXSDTime.dup )
  end
end

InteropApp.new( "InteropApp", InterfaceNS ).start
