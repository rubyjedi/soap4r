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
require 'soap/rpcUtils'


module SOAP


module Marshallable
  @@typeNamespace = RPCUtils::RubyCustomTypeNamespace
end


module RPCServerException; end


module RPCUtils
  # Inner class to pass an exception.
  class SOAPException; include Marshallable
    attr_reader :exceptionTypeName, :message, :backtrace, :cause
    def initialize( e )
      @exceptionTypeName = RPCUtils.getElementNameFromName( e.type.to_s )
      @message = e.message
      @backtrace = e.backtrace
      @cause = e
    end

    def to_e
      if @cause.is_a?( Exception )
	@cause.extend( ::SOAP::RPCServerException )
	return @cause
      end
      klass = RPCUtils.getClassFromName(
	RPCUtils.getNameFromElementName( @exceptionTypeName.to_s ))
      if klass.nil?
	raise RuntimeError.new( @message )
      end
      unless klass <= Exception
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

    def getClassType( klass )
      name = if klass.class_variables.include?( "@@typeName" )
	  klass.class_eval( "@@typeName" )
	else
	  nil
	end
      namespace = if klass.class_variables.include?( "@@typeNamespace" )
	  klass.class_eval( "@@typeNamespace" )
	else
	  nil
	end
      XSD::QName.new( namespace, name )
    end

    def getObjType( obj )
      name = namespace = nil
      ivars = obj.instance_variables
      if ivars.include?( "@typeName" )
	name = obj.instance_eval( "@typeName" )
      end
      if ivars.include?( "@typeNamespace" )
	namespace = obj.instance_eval( "@typeNamespace" )
      end
      # Do not mix type and its namespace.
      if !name or !namespace
	getClassType( obj.class )
      else
	XSD::QName.new( namespace, name )
      end
    end

    if Object.respond_to?( :allocate )
      # ruby/1.7 or later.
      def createEmptyObject( klass )
	klass.allocate
      end
    else
      def createEmptyObject( klass )
	name = klass.name
	# Below line is from TANAKA, Akira's amarshal.rb.
	# See http://cvs.m17n.org/cgi-bin/viewcvs/amarshal/?cvsroot=ruby
	::Marshal.load( sprintf( "\004\006o:%c%s\000", name.length + 5, name ))
      end
    end

    def setInstanceVariables( obj, values )
      values.each do | name, value |
	obj.instance_eval( "@#{ name } = value" )
      end
    end

    def setiv2obj( obj, node, map )
      vars = {}
      node.each do | name, value |
	vars[ RPCUtils.getNameFromElementName( name ) ] =
	  RPCUtils._soap2obj( value, map )
      end
      setInstanceVariables( obj, vars )
    end

    def setiv2soap( node, obj, map )
      obj.instance_variables.each do | var |
   	name = var.dup.sub!( /^@/, '' )
	node.add( RPCUtils.getElementNameFromName( name ),
     	  RPCUtils._obj2soap( obj.instance_eval( var ), map ))
      end
    end

    def addiv2soap( node, obj, map )
      ivars = SOAPStruct.new	# Undefined type.
      setiv2soap( ivars, obj, map )
      node.add( 'ivars', ivars )
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
      target.gsub( /^([a-z])/ ) { $1.tr!( '[a-z]', '[A-Z]' ) }
    end
  end

  class BasetypeFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      soapObj = nil
      begin
	if soapKlass <= XSD::XSDString
	  if Charset.isCES( obj, $KCODE )
	    encoded = Charset.codeConv( obj, $KCODE, Charset.getEncoding )
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
      obj = if objKlass <= ::String
	  Charset.codeConv( node.data, Charset.getEncoding, $KCODE )
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
    # [ [1], [2] ] is converted to Array of Array, not 2-D Array.
    # To create M-D Array, you must call RPCUtils.ary2md.
    def obj2soap( soapKlass, obj, info, map )
      if soapKlass != SOAP::SOAPArray
	return nil
      end
      type = getObjType( obj )
      if type.name
	type.namespace ||= RubyTypeNamespace
      else
	type = XSD::AnyType
      end
      param = SOAPArray.new( type )
      markMarshalledObj( obj, param )
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
      obj.instance_eval( "@typeName = '#{ node.type.name }'; @typeNamespace = '#{ node.type.namespace }'" )
      return true, obj
    end
  end

  class TypedArrayFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      type = info[0]
      param = SOAPArray.new( type )
      markMarshalledObj( obj, param )
      obj.each do | var |
	param.add( RPCUtils._obj2soap( var, map ))
      end
      param
    end

    def soap2obj( objKlass, node, info, map )
      if node.rank > 1
        return false
      end
      type = info[0]
      unless node.type == type
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
      type = info[0]
      param = SOAPStruct.new( type  )
      markMarshalledObj( obj, param )
      if obj.class <= SOAP::Marshallable
	setiv2soap( param, obj, map )
      else
	setiv2soap( param, obj, map )
      end
      param
    end

    def soap2obj( objKlass, node, info, map )
      type = info[0]
      unless node.type == type
	return false
      end
      obj = createEmptyObject( objKlass )
      markUnmarshalledObj( node, obj )
      setiv2obj( obj, node, map )
      return true, obj
    end
  end

  MapQName = XSD::QName.new( ApacheSOAPTypeNamespace, 'Map' )
  class HashFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      if !obj.is_a?( Hash )
	return nil
      end
      param = SOAPStruct.new( MapQName )
      markMarshalledObj( obj, param )
      obj.each do | key, value |
	elem = SOAPStruct.new # Undefined type.
     	elem.add( "key", RPCUtils._obj2soap( key, map ))
  	elem.add( "value", RPCUtils._obj2soap( value, map ))
     	# ApacheAxis allows only 'item' here.
  	param.add( "item", elem )
      end
