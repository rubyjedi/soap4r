=begin
SOAP4R - RPC utility.
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


module SOAP


class SOAPBody < SOAPStruct
  public

  def request
    rootNode
  end

  def response
    if !@isFault
      if void?
	nil
      else
	# Initial element is [retVal].
	rootNode[ 0 ]
      end
    else
      rootNode
    end
  end

  def void?
    rootNode.nil? # || rootNode.is_a?( SOAPNil )
  end

  def fault
    if @isFault
      @data[ 'fault' ]
    else
      nil
    end
  end

  def setFault( faultData )
    @isFault = true
    addMember( 'fault', faultData )
  end
end


module Marshallable
  @@typeName = nil
  @@typeNamespace = nil

  alias __instance_variables instance_variables
  def instance_variables
    if block_given?
      self.__instance_variables.each do |key|
	yield( key, eval( key ))
      end
    else
      self.__instance_variables
    end
  end
end


module RPCUtils
  RubyTypeNamespace = 'http://www.ruby-lang.org/xmlns/ruby/type/1.6'
  RubyCustomTypeNamespace = 'http://www.ruby-lang.org/xmlns/ruby/type/custom'

  ApacheSOAPTypeNamespace = 'http://xml.apache.org/xml-soap'


  ###
  ## RPC specific elements
  #
  class SOAPMethod < NSDBase
    include SOAPCompoundtype

    attr_reader :namespace
    attr_reader :name

    attr_reader :paramDef
    attr_accessor :paramNames
    attr_reader :paramTypes
    attr_reader :params
    attr_reader :soapAction

    attr_accessor :retName
    attr_accessor :retVal
  
    def initialize( namespace, name, paramDef = nil, soapAction = nil )
      super( self.type.to_s )
  
      @namespace = namespace
      @name = name
  
      @paramDef = paramDef
      @paramNames = []
      @paramTypes = {}
      @params = {}

      @soapAction = soapAction

      @retName = nil
      @retVal = nil
  
      setParamDef if @paramDef
    end
  
    def setParams( params )
      params.each do | param, data |
        @params[ param ] = data
      end
    end
  
    def encode( ns )
      attrs = []
      createNS( attrs, ns )
      if !retVal
	# Should it be typed?
	# attrs.push( datatypeAttr( ns ))

	elems = []
        @paramNames.each do | param |
	  unless @params[ param ].is_a?( SOAPVoid )
	    elems << @params[ param ].encode( ns.clone, param )
	  end
	end

        # Element.new( ns.name( @namespace, @name ), attrs, elems )
	Node.initializeWithChildren( ns.name( @namespace, @name ), attrs, elems )
      else
	# Should it be typed?
	# attrs.push( datatypeAttrResponse( ns ))

	elems = []
	unless retVal.is_a?( SOAPVoid )
	  elems << retVal.encode( ns.clone, 'return' )
	end
        # Element.new( ns.name( @namespace, responseTypeName() ), attrs, retElem )
        Node.initializeWithChildren( ns.name( @namespace, responseTypeName() ), attrs, elems )
      end
    end
  
  private

    def datatypeAttr( ns )
      Attr.new( ns.name( XSD::InstanceNamespace, 'type' ), ns.name( @namespace, @name ))
    end

    def datatypeAttrResponse( ns )
      Attr.new( ns.name( XSD::InstanceNamespace, 'type' ), ns.name( @namespace, responseTypeName() ))
    end

    def createNS( attrs, ns )
      unless ns.assigned?( @namespace )
	tag = ns.assign( @namespace )
	attrs.push( Attr.new( 'xmlns:' << tag, @namespace ))
      end
    end

    def setParamDef
      @paramDef.each do | pair |
        type, name = pair
        type.scan( /[^,\s]+/ ).each do | typeToken |
  	case typeToken
  	when 'in'
  	  @paramNames.push( name )
  	  @paramTypes[ name ] = 1
  	when 'out'
  	  @paramNames.push( name )
  	  @paramTypes[ name ] = 2
  	when 'retval'
  	  if ( @retName )
	    raise MethodDefinitionError.new( 'Duplicated retval' )
  	  end
  	  @retName = name
  	else
  	  raise MethodDefinitionError.new( 'Unknown type: ' << typeToken )
  	end
        end
      end
    end
  
    def responseTypeName
      @name + 'Response'
    end
  end


  class SOAPVoid < XSDBase
    include SOAPBasetype
    extend SOAPModuleUtils

  public
    def initialize()
      @namespace = RubyCustomTypeNamespace
      @name = nil
      @id = nil
      @parent = nil
    end
  end


  class SOAPException
    include Marshallable
    attr_reader :exceptionTypeName, :message, :backtrace
    def initialize( e )
      @exceptionTypeName = e.type.to_s
      @message = e.message
      @backtrace = e.backtrace
    end

    def to_e
      e = begin
	  klass = Object
	  @exceptionTypeName.to_s.split( '::' ).each do | klassStr |
	    klass = klass.const_get( klassStr )
	  end
  	  raise NameError unless klass.ancestors.include?( Exception )
   	  klass.new( @message )
    	rescue NameError
	  RuntimeError.new( @message )
	end
      e.set_backtrace(
	if @backtrace.is_a?( Array )
	  @backtrace
	else
	  [ @backtrace.inspect ]
	end
      )
      e
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

    def getTypeName( obj )
      ret = nil
      begin
	ret = obj.instance_eval( "@typeName" ) || obj.instance_eval( "@@typeName" )
      rescue NameError
      end
      ret
    end

    def getNamespace( obj )
      ret = nil
      begin
	ret = obj.instance_eval( "@typeNamespace" ) || obj.instance_eval( "@@typeNamespace" )
      rescue NameError
      end
      ret
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

    def addWriter( klass, values )
      values.each do |name, value|
	klass.module_eval <<-EOS
	  begin
	    alias __#{ name }= #{ name }=
	  rescue NameError
	  end
	  def #{ name }=( var )
	    @#{ name } = var
	  end
	EOS
      end
    end

    def restoreWriter( klass, values )
      values.each do |name, value|
	klass.module_eval <<-EOS
	  undef #{ name }=
	  begin
	    alias #{ name }= __#{ name }=
	  rescue NameError
	  end
	EOS
      end
    end

    def setInstanceVar( obj, var )
      obj.instance_eval( "alias __initialize initialize; def initialize; end" )
      obj.instance_eval( "undef initialize; alias initialize __initialize" )
      obj
    end

    def toType( name )
      capitalize( name )
    end

    # Create NCName
    def toTypeName( name )
      name.gsub( ':', '_' )
    end

    def capitalize( target )
      target.gsub('^([a-z])') { $1.tr!('[a-z]', '[A-Z]') }
    end
  end

  class BasetypeFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      if soapKlass.ancestors.include?( XSD::XSDString )
	encoded = case SOAP::Processor.getEncoding
          when 'NONE'
	    obj
          when 'EUC'
            Uconv.euctou8( obj )
          when 'SJIS'
            Uconv.sjistou8( obj )
          else
	    obj
          end
	soapKlass.new( encoded )
      else
	soapKlass.new( obj )
      end
    end

    def soap2obj( objKlass, node, info, map )
      node.data
    end
  end

  class Base64Factory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      raise FactoryError.new
    end

    def soap2obj( objKlass, node, info, map )
      node.toString
    end
  end

  class CompoundtypeFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      if soapKlass == SOAP::SOAPArray
	# [ [1], [2] ] is converted to Array of Array, not 2-D Array.
	# To create M-D Array, you must call RPCUtils.ary2md.
	typeName = getTypeName( obj.type )
	typeNamespace = getNamespace( obj.type ) || RubyTypeNamespace
	unless typeName
	  typeName = XSD::AnyTypeLiteral
	  typeNamespace = XSD::Namespace
	end
	param = SOAPArray.new( typeName )
	param.typeNamespace = typeNamespace
	obj.each do | var |
	  param.add( RPCUtils.obj2soap( var, map ))
	end
	param
      elsif soapKlass == SOAP::SOAPStruct
	param = SOAPStruct.new( toTypeName( obj.type.to_s ))
	param.typeNamespace = getNamespace( obj.type ) || RubyTypeNamespace
	obj.members.each do |member|
	  param.add( member, RPCUtils.obj2soap( obj[ member ], map ))
	end
	param
      else
	nil
      end
    end

    def soap2obj( objKlass, node, info, map )
      if node.is_a?( SOAPArray )
       	obj = node.soap2array { | elem |
  	  RPCUtils.soap2obj( elem, map )
   	}
    	obj.instance_eval( "@typeName = '#{ node.typeName }'; @typeNamespace = '#{ node.typeNamespace }'" )
     	obj
      elsif node.is_a?( SOAPStruct )
	if node.typeEqual( XSD::Namespace, XSD::AnyTypeLiteral )
	  unknownObj( node, map )
	else
	  struct2obj( node, map )
	end
      else
	raise FactoryError.new( "Unknown compound type: #{ node }" )
      end
    end

  private

    def unknownObj( node, map )
      klass = Object	# SOAP::RPCUtils::Object
      Thread.critical = true
      addWriter( klass, node )
      obj = klass.new
      node.each do |name, value|
	obj.send( name + "=", RPCUtils.soap2obj( value, map ))
      end
      restoreWriter( klass, node )
      Thread.critical = false
      obj.typeNamespace = node.typeNamespace
      obj.typeName = node.typeName
      obj
    end

    def struct2obj( node, map )
      obj = nil
      typeName = node.typeName || node.instance_eval( "@name" )
      begin
	klass = self.instance_eval( toType( typeName ))
	if getNamespace( klass ) != node.typeNamespace
	  raise NameError.new()
	elsif getTypeName( klass ) and ( getTypeName( klass ) != typeName )
	  raise NameError.new()
	end

	Thread.critical = true
	addWriter( klass, node )
	obj = createEmptyObject( klass )
	node.each do |name, value|
	  obj.send( name + "=", RPCUtils.soap2obj( value, map ))
	end
	restoreWriter( klass, node )
	Thread.critical = false

      rescue NameError
	klass = nil
	structName = toType( typeName )
	if ( Struct.constants - Struct.superclass.constants ).member?( structName )
	  klass = Struct.const_get( structName )
	  if klass.members.length != node.members.length
	    klass = Struct.new( structName, *node.members )
	  end
	else
	  klass = Struct.new( structName, *node.members )
	end
	obj = klass.new
	node.each do | name, value |
	  obj.send( name + "=", RPCUtils.soap2obj( value, map ))
	end
      end

      obj
    end
  end

  class HashFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      if obj.is_a?( Hash )
	param = SOAPStruct.new( "Map" )
	param.typeNamespace = ApacheSOAPTypeNamespace
	i = 1
	obj.each do | key, value |
	  elem = SOAPStruct.new( "mapItem" )
	  elem.add( "key", RPCUtils.obj2soap( key, map ))
	  elem.add( "value", RPCUtils.obj2soap( value, map ))
	  param.add( "item#{ i }", elem )
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
	keyArray = RPCUtils.soap2obj( node.key, map )
	valueArray = RPCUtils.soap2obj( node.value, map )
	while !keyArray.empty?
	  obj[ keyArray.shift ] = valueArray.shift
	end
	obj
      elsif node.typeEqual( ApacheSOAPTypeNamespace, 'Map' )
	obj = Hash.new
	node.each do | key, value |
	  obj[ RPCUtils.soap2obj( value.key, map ) ] =
	    RPCUtils.soap2obj( value.value, map )
	end
	obj
      else
	raise FactoryError.new( "#{ node } is not a Hash." )
      end
    end
  end

  class UnknownKlassFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      typeName = getTypeName( obj.type ) || obj.type.to_s
      param = SOAPStruct.new( typeName  )
      param.typeNamespace = getNamespace( obj.type ) || RubyCustomTypeNamespace
      if obj.type.ancestors.member?( Marshallable )
	obj.instance_variables do |var, data|
	  name = var.dup.sub!( /^@/, '' )
	  param.add( name, RPCUtils.obj2soap( data, map ))
	end
      else
        obj.instance_variables.each do |var|
	  name = var.dup.sub!( /^@/, '' )
	  param.add( name, RPCUtils.obj2soap( obj.instance_eval( var ), map ))
        end
      end
      param
    end

    def soap2obj( objKlass, node, info, map )
      node
    end
  end

  class TypedArrayFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      typeName = info[1]
      typeNamespace = info[0]
      param = SOAPArray.new( typeName )
      param.typeNamespace = typeNamespace

      obj.each do | var |
	param.add( RPCUtils.obj2soap( var, map ))
      end
      param
    end

    def soap2obj( objKlass, node, info, map )
      if node.rank > 1
	raise FactoryError.new( "Type mismatch" )
      end
      typeName = info[1]
      typeNamespace = info[0]
      if ( node.typeNamespace != typeNamespace ) || ( node.typeName != typeName )
	raise FactoryError.new( "Type mismatch" )
      end

      obj = objKlass.new
      node.soap2array.each do | elem |
	obj << RPCUtils.soap2obj( elem, map )
      end
      obj.instance_eval( "@typeName = '#{ typeName }'; @typeNamespace = '#{ typeNamespace }'" )
      obj
    end
  end

  class TypedStructFactory_ < Factory
    def obj2soap( soapKlass, obj, info, map )
      typeName = info[1]
      typeNamespace = info[0]
      param = SOAPStruct.new( typeName  )
      param.typeNamespace = typeNamespace
      if obj.type.ancestors.member?( Marshallable )
	obj.instance_variables do |var, data|
	  name = var.dup.sub!( /^@/, '' )
	  param.add( name, RPCUtils.obj2soap( data, map ))
	end
      else
        obj.instance_variables.each do |var|
	  name = var.dup.sub!( /^@/, '' )
	  param.add( name, RPCUtils.obj2soap( obj.instance_eval( var ), map ))
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

      Thread.critical = true
      addWriter( objKlass, node )
      obj = createEmptyObject( objKlass )
      node.each do |name, value|
	obj.send( name + "=", RPCUtils.soap2obj( value, map ))
      end
      restoreWriter( objKlass, node )
      Thread.critical = false

      obj
    end
  end

  class MappingRegistry
    class MappingError < Error; end

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
	raise MappingError.new( "Unknown klass: #{ klass }" )
      end

      def init( initMapping = [] )
	clear
	initMapping.each do | objKlass, soapKlass, factory, info |
  	  set( objKlass, soapKlass, factory, info )
   	end
      end

      def set( objKlass, soapKlass, factory, info )
	@map << [ objKlass, soapKlass, factory, info ]
      end

      def clear
	@map.clear
      end
    end

    BasetypeFactory = BasetypeFactory_.new
    CompoundtypeFactory = CompoundtypeFactory_.new
    Base64Factory = Base64Factory_.new
    HashFactory = HashFactory_.new
    UnknownKlassFactory = UnknownKlassFactory_.new
    TypedArrayFactory = TypedArrayFactory_.new
    TypedStructFactory = TypedStructFactory_.new

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
      [ ::Integer,	::SOAP::SOAPInteger,	BasetypeFactory ],
      [ ::String,	::SOAP::SOAPBase64,	Base64Factory ],
      [ ::String,	::SOAP::SOAPDecimal,	BasetypeFactory ],
      [ ::Array,	::SOAP::SOAPArray,	CompoundtypeFactory ],
      [ ::SOAP::RPCUtils::SOAPException,
			::SOAP::SOAPStruct,	TypedStructFactory,
			[ RubyCustomTypeNamespace, "SOAPException" ]],
      [ ::Struct,	::SOAP::SOAPStruct,	CompoundtypeFactory ],
    ]

    UserMapping = [
      [ ::Hash,		::SOAP::SOAPStruct,	HashFactory ],
    ]

    def initialize()
      @userMap = Mapping.new( self )
      @baseMap = Mapping.new( self )
      @baseMap.init( SOAPBaseMapping )
      @defaultFactory = UnknownKlassFactory
    end

    def set( objKlass, soapKlass, factory, info = nil )
      @userMap.set( objKlass, soapKlass, factory, info )
    end

    def obj2soap( klass, obj )
      @userMap.obj2soap( klass, obj ) ||
	@baseMap.obj2soap( klass, obj ) ||
	@defaultFactory.obj2soap( klass, obj, nil, self )
    end

    def soap2obj( klass, node )
      begin
	return @userMap.soap2obj( klass, node )
      rescue MappingError
	begin
	  return @baseMap.soap2obj( klass, node )
	rescue MappingError
	end
      end

      @defaultFactory.soap2obj( klass, node, nil, self )
    end

    def defaultFactory=( newFactory )
      @defaultFactory = newFactory
    end
  end


  ###
  ## Convert parameter
  #
  # For type unknown object.
  class Object
    attr_accessor :typeName, :typeNamespace
  end


  def RPCUtils.obj2soap( obj, mappingRegistry = MappingRegistry.new )
    mappingRegistry ||= MappingRegistry.new
    if obj.is_a?( SOAPBasetype ) || obj.is_a?( SOAPCompoundtype )
      return obj
    end
    return mappingRegistry.obj2soap( obj.type, obj )
  end


  def RPCUtils.soap2obj( node, mappingRegistry = MappingRegistry.new )
    mappingRegistry ||= MappingRegistry.new
    if node.is_a?( SOAPReference )
      # ToDo: multi-reference decoding...
      return RPCUtils.soap2obj( node.__getobj__, mappingRegistry )
    end
    return mappingRegistry.soap2obj( node.type, node )
  end


  def RPCUtils.ary2md( ary, rank )
    mdAry = SOAPArray.new( XSD::AnyTypeLiteral, rank )
    mdAry.typeNamespace = XSD::Namespace

    addMDAry( mdAry, ary, [] )

    mdAry
  end

  class << RPCUtils
  private
    def addMDAry( mdAry, ary, indices )
      0.upto( ary.size - 1 ) do | idx |
       	if ary[ idx ].is_a?( Array )
  	  addMDAry( mdAry, ary[ idx ], indices + [ idx ] )
   	else
  	  mdAry[ *( indices + [ idx ] ) ] = RPCUtils.obj2soap( ary[ idx ] )
   	end
      end
    end
  end
end


end
