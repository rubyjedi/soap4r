=begin
SOAP4R - RPC utility -- Mapping registry.
Copyright (C) 2000, 2001 NAKAMURA Hiroshi.

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PRATICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 675 Mass
Ave, Cambridge, MA 02139, USA.
=end

require 'soap/baseData'
require 'soap/charset'


module SOAP


module Marshallable
  @@typeNamespace = RPCUtils::RubyCustomTypeNamespace

  def getInstanceVariables
    if block_given?
      self.instance_variables.each do | key |
	yield( key, eval( key ))
      end
    else
      self.instance_variables
    end
  end

  # Not used now...
  def setInstanceVariable( key, value )
    eval( "@#{ key } = value" )
  end
end


module RPCServerException; end


module RPCUtils
  # Inner class to pass an exception.
  class SOAPException; include Marshallable
    attr_reader :exceptionTypeName, :message, :backtrace
    def initialize( e )
      @exceptionTypeName = RPCUtils.getElementNameFromName( e.type.to_s )
      @message = e.message
      @backtrace = e.backtrace
    end

    def to_e
      klass = RPCUtils.getClassFromName( @exceptionTypeName.to_s )
      if klass.nil?
	raise RuntimeError.new( @message )
      end
      if !klass.ancestors.include?( Exception )
	raise NameError.new
      end
      obj = klass.new( @message )
      obj.extend( ::SOAP::RPCServerException )
      obj
    end

    def set_backtrace( e )
      e.set_backtrace(
	if @backtrace.is_a?( Array )
	  @backtrace
	else
	  [ @backtrace.inspect ]
	end
      )
    end
  end


  ###
  ## Ruby's obj <-> SOAP/OM mapping registry.
  #
  class Factory
    def obj2soap( soapKlass, obj, info, map )
      raise NotImplementError.new
      # return soapObj
    end

    def soap2obj( objKlass, node, info, map )
      raise NotImplementError.new
      # return convertSucceededOrNot, obj
    end

  protected

    def getTypeName( klass )
      if klass.class_variables.include?( "@@typeName" )
	klass.class_eval( "@@typeName" )
      else
	nil
      end
    end

    def getNamespace( klass )
      if klass.class_variables.include?( "@@typeNamespace" )
	klass.class_eval( "@@typeNamespace" )
      else
	nil
      end
    end

    if Object.respond_to?( :allocate )
      # ruby/1.7 or later.
      def createEmptyObject( klass )
	klass.allocate
      end
    else
      def createEmptyObject( klass )
	klass.module_eval <<-EOS
	  begin
	    alias __initialize initialize
	  rescue NameError
	  end
	  def initialize; end
	EOS
   	obj = klass.new
   	klass.module_eval <<-EOS
  	  undef initialize
  	  begin
  	    alias initialize __initialize
  	  rescue NameError
  	  end
   	EOS
   	obj
      end
    end

    # It breaks Thread.current[ :SOAPDataKey ].
    def setInstanceVariables( obj, values )
      values.each do | name, value |
	# obj.instance_eval( "@#{ name } = Thread.current[ :SOAPDataKey ]" )
	# Suggested by m_seki;
	obj.instance_eval( "@#{ name } = value" )
      end
    end

    # It breaks Thread.current[ :SOAPMarshalDataKey ].
    def markMarshalledObj( obj, soapObj )
      Thread.current[ :SOAPMarshalDataKey ][ obj.__id__ ] = soapObj
    end

    # It breaks Thread.current[ :SOAPMarshalDataKey ].
    def markUnmarshalledObj( node, obj )
      Thread.current[ :SOAPMarshalDataKey ][ node.id ] = obj
    end

    def toType( name )
      capitalize( name )
    end

    def capitalize( target )
      target.gsub('^([a-z])') { $1.tr!('[a-z]', '[A-Z]') }
    end
  end

  class BasetypeFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      soapObj = nil
      begin
	if soapKlass.ancestors.include?( XSD::XSDString )
	  if Charset.isCES( obj, $KCODE )
	    encoded = Charset.codeConv( obj, $KCODE, 'UTF8' )
	    soapObj = soapKlass.new( encoded )
	  else
	    soapObj = nil
	  end
	else
	  soapObj = soapKlass.new( obj )
	end
      rescue XSD::ValueSpaceError
	# Conversion failed.
	nil
      end

      if soapObj
	if soapObj.is_a?( SOAPString )
	  markMarshalledObj( obj, soapObj )
	else
	  # Should not be multiref-ed.
	end
      end
      soapObj
    end

    def soap2obj( objKlass, node, info, map )
      obj = if objKlass.ancestors.include?( ::String )
	  Charset.codeConv( node.data, 'UTF8', $KCODE )
	else
	  node.data
	end
      markUnmarshalledObj( node, obj )
      return true, obj
    end
  end

  class DateTimeFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      soapObj = begin
	  soapKlass.new( obj )
	rescue XSD::ValueSpaceError
	  # Conversion failed.
	  nil
	end
      markMarshalledObj( obj, soapObj ) if soapObj
      soapObj
    end

    def soap2obj( objKlass, node, info, map )
      obj = nil
      if objKlass == Time
	if node.data.sec_fraction.nonzero?
	  # Time can have usec but it may not have sufficient precision.
	  return false
	end
	obj = node.to_time
	if obj.nil?
	  # Is out of range as a Time
	  return false
	end
      elsif objKlass == Date
	obj = node.data
      else
	return false
      end
      markUnmarshalledObj( node, obj )
      return true, obj
    end
  end

  class Base64Factory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      soapObj = soapKlass.new( obj )
      markMarshalledObj( obj, soapObj ) if soapObj
      soapObj
    end

    def soap2obj( objKlass, node, info, map )
      obj = node.toString
      markUnmarshalledObj( node, obj )
      return true, obj
    end
  end

  class ArrayFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      if soapKlass != SOAP::SOAPArray
	return nil
      end

      # [ [1], [2] ] is converted to Array of Array, not 2-D Array.
      # To create M-D Array, you must call RPCUtils.ary2md.
      typeName = getTypeName( obj.type ) || obj.instance_eval( "@typeName" )
      typeNamespace = getNamespace( obj.type ) ||
	obj.instance_eval( "@typeNamespace" ) || RubyTypeNamespace
      unless typeName
	typeName = XSD::AnyTypeLiteral
	typeNamespace = XSD::Namespace
      end
      param = SOAPArray.new( typeName )
      markMarshalledObj( obj, param )
      param.typeNamespace = typeNamespace
      obj.each do | var |
	param.add( RPCUtils._obj2soap( var, map ))
      end
      param
    end

    def soap2obj( objKlass, node, info, map )
      if !node.is_a?( SOAPArray )
	return false
      end

      obj = []
      markUnmarshalledObj( node, obj )
      node.soap2array( obj ) { | elem |
	elem ? RPCUtils._soap2obj( elem, map ) : nil
      }
      obj.instance_eval( "@typeName = '#{ node.typeName }'; @typeNamespace = '#{ node.typeNamespace }'" )
      return true, obj
    end
  end

  class TypedArrayFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      typeName = info[1]
      typeNamespace = info[0]
      param = SOAPArray.new( typeName )
      markMarshalledObj( obj, param )
      param.typeNamespace = typeNamespace

      obj.each do | var |
	param.add( RPCUtils._obj2soap( var, map ))
      end
      param
    end

    def soap2obj( objKlass, node, info, map )
      if node.rank > 1
        return false
      end
      typeName = info[1]
      typeNamespace = info[0]
      if ( node.typeNamespace != typeNamespace ) ||
	  ( node.typeName != typeName )
	return false
      end

      obj = objKlass.new
      markUnmarshalledObj( node, obj )
      node.soap2array( obj ) do | elem |
	elem ? RPCUtils._soap2obj( elem, map ) : nil
      end
      return true, obj
    end
  end

  class TypedStructFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      typeName = info[1]
      typeNamespace = info[0]
      param = SOAPStruct.new( typeName  )
      markMarshalledObj( obj, param )
      param.typeNamespace = typeNamespace
      if obj.type.ancestors.member?( Marshallable )
	obj.getInstanceVariables do |var, data|
	  name = var.dup.sub!( /^@/, '' )
	  param.add( RPCUtils.getElementNameFromName( name ),
	    RPCUtils._obj2soap( data, map ))
	end
      else
        obj.instance_variables.each do |var|
	  name = var.dup.sub!( /^@/, '' )
	  param.add( RPCUtils.getElementNameFromName( name ),
	    RPCUtils._obj2soap( obj.instance_eval( var ), map ))
        end
      end
      param
    end

    def soap2obj( objKlass, node, info, map )
      typeName = info[1]
      typeNamespace = info[0]
      if ( node.typeNamespace != typeNamespace ) ||
	  ( node.typeName != typeName )
	return false
      end

      obj = createEmptyObject( objKlass )
      markUnmarshalledObj( node, obj )
      vars = Hash.new
      node.each do |name, value|
	vars[ RPCUtils.getNameFromElementName( name ) ] =
	  RPCUtils._soap2obj( value, map )
      end
      setInstanceVariables( obj, vars )
      return true, obj
    end
  end

  class HashFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      if !obj.is_a?( Hash )
	return nil
      end

      param = SOAPStruct.new( "Map" )
      markMarshalledObj( obj, param )
      param.typeNamespace = ApacheSOAPTypeNamespace
      i = 1
      obj.each do | key, value |
	elem = SOAPStruct.new # Undefined typeName.
     	elem.add( "key", RPCUtils._obj2soap( key, map ))
  	elem.add( "value", RPCUtils._obj2soap( value, map ))
	# param.add( "item#{ i }", elem )
     	# ApacheAxis allows only 'item' here.
  	param.add( "item", elem )
	i += 1
      end
      param
    end

    def soap2obj( objKlass, node, info, map )
      if !node.typeEqual( ApacheSOAPTypeNamespace, 'Map' )
	return false
      end

      obj = Hash.new
      markUnmarshalledObj( node, obj )
      node.each do | key, value |
	obj[ RPCUtils._soap2obj( value[ 'key' ], map ) ] =
     	  RPCUtils._soap2obj( value[ 'value' ], map )
      end
      return true, obj
    end
  end

  class RubytypeFactory_ < Factory
    TYPE_REGEXP = 'Regexp'
    TYPE_CLASS = 'Class'
    TYPE_MODULE = 'Module'
    TYPE_SYMBOL = 'Symbol'
    TYPE_STRUCT = 'Struct'
    TYPE_HASH = 'Map'

    def initialize( config = {} )
      @config = config
      @allowUntypedStruct = @config.has_key?( :allowUntypedStruct ) ?
	@config[ :allowUntypedStruct ] : true
    end

    def obj2soap( soapKlass, obj, info, map )
      case obj
      when Regexp
	typeName = TYPE_REGEXP
	param = SOAPStruct.new( typeName  )
	markMarshalledObj( obj, param )
	param.typeNamespace = RubyTypeNamespace
	param.add( 'source', SOAPBase64.new( obj.source ))
	if obj.respond_to?( 'options' )
	  # Regexp#options is from Ruby/1.7
	  param.add( 'options', SOAPString.new( obj.options ))
	end
	if obj.kcode
	  # Why Regexp#kcode returns lower case?  Deprecated?
	  param.add( 'kcode', SOAPString.new( obj.kcode.upcase ))
	end
	param
      when Hash
	typeName = TYPE_HASH
	param = SOAPStruct.new( typeName )
	markMarshalledObj( obj, param )
	param.typeNamespace = RubyTypeNamespace
	i = 1
	obj.each do | key, value |
	  elem = SOAPStruct.new	# Undefined typeName.
	  elem.add( "key", RPCUtils._obj2soap( key, map ))
	  elem.add( "value", RPCUtils._obj2soap( value, map ))
	  # param.add( "item#{ i }", elem )
	  # ApacheAxis allows only 'item' here.
	  param.add( "item", elem )
	  i += 1
	end
	param
      when Class
	if obj.name.empty?
	  # raise FactoryError.new( "Can't dump anonymous class #{ obj }." )
	  return nil
	end
	typeName = TYPE_CLASS
	param = SOAPStruct.new( typeName  )
	markMarshalledObj( obj, param )
	param.typeNamespace = RubyTypeNamespace
	param.add( 'name', SOAPString.new( obj.name ))
	param
      when Module
	if obj.name.empty?
	  # raise FactoryError.new( "Can't dump anonymous module #{ obj }." )
	  return nil
	end
	typeName = TYPE_MODULE
	param = SOAPStruct.new( typeName  )
	markMarshalledObj( obj, param )
	param.typeNamespace = RubyTypeNamespace
	param.add( 'name', SOAPString.new( obj.name ))
	param
      when Symbol
	typeName = TYPE_SYMBOL
	param = SOAPStruct.new( typeName  )
	markMarshalledObj( obj, param )
	param.typeNamespace = RubyTypeNamespace
	param.add( 'id', SOAPString.new( obj.id2name ))
	param
      when Exception
	typeName = RPCUtils.getElementNameFromName( obj.type.to_s )
	param = SOAPStruct.new( typeName )
	markMarshalledObj( obj, param )
	param.typeNamespace = RubyTypeNamespace
	param.add( 'message', RPCUtils._obj2soap( obj.message, map ))
	param.add( 'backtrace', RPCUtils._obj2soap( obj.backtrace, map ))
	obj.instance_variables.each do |var|
	  name = var.dup.sub!( /^@/, '' )
	  param.add( RPCUtils.getElementNameFromName( name ),
	    RPCUtils._obj2soap( obj.instance_eval( var ), map ))
	end
	param
      when Struct
	typeName = TYPE_STRUCT
	param = SOAPStruct.new( typeName )
	markMarshalledObj( obj, param )
	param.typeNamespace = RubyTypeNamespace
	param.add( 'type', typeElem = SOAPString.new( obj.type.to_s ))
	memberElem = SOAPStruct.new
	obj.members.each do |member|
	  memberElem.add( RPCUtils.getElementNameFromName( member ),
	    RPCUtils._obj2soap( obj[ member ], map ))
	end
	param.add( 'member', memberElem )
	param
      when IO, Binding, Continuation, Data, Dir, File::Stat, MatchData, Method,
  	  Proc, Thread, ThreadGroup 
	return nil
      when ::SOAP::RPCUtils::Object
	typeNamespace = XSD::Namespace
	typeName = XSD::AnyTypeLiteral
	param = SOAPStruct.new( typeName )
	markMarshalledObj( obj, param )
	param.typeNamespace = typeNamespace
      	obj.getInstanceVariables do |var, data|
	  name = var.dup.sub!( /^@/, '' )
	  param.add( RPCUtils.getElementNameFromName( name ),
	    RPCUtils._obj2soap( data, map ))
	end
	param
      else
	typeName = getTypeName( obj.type ) ||
	  RPCUtils.getElementNameFromName( obj.type.to_s )
	typeNamespace = getNamespace( obj.type ) || RubyCustomTypeNamespace
	param = SOAPStruct.new( typeName  )
	markMarshalledObj( obj, param )
	param.typeNamespace = typeNamespace
	if obj.type.ancestors.member?( Marshallable )
	  obj.getInstanceVariables do |var, data|
	    name = var.dup.sub!( /^@/, '' )
	    param.add( RPCUtils.getElementNameFromName( name ),
	      RPCUtils._obj2soap( data, map ))
	  end
	else
	  # Should not be marshalled?
	  obj.instance_variables.each do |var|
	    name = var.dup.sub!( /^@/, '' )
	    param.add( RPCUtils.getElementNameFromName( name ),
	      RPCUtils._obj2soap( obj.instance_eval( var ), map ))
	  end
	end
	param
      end
    end

    def soap2obj( objKlass, node, info, map )
      if node.typeNamespace == RubyTypeNamespace
	rubyType2obj( node, map )
      elsif node.typeEqual( XSD::Namespace, XSD::AnyTypeLiteral )
	anyType2obj( node, map )
      else
	unknownType2obj( node, map )
      end
    end

  private

    def rubyType2obj( node, map )
      obj = nil
      case node.typeName
      when TYPE_REGEXP
	source = node[ 'source' ].toString
	options = node.include?( 'options' ) ? node[ 'options' ].data : nil
	kcode = node.include?( 'kcode' ) ? node[ 'kcode' ].data : nil
	obj = kcode ? Regexp.new( source, options, kcode ) :
	  Regexp.new( source, options )
	markUnmarshalledObj( node, obj )
      when TYPE_HASH
	obj = Hash.new
	markUnmarshalledObj( node, obj )
	node.each do | key, value |
	  obj[ RPCUtils._soap2obj( value[ 'key' ], map ) ] =
	    RPCUtils._soap2obj( value[ 'value' ], map )
	end
      when TYPE_CLASS
	obj = RPCUtils.getClassFromName( node[ 'name' ].data )
      when TYPE_MODULE
	obj = RPCUtils.getClassFromName( node[ 'name' ].data )
      when TYPE_SYMBOL
	obj = node[ 'id' ].data.intern
      when TYPE_STRUCT
	typeName = RPCUtils.getNameFromElementName( node[ 'type' ] )
	begin
	  klass = RPCUtils.getClassFromName( typeName )
	  if klass.nil?
	    klass = self.instance_eval( toType( typeName ))
	  end
	  if !klass.ancestors.include?( ::Struct )
	    raise NameError.new
	  end
	  obj = klass.new
	  markUnmarshalledObj( node, obj )
	  node[ 'member'].each do | name, value |
	    obj[ RPCUtils.getNameFromElementName( name ) ] =
	      RPCUtils._soap2obj( value, map )
	  end
	rescue NameError
	  return false
	end
      else
	conv, obj = exception2obj( node, map )
	unless conv
	  return false
	end
      end
      return true, obj
    end

    def exception2obj( node, map )
      typeName = RPCUtils.getNameFromElementName( node.typeName )
      klass = RPCUtils.getClassFromName( typeName )
      if klass.nil?
	return false
      end
      if !klass.ancestors.include?( Exception )
	return false
      end
      message = RPCUtils._soap2obj( node[ 'message' ], map )
      backtrace = RPCUtils._soap2obj( node[ 'backtrace' ], map )
      obj = klass.new( message )
      markUnmarshalledObj( node, obj )
      obj.set_backtrace( backtrace )
      vars = Hash.new
      node.each do |name, value|
	if name != 'message' && name != 'backtrace'
	  vars[ RPCUtils.getNameFromElementName( name ) ] =
	    RPCUtils._soap2obj( value, map )
	end
      end
      setInstanceVariables( obj, vars )
      return true, obj
    end

    def anyType2obj( node, map )
      klass = Object	# SOAP::RPCUtils::Object
      obj = klass.new
      markUnmarshalledObj( node, obj )
      node.each do | name, value |
	obj.setProperty( name, RPCUtils._soap2obj( value, map ))
      end
      return true, obj
    end

    def unknownType2obj( node, map )
      obj = struct2obj( node, map )
      return true, obj if obj
      if !@allowUntypedStruct
	return false
      end
      return anyType2obj( node, map )
    end

    def struct2obj( node, map )
      obj = nil
      typeName = RPCUtils.getNameFromElementName( node.typeName )
      begin
	klass = RPCUtils.getClassFromName( typeName )
	if klass.nil?
	  klass = self.instance_eval( toType( typeName ))
       	end
	if ( getNamespace( klass ) and
	    ( getNamespace( klass ) != node.typeNamespace ))
	  raise NameError.new
	elsif ( getTypeName( klass ) and ( getTypeName( klass ) != typeName ))
	  raise NameError.new
	end

	obj = createEmptyObject( klass )
	markUnmarshalledObj( node, obj )

	vars = Hash.new
	node.each do | name, value |
	  vars[ RPCUtils.getNameFromElementName( name ) ] =
	    RPCUtils._soap2obj( value, map )
	end
	setInstanceVariables( obj, vars )

      rescue NameError
	obj = nil
      end

      obj
    end
  end

  # For anyType object.
  class Object; include Marshallable
    def setProperty( name, value )
      varName = name
      begin
	instance_eval <<-EOS
	  def #{ varName }
	    @#{ varName }
	  end

	  def #{ varName }=( newMember )
	    @#{ varName } = newMember
	  end
	EOS
	self.send( varName + '=', value )
      rescue SyntaxError
	varName = safeName( varName )
	retry
      end

      varName
    end

    def members
      instance_variables.collect { | str | str[1..-1] }
    end

    def []( name )
      if self.methods.include?( name )
	self.send( name )
      else
	self.send( safeName( name ))
      end
    end

    def []=( name, value )
      if self.methods.include?( name )
	self.send( name + '=', value )
      else
	self.send( safeName( name ) + '=', value )
      end
    end

  private

    def safeName( name )
      require 'md5'
      "var_" << MD5.new( name ).hexdigest
    end
  end

  class MappingError < Error; end

  class MappingRegistry
    class Mapping
      def initialize( mappingRegistry )
	@map = []
	@registry = mappingRegistry
      end

      def obj2soap( klass, obj )
	@map.each do | objKlass, soapKlass, factory, info |
	  if klass.ancestors.include?( objKlass )
	    ret = factory.obj2soap( soapKlass, obj, info, @registry )
	    return ret if ret
	  end
	end
	nil
      end

      def soap2obj( klass, node )
	@map.each do | objKlass, soapKlass, factory, info |
	  if klass == soapKlass
	    conv, obj = factory.soap2obj( objKlass, node, info, @registry )
	    return true, obj if conv
	  end
	end
	return false
      end

      # Give priority to former entry.
      def init( initMapping = [] )
	clear
	initMapping.reverse_each do | objKlass, soapKlass, factory, info |
  	  add( objKlass, soapKlass, factory, info )
   	end
      end

      # Give priority to latter entry.
      def add( objKlass, soapKlass, factory, info )
	@map.unshift( [ objKlass, soapKlass, factory, info ] )
      end

      def clear
	@map.clear
      end
    end

    BasetypeFactory = BasetypeFactory_.new
    DateTimeFactory = DateTimeFactory_.new
    ArrayFactory = ArrayFactory_.new
    Base64Factory = Base64Factory_.new
    TypedArrayFactory = TypedArrayFactory_.new
    TypedStructFactory = TypedStructFactory_.new

    HashFactory = HashFactory_.new

    SOAPBaseMapping = [
      [ ::NilClass,	::SOAP::SOAPNil,	BasetypeFactory ],
      [ ::TrueClass,	::SOAP::SOAPBoolean,	BasetypeFactory ],
      [ ::FalseClass,	::SOAP::SOAPBoolean,	BasetypeFactory ],
      [ ::String,	::SOAP::SOAPString,	BasetypeFactory ],
      [ ::Date,		::SOAP::SOAPDateTime,	BasetypeFactory ],
      [ ::Date,		::SOAP::SOAPDate,	BasetypeFactory ],
      [ ::Time,		::SOAP::SOAPDateTime,	BasetypeFactory ],
      [ ::Time,		::SOAP::SOAPTime,	BasetypeFactory ],
      [ ::Float,	::SOAP::SOAPFloat,	BasetypeFactory ],
      [ ::Float,	::SOAP::SOAPDouble,	BasetypeFactory ],
      [ ::Integer,	::SOAP::SOAPInt,	BasetypeFactory ],
      [ ::Integer,	::SOAP::SOAPLong,	BasetypeFactory ],
      [ ::Integer,	::SOAP::SOAPInteger,	BasetypeFactory ],
      [ ::String,	::SOAP::SOAPBase64,	Base64Factory ],
      [ ::String,	::SOAP::SOAPHexBinary,	Base64Factory ],
      [ ::String,	::SOAP::SOAPDecimal,	BasetypeFactory ],

      [ ::Array,	::SOAP::SOAPArray,	ArrayFactory ],
      [ ::SOAP::RPCUtils::SOAPException,
			::SOAP::SOAPStruct,	TypedStructFactory,
			[ RubyCustomTypeNamespace, "SOAPException" ]],
    ]

    UserMapping = [
      [ ::Hash,		::SOAP::SOAPStruct,	HashFactory ],
    ]

    def initialize( config = {} )
      @config = config
      @allowUntypedStruct = @config.has_key?( :allowUntypedStruct ) ?
	@config[ :allowUntypedStruct ] : true
      @map = Mapping.new( self )
      @map.init( SOAPBaseMapping )
      UserMapping.each do | mapData |
	add( *mapData )
      end
      @defaultFactory =
	RubytypeFactory_.new( :allowUntypedStruct => @allowUntypedStruct )
      @obj2soapExceptionHandler = nil
      @soap2objExceptionHandler = nil
    end

    def add( objKlass, soapKlass, factory, info = nil )
      @map.add( objKlass, soapKlass, factory, info )
    end
    alias :set :add

    def obj2soap( klass, obj )
      ret = nil
      begin 
	ret = @map.obj2soap( klass, obj ) ||
	  @defaultFactory.obj2soap( klass, obj, nil, self )
      rescue MappingError
      end

      if ret.nil? && @obj2soapExceptionHandler
	ret = @obj2soapExceptionHandler.call( obj ) { | yieldObj |
	  RPCUtils._obj2soap( yieldObj, self )
	}
      end
      if ret.nil?
	raise MappingError.new( "Cannot map #{ klass.name } to SOAP/OM." )
      end
      ret
    end

    def soap2obj( klass, node )
      conv, obj = @map.soap2obj( klass, node )
      return obj if conv

      conv, obj = @defaultFactory.soap2obj( klass, node, nil, self )
      return obj if conv

      if @soap2objExceptionHandler
	begin
	  return @soap2objExceptionHandler.call( node ) { | yieldNode |
	    RPCUtils._soap2obj( yieldNode, self )
	  }
	rescue Exception
	end
      end

      raise MappingError.new( "Cannot map #{ node.typeName } to Ruby object." )
    end

    def defaultFactory=( newFactory )
      @defaultFactory = newFactory
    end

    def obj2soapExceptionHandler=( newHandler )
      @obj2soapExceptionHandler = newHandler
    end

    def soap2objExceptionHandler=( newHandler )
      @soap2objExceptionHandler = newHandler
    end
  end
end


end
