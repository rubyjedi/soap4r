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
      begin
	klass = RPCUtils.getClassFromName( @exceptionTypeName.to_s )
	raise NameError unless klass.ancestors.include?( Exception )
 	obj = klass.new( @message )
	obj.extend( ::SOAP::RPCServerException )
	obj
      rescue NameError
	RuntimeError.new( @message )
      end
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
    class FactoryError < Error; end

    def obj2soap( soapKlass, obj, info, map )
      raise NotImplementError.new
    end

    def soap2obj( objKlass, node, info, map )
      raise NotImplementError.new
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

    # It breaks Thread.current[ :SOAPDataKey ].
    def setInstanceVariables( obj, values )
      values.each do | name, value |
	# obj.instance_eval( "@#{ name } = Thread.current[ :SOAPDataKey ]" )
	# m_seki:
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
      soapObj = begin
	  if soapKlass.ancestors.include?( XSD::XSDString )
	    encoded = Charset.encodingToXML( obj )
	    soapKlass.new( encoded )
	  else
	    soapKlass.new( obj )
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
      obj = node.data
      markUnmarshalledObj( node, obj )
      obj
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
      obj
    end
  end

  class ArrayFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      if soapKlass != SOAP::SOAPArray
	return nil
      end

      # [ [1], [2] ] is converted to Array of Array, not 2-D Array.
      # To create M-D Array, you must call RPCUtils.ary2md.
      typeName = getTypeName( obj.type )
      typeNamespace = getNamespace( obj.type ) || RubyTypeNamespace
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
	raise FactoryError.new( "Unknown compound type: #{ node }" )
      end

      obj = []
      markUnmarshalledObj( node, obj )
      node.soap2array( obj ) { | elem |
	elem ? RPCUtils._soap2obj( elem, map ) : nil
      }
      obj.instance_eval( "@@typeName = '#{ node.typeName }'; @@typeNamespace = '#{ node.typeNamespace }'" )
      obj
    end
  end

  class StructFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      if soapKlass != SOAP::SOAPStruct
	return nil
      end

      param = SOAPStruct.new( RPCUtils.getElementNameFromName( obj.type.to_s ))
      markMarshalledObj( obj, param )
      param.typeNamespace = getNamespace( obj.type ) || RubyTypeNamespace
      obj.members.each do |member|
	param.add( RPCUtils.getElementNameFromName( member ),
	  RPCUtils._obj2soap( obj[ member ], map ))
      end
      param
    end

    def soap2obj( objKlass, node, info, map )
      if !node.is_a?( SOAPStruct )
	raise FactoryError.new( "Unknown compound type: #{ node }" )
      end

      if node.typeEqual( XSD::Namespace, XSD::AnyTypeLiteral )
	unknownObj( node, map )
      else
	struct2obj( node, map )
      end
    end

  private

    def unknownObj( node, map )
      klass = Object	# SOAP::RPCUtils::Object

      obj = klass.new
      markUnmarshalledObj( node, obj )
      obj.typeNamespace = node.typeNamespace
      obj.typeName = node.typeName

      vars = Hash.new
      node.each do |name, value|
	vars[ RPCUtils.getNameFromElementName( name ) ] =
	  RPCUtils._soap2obj( value, map )
      end
      setInstanceVariables( obj, vars )

      obj
    end

    def struct2obj( node, map )
      obj = nil
      typeName = RPCUtils.getNameFromElementName( node.typeName ||
	node.instance_eval( "@name" ))
      begin
	klass = begin
	    RPCUtils.getClassFromName( typeName )
	  rescue NameError
	    self.instance_eval( toType( typeName ))
	  end
	if getNamespace( klass ) != node.typeNamespace
	  raise NameError.new()
	elsif getTypeName( klass ) and ( getTypeName( klass ) != typeName )
	  raise NameError.new()
	end

	obj = createEmptyObject( klass )
	markUnmarshalledObj( node, obj )

	vars = Hash.new
	node.each do |name, value|
	  vars[ RPCUtils.getNameFromElementName( name ) ] =
	    RPCUtils._soap2obj( value, map )
	end
	setInstanceVariables( obj, vars )

      rescue NameError
	raise FactoryError.new( "Unknown compound type: #{ node.typeName }" )
      end

      obj
    end
  end

  class HashFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      if obj.is_a?( Hash )
	param = SOAPStruct.new( "Map" )
	markMarshalledObj( obj, param )
	param.typeNamespace = ApacheSOAPTypeNamespace
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
      else
	nil
      end
    end

    def soap2obj( objKlass, node, info, map )
      if node.typeEqual( RubyTypeNamespace, 'Hash' )
	obj = Hash.new
	markUnmarshalledObj( node, obj )
	keyArray = RPCUtils._soap2obj( node[ 'key' ], map )
	valueArray = RPCUtils._soap2obj( node[ 'value' ], map )
	while !keyArray.empty?
	  obj[ keyArray.shift ] = valueArray.shift
	end
	obj
      elsif node.typeEqual( ApacheSOAPTypeNamespace, 'Map' )
	obj = Hash.new
	markUnmarshalledObj( node, obj )
	node.each do | key, value |
	  obj[ RPCUtils._soap2obj( value[ 'key' ], map ) ] =
	    RPCUtils._soap2obj( value[ 'value' ], map )
	end
	obj
      else
	raise FactoryError.new( "#{ node } is not a Hash." )
      end
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
	raise FactoryError.new( "Type mismatch" )
      end
      typeName = info[1]
      typeNamespace = info[0]
      if ( node.typeNamespace != typeNamespace ) ||
	  ( node.typeName != typeName )
	raise FactoryError.new( "Type mismatch" )
      end

      obj = objKlass.new
      markUnmarshalledObj( node, obj )
      node.soap2array( obj ) do | elem |
	elem ? RPCUtils._soap2obj( elem, map ) : nil
      end
      obj.instance_eval( "@@typeName = '#{ typeName }'; @@typeNamespace = '#{ typeNamespace }'" )
      obj
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
      if ( node.typeNamespace != typeNamespace ) || ( node.typeName != typeName )
	raise FactoryError.new( "Type mismatch" )
      end

      obj = createEmptyObject( objKlass )
      markUnmarshalledObj( node, obj )
      vars = Hash.new
      node.each do |name, value|
	vars[ RPCUtils.getNameFromElementName( name ) ] =
	  RPCUtils._soap2obj( value, map )
      end
      setInstanceVariables( obj, vars )

      obj
    end
  end

  class RubytypeFactory_ < Factory
    TYPE_REGEXP = 'Regexp'
    TYPE_CLASS = 'Class'
    TYPE_MODULE = 'Module'
    TYPE_SYMBOL = 'Symbol'

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
      when IO, Binding, Continuation, Data, Dir, File::Stat, MatchData, Method,
  	  Proc, Thread, ThreadGroup 
	# raise FactoryError.new( "can't dump #{ obj.type }." )
	return nil
      else
	typeName = getTypeName( obj.type ) ||
	  RPCUtils.getElementNameFromName( obj.type.to_s )
	param = SOAPStruct.new( typeName  )
	markMarshalledObj( obj, param )
	param.typeNamespace = getNamespace( obj.type ) ||
	  RubyCustomTypeNamespace
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
	case node.typeName
	when TYPE_REGEXP
	  source = node[ 'source' ].toString
	  options = node.include?( 'options' ) ? node[ 'options' ].data : nil
	  kcode = node.include?( 'kcode' ) ? node[ 'kcode' ].data : nil
	  kcode ? Regexp.new( source, options, kcode ) :
	    Regexp.new( source, options )
	when TYPE_CLASS
	  RPCUtils.getClassFromName( node[ 'name' ].data )
	when TYPE_MODULE
	  RPCUtils.getClassFromName( node[ 'name' ].data )
	when TYPE_SYMBOL
	  node[ 'id' ].data.intern
	else
	  # For Exception
	  begin
	    typeName = RPCUtils.getNameFromElementName( node.typeName )
	    klass = RPCUtils.getClassFromName( typeName )
	  rescue NameError
	    raise FactoryError.new( "#{ node.typeName } is not a Rubytype." )
	  end
	  if klass.ancestors.include?( Exception )
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
	    obj
	  else
	    raise FactoryError.new( "#{ node.typeName } is not a Rubytype." )
	  end
	end
      else
	soapUnknownType2obj( node, map )
      end
    end

  private

    def soapUnknownType2obj( node, map )
      if !@allowUntypedStruct
	raise FactoryError.new( "Unknown object #{ node.typeName }." )
      end

      # Only Method Struct is allowed untyped in RPC style.
      if !node.parent.is_a?( SOAPBody )
	node
      else
	typeName = RPCUtils.getNameFromElementName( node.typeName || node.name )
	klass = nil
	structName = toType( typeName )
	members = node.members.collect { |member|
	  RPCUtils.getNameFromElementName( member )
	}
	if ( Struct.constants - Struct.superclass.constants ).member?(
	    structName )
	  klass = Struct.const_get( structName )
	  if klass.members.length != members.length
	    klass = Struct.new( structName, *members )
	  end
	else
	  klass = Struct.new( structName, *members )
	end
	obj = klass.new
	markUnmarshalledObj( node, obj )
	node.each do | name, value |
	  obj.send( RPCUtils.getNameFromElementName( name ) + "=",
	    RPCUtils._soap2obj( value, map ))
	end
	obj
      end
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
	    begin
	      return factory.soap2obj( objKlass, node, info, @registry )
	    rescue Factory::FactoryError
	    end
	  end
	end
	raise Factory::FactoryError.new( "Cannot map #{ node.name }." )
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
    ArrayFactory = ArrayFactory_.new
    StructFactory = StructFactory_.new
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
      [ ::Struct, 	::SOAP::SOAPStruct,	StructFactory ],
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
      rescue Factory::FactoryError
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
      begin
	return @map.soap2obj( klass, node )
      rescue Factory::FactoryError
      end

      begin
	return @defaultFactory.soap2obj( klass, node, nil, self )
      rescue Factory::FactoryError
      end

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


  ###
  ## Convert parameter
  #
  # For type unknown object.
  class Object
    attr_accessor :typeName, :typeNamespace
  end
end


end