#      unless obj.instance_variables.empty?
#	addiv2soap( param, obj, map )
#      end
      param
    end

    def soap2obj( objKlass, node, info, map )
      unless node.type == MapQName
	return false
      end

      obj = Hash.new
      markUnmarshalledObj( node, obj )
      node.each do | key, value |
	obj[ RPCUtils._soap2obj( value[ 'key' ], map ) ] =
     	  RPCUtils._soap2obj( value[ 'value' ], map )
      end
#      if node.members.include?( 'ivars' )
#	setiv2obj( obj, node[ 'ivars' ], map )
#      end
      return true, obj
    end
  end

  class RubytypeFactory_ < Factory
    TYPE_REGEXP = 'Regexp'
    TYPE_RANGE = 'Range'
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
	param = SOAPStruct.new( XSD::QName.new( RubyTypeNamespace, TYPE_REGEXP ))
	markMarshalledObj( obj, param )
	param.add( 'source', SOAPBase64.new( obj.source ))
	if obj.respond_to?( 'options' )
      	  # Regexp#options is from Ruby/1.7
	  options = obj.options
	else
	  options = 0
	  obj.inspect.sub( /^.*\//, '' ).each_byte do | c |
	    options += case c
	      when ?i
		1
	      when ?x
		2
	      when ?m
		4
	      when ?n
		16
	      when ?e
		32
	      when ?s
		48
	      when ?u
		64
	      end
	  end
	end
	param.add( 'options', SOAPInt.new( options ))
	unless obj.instance_variables.empty?
	  addiv2soap( param, obj, map )
	end
	param
      when Range
	param = SOAPStruct.new( XSD::QName.new( RubyTypeNamespace, TYPE_RANGE ))
	markMarshalledObj( obj, param )
	param.add( 'begin', RPCUtils._obj2soap( obj.begin, map ))
	param.add( 'end', RPCUtils._obj2soap( obj.end, map ))
	param.add( 'exclude_end', SOAP::SOAPBoolean.new( obj.exclude_end? ))
	unless obj.instance_variables.empty?
	  addiv2soap( param, obj, map )
	end
	param
      when Hash
	param = SOAPStruct.new( XSD::QName.new( RubyTypeNamespace, TYPE_HASH ))
	markMarshalledObj( obj, param )
	obj.each do | key, value |
	  elem = SOAPStruct.new	# Undefined type.
	  elem.add( "key", RPCUtils._obj2soap( key, map ))
	  elem.add( "value", RPCUtils._obj2soap( value, map ))
	  # ApacheAxis allows only 'item' here.
	  param.add( "item", elem )
	end
#	unless obj.instance_variables.empty?
#	  addiv2soap( param, obj, map )
#	end
	param
      when Class
	if obj.name.empty?
	  # raise FactoryError.new( "Can't dump anonymous class #{ obj }." )
	  return nil
	end
	param = SOAPStruct.new( XSD::QName.new( RubyTypeNamespace, TYPE_CLASS ))
	markMarshalledObj( obj, param )
	param.add( 'name', SOAPString.new( obj.name ))
	param
      when Module
	if obj.name.empty?
	  # raise FactoryError.new( "Can't dump anonymous module #{ obj }." )
	  return nil
	end
	param = SOAPStruct.new( XSD::QName.new( RubyTypeNamespace, TYPE_MODULE ))
	markMarshalledObj( obj, param )
	param.add( 'name', SOAPString.new( obj.name ))
	param
      when Symbol
	param = SOAPStruct.new( XSD::QName.new( RubyTypeNamespace, TYPE_SYMBOL ))
	markMarshalledObj( obj, param )
	param.add( 'id', SOAPString.new( obj.id2name ))
	param
      when Exception
	typeStr = RPCUtils.getElementNameFromName( obj.class.to_s )
	param = SOAPStruct.new( XSD::QName.new( RubyTypeNamespace, typeStr ))
	markMarshalledObj( obj, param )
	param.add( 'message', RPCUtils._obj2soap( obj.message, map ))
	param.add( 'backtrace', RPCUtils._obj2soap( obj.backtrace, map ))
	unless obj.instance_variables.empty?
	  addiv2soap( param, obj, map )
	end
	param
      when Struct
	param = SOAPStruct.new( XSD::QName.new( RubyTypeNamespace, TYPE_STRUCT ))
	markMarshalledObj( obj, param )
	param.add( 'type', typeElem = SOAPString.new( obj.class.to_s ))
	memberElem = SOAPStruct.new
	obj.members.each do | member |
	  memberElem.add( RPCUtils.getElementNameFromName( member ),
	    RPCUtils._obj2soap( obj[ member ], map ))
	end
	param.add( 'member', memberElem )
	unless obj.instance_variables.empty?
	  addiv2soap( param, obj, map )
	end
	param
      when IO, Binding, Continuation, Data, Dir, File::Stat, MatchData, Method,
  	  Proc, Thread, ThreadGroup 
	return nil
      when ::SOAP::RPCUtils::Object
	param = SOAPStruct.new( XSD::AnyType )
	markMarshalledObj( obj, param )
	setiv2soap( param, obj, map )
	param
      else
	type = getClassType( obj.class )
	type.name ||= RPCUtils.getElementNameFromName( obj.class.to_s )
	type.namespace ||= RubyCustomTypeNamespace
	param = SOAPStruct.new( type )
	markMarshalledObj( obj, param )
	if obj.class <= Marshallable
	  setiv2soap( param, obj, map )
	else
	  # Should not be marshalled?
	  setiv2soap( param, obj, map )
	end
	param
      end
    end

    def soap2obj( objKlass, node, info, map )
      if node.type.namespace == RubyTypeNamespace
	rubyType2obj( node, map )
      elsif node.type == XSD::AnyType
	anyType2obj( node, map )
      else
	unknownType2obj( node, map )
      end
    end

  private

    def rubyType2obj( node, map )
      obj = nil
      case node.type.name
      when TYPE_REGEXP
	obj = createEmptyObject( Regexp )
	markUnmarshalledObj( node, obj )
	source = node[ 'source' ].toString
	options = node[ 'options' ].data || 0
	obj.instance_eval { initialize( source, options ) }
	if node.members.include?( 'ivars' )
  	  setiv2obj( obj, node[ 'ivars' ], map )
   	end
      when TYPE_RANGE
	obj = createEmptyObject( Range )
	markUnmarshalledObj( node, obj )
	first = RPCUtils._soap2obj( node[ 'begin' ], map )
	last = RPCUtils._soap2obj( node[ 'end' ], map )
	exclude_end = node[ 'exclude_end' ].data
	obj.instance_eval { initialize( first, last, exclude_end ) }
	if node.members.include?( 'ivars' )
  	  setiv2obj( obj, node[ 'ivars' ], map )
   	end
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
	typeStr = RPCUtils.getNameFromElementName( node[ 'type' ].data )
	klass = RPCUtils.getClassFromName( typeStr )
	if klass.nil?
	  klass = RPCUtils.getClassFromName( toType( typeStr ))
	  #klass = self.instance_eval( toType( typeStr ))
	end
	if klass.nil?
	  return false
	end
	unless klass <= ::Struct
	  return false
	end
	obj = klass.new
	markUnmarshalledObj( node, obj )
	node[ 'member'].each do | name, value |
	  obj[ RPCUtils.getNameFromElementName( name ) ] =
	    RPCUtils._soap2obj( value, map )
	end

	if node.members.include?( 'ivars' )
  	  setiv2obj( obj, node[ 'ivars' ], map )
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
      typeStr = RPCUtils.getNameFromElementName( node.type.name )
      klass = RPCUtils.getClassFromName( typeStr )
      if klass.nil?
	return false
      end
      unless klass <= Exception
	return false
      end
      message = RPCUtils._soap2obj( node[ 'message' ], map )
      backtrace = RPCUtils._soap2obj( node[ 'backtrace' ], map )
      obj = klass.new( message )
      markUnmarshalledObj( node, obj )
      obj.set_backtrace( backtrace )
      if node.members.include?( 'ivars' )
	setiv2obj( obj, node[ 'ivars' ], map )
      end
      return true, obj
    end

    def anyType2obj( node, map )
      case node
      when SOAPBasetype
	return true, node.data
      when SOAPStruct
	klass = Object	# SOAP::RPCUtils::Object
	obj = klass.new
	markUnmarshalledObj( node, obj )
	node.each do | name, value |
	  obj.setProperty( name, RPCUtils._soap2obj( value, map ))
	end
	return true, obj
      else
	return false
      end
    end

    def unknownType2obj( node, map )
      if node.is_a?( SOAPStruct )
	obj = struct2obj( node, map )
	return true, obj if obj

	if !@allowUntypedStruct
	  return false
	end

	return anyType2obj( node, map )
      else
	# Basetype which is not defined...
	return false
      end
    end

    def struct2obj( node, map )
      obj = nil
      typeStr = RPCUtils.getNameFromElementName( node.type.name )
      klass = RPCUtils.getClassFromName( typeStr )
      if klass.nil?
	klass = RPCUtils.getClassFromName( toType( typeStr ))
	#klass = self.instance_eval( toType( typeStr ))
      end
      if klass.nil?
	return nil
      end
      klassType = getClassType( klass )
      return nil unless node.type.match( klassType )
      obj = createEmptyObject( klass )
      markUnmarshalledObj( node, obj )
      setiv2obj( obj, node, map )
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
      if self.respond_to?( name )
	self.send( name )
      else
	self.send( safeName( name ))
      end
    end

    def []=( name, value )
      if self.respond_to?( name )
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
	  if klass <= objKlass
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
      [ ::Float,	::SOAP::SOAPDouble,	BasetypeFactory ],
      [ ::Float,	::SOAP::SOAPFloat,	BasetypeFactory ],
      [ ::Integer,	::SOAP::SOAPInt,	BasetypeFactory ],
      [ ::Integer,	::SOAP::SOAPLong,	BasetypeFactory ],
      [ ::Integer,	::SOAP::SOAPInteger,	BasetypeFactory ],
      [ ::Integer,	::SOAP::SOAPShort,	BasetypeFactory ],
      [ ::URI::Generic,	::SOAP::SOAPAnyURI,	BasetypeFactory ],
      [ ::String,	::SOAP::SOAPBase64,	Base64Factory ],
      [ ::String,	::SOAP::SOAPHexBinary,	Base64Factory ],
      [ ::String,	::SOAP::SOAPDecimal,	BasetypeFactory ],
      [ ::String,	::SOAP::SOAPDuration,	BasetypeFactory ],
      [ ::String,	::SOAP::SOAPGYearMonth,	BasetypeFactory ],
      [ ::String,	::SOAP::SOAPGYear,	BasetypeFactory ],
      [ ::String,	::SOAP::SOAPGMonthDay,	BasetypeFactory ],
      [ ::String,	::SOAP::SOAPGDay,	BasetypeFactory ],
      [ ::String,	::SOAP::SOAPGMonth,	BasetypeFactory ],
      [ ::String,	::SOAP::SOAPQName,	BasetypeFactory ],

      [ ::Array,	::SOAP::SOAPArray,	ArrayFactory ],
      [ ::SOAP::RPCUtils::SOAPException,
			::SOAP::SOAPStruct,	TypedStructFactory,
			[ XSD::QName.new( RubyCustomTypeNamespace, "SOAPException" ) ]],
      [ ::Hash,		::SOAP::SOAPStruct,	HashFactory ],
    ]

    def initialize( config = {} )
      @config = config
      @allowUntypedStruct = @config.has_key?( :allowUntypedStruct ) ?
	@config[ :allowUntypedStruct ] : true
      @map = Mapping.new( self )
      @map.init( SOAPBaseMapping )
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

      raise MappingError.new( "Cannot map #{ node.type.name } to Ruby object." )
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
