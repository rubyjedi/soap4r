#!/usr/bin/env ruby

require 'soap/cgistub'
require 'base'

LogFile = './log'

class InteropApp < SOAP::CGIStub
  def initialize( *arg )
    super( *arg )
    setLog( LogFile, 'weekly' )
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
  end
  
  def echoVoid
    nil		# Every sentence has a value in Ruby...
  end

  def echoString( inputString )
    inputString.dup
  end

  def echoStringArray( inputStringArray )
    inputStringArray.dup
  end

  def echoInteger( inputInteger )
    inputInteger.dup
  end

  def echoIntegerArray( inputIntegerArray )
    inputIntegerArray.dup
  end

  def echoFloat( inputFloat )
    inputFloat.dup
  end

  def echoFloatArray( inputFloatArray )
    inputFloatArray.dup
  end

  def echoStruct( inputStruct )
    inputStruct.dup
  end

  def echoStructArray( inputStructArray )
    inputStructArray.dup
  end

  def echoDate( inputDate )
    inputDate.dup
  end

  def echoBase64( inputBase64String )
    SOAP::SOAPBase64.new( inputBase64String.dup )
  end
end

InteropApp.new( "InteropApp", InterfaceNS ).start
