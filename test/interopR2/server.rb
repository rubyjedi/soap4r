#!/usr/bin/env ruby

$KCODE = "UTF8"      # Set $KCODE before loading 'soap/xmlparser'.

#require 'soap/nqxmlparser'
#require 'soap/rexmlparser'
require 'soap/standaloneServer'
require 'base'

class InteropApp < SOAP::StandaloneServer

  def initialize( *arg )
    super( *arg )
    @router.mappingRegistry = SOAPBuildersInterop::MappingRegistry
  end

  def methodDef
    ( SOAPBuildersInterop::MethodsBase + SOAPBuildersInterop::MethodsGroupB + SOAPBuildersInterop::MethodsPolyMorph ).each do | methodName, *params |
      addMethod( self, methodName, params )
    end
  end

  def clone( obj )
    begin
      return Marshal.load( Marshal.dump( obj ))
    rescue TypeError
      return obj
    end
  end
  
  # In echoVoid, 'retval' is not defined.  So nothing will be returned.
  def echoVoid
    # return SOAP::RPCUtils::SOAPVoid.new
    return "Hello"
  end

  def echoString( inputString )
    clone( inputString )
  end

  def echoStringArray( inputStringArray )
    clone( inputStringArray )
  end

  def echoInteger( inputInteger )
    SOAP::SOAPInt.new( clone( inputInteger ))
  end

  def echoIntegerArray( inputIntegerArray )
    clone( inputIntegerArray )
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
    clone( inputStruct )
  end

  def echoStructArray( inputStructArray )
    clone( inputStructArray )
  end

  def echoDate( inputDate )
    clone( inputDate )
  end

  def echoBase64( inputBase64 )
    o = SOAP::SOAPBase64.new( clone( inputBase64 ))
    o.asXSD
    o
  end

  def echoHexBinary( inputHexBinary )
    SOAP::SOAPHexBinary.new( clone( inputHexBinary ))
  end

  def echoDouble( inputDouble )
    SOAP::SOAPDouble.new( inputDouble )
  end

  # for Round 2 group B
  def echoStructAsSimpleTypes( inputStruct )
    outputString = inputStruct.varString
    outputInteger = inputStruct.varInt
    outputFloat = inputStruct.varFloat
    # retVal is not returned to SOAP client because retVal of this method is
    #   not defined in method definition.
    # retVal, out, out, out
    return nil, outputString, outputInteger, outputFloat
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
    clone( inputStruct )
  end

  def echoNestedArray( inputStruct )
    clone( inputStruct )
  end

  def echoBoolean( inputBoolean )
    inputBoolean
  end

  def echoDouble( inputDouble )
    # inputDouble.is_a? Float
    clone( inputDouble )
  end

  def echoDecimal( inputDecimal )
    # inputDecimal.is_a? String
    SOAP::SOAPDecimal.new( inputDecimal.to_s )
  end

  def echoMap( inputMap )
    clone( inputMap )
  end

  def echoMapArray( inputMapArray )
    clone( inputMapArray )
  end

  def echoXSDDateTime( inputXSDDateTime )
    clone( inputXSDDateTime )
  end

  def echoXSDDate( inputXSDDate )
    SOAP::SOAPDate.new( clone( inputXSDDate ))
  end

  def echoXSDTime( inputXSDTime )
    SOAP::SOAPTime.new( clone( inputXSDTime ))
  end

  def echoPolyMorph( anObject )
    clone( anObject )
  end

  alias echoPolyMorphStruct echoPolyMorph
  alias echoPolyMorphArray echoPolyMorph
end

InteropApp.new( 'InteropApp', InterfaceNS, '0.0.0.0', 10080 ).start
