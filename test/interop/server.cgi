#!/usr/bin/env ruby


require 'soap/cgistub'
require 'soap/rpcUtils'
require 'base'

LogFile = './log'

class InteropApp < SOAP::CGIStub
  include RPCUtils

  def initialize( *arg )
    super( *arg )
    setLog( LogFile, 'weekly' )
    @router.mappingRegistry = MappingRegistry
  end

  def methodDef
    addMethod( self, 'echoVoid' )
    addMethod( self, 'echoString' )
    addMethod( self, 'echoStringArray' )
    addMethod( self, 'echoInteger' )
    addMethod( self, 'echoIntegerArray' )
    addMethod( self, 'echoFloat' )
    addMethod( self, 'echoFloatArray' )
    addMethod( self, 'echoStruct' )
    addMethod( self, 'echoStructArray' )
    addMethod( self, 'echoDate' )
    addMethod( self, 'echoBase64' )
    addMethod( self, 'echoDouble' )

    addMethod( self, 'echo2DStringArray' )
    addMethod( self, 'echoNestedStruct' )
    addMethod( self, 'echoArrayStruct' )
  end
  
  def echoVoid
    SOAP::RPCUtils::SOAPVoid.new
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
    inputFloatArray.collect { | f |
      SOAPFloat.new( f )
    }
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
    SOAP::SOAPBase64.new( inputBase64String.clone )
  end

  def echoDouble( inputDouble )
    SOAP::SOAPDouble.new( inputDouble )
  end

  # for Round 2 group B
  def echo2DStringArray( ary )
    # In Ruby, M-D Array is converted to Array of Array now.
    ary2md( ary, 2 )
  end

  def echoNestedStruct( inputStruct )
    inputStruct.clone
  end

  def echoArrayStruct( inputStruct )
    inputStruct.clone
  end
end

InteropApp.new( "InteropApp", InterfaceNS ).start
