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
  module RPCUtils
    RubyTypeNamespace = 'http://www.ruby-lang.org/xmlns/ruby/type/1.6'
    RubyCustomTypeNamespace = 'http://www.ruby-lang.org/xmlns/ruby/type/custom'
    ApacheSOAPTypeNamespace = 'http://xml.apache.org/xml-soap'
  end
end

require 'soap/mappingRegistry'


module SOAP


# Add method definitions for RPC to common definition in element.rb
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

  def outParams
    if !@isFault and !void?
      op = rootNode[ 1..-1 ]
      op = nil if op && op.empty?
      op
    else
      nil
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


module RPCUtils
  class RPCError < Error; end
  class MethodDefinitionError < RPCError; end
  class ParameterError < RPCError; end

  class SOAPMethod < SOAPStruct
    attr_reader :namespace
    attr_reader :name
    attr_accessor :encodingStyle

    attr_reader :paramDef

    attr_reader :inParam
    attr_reader :outParam
  
    def initialize( namespace, name, paramDef = nil )
      super( self.type.to_s )
      @typeName = nil
      @namespace = namespace
      @name = name
      @encodingStyle = nil
  
      @paramDef = paramDef

      @paramSignature = []
      @inParamNames = []
      @inoutParamNames = []
      @outParamNames = []

      @inParam = {}
      @outParam = {}
      @retName = nil

      setParamDef if @paramDef
    end

    def outParam?
      @outParamNames.size > 0
    end

    def eachParamName( *type )
      @paramSignature.each do | ioType, paramName |
	if type.include?( ioType )
	  yield( paramName )
	end
      end
    end
  
    def setParams( params )
      params.each do | param, data |
        @inParam[ param ] = data
	data.name = param
      end
    end

    def setOutParams( params )
      params.each do | param, data |
	@outParam[ param ] = data
	data.name = param
      end
    end

    def each
      eachParamName( 'in', 'inout' ) do | paramName |
	unless @inParam[ paramName ]
	  raise ParameterError.new( "Parameter: #{ paramName } was not given." )
	end
	yield( paramName, @inParam[ paramName ] )
      end
    end

    def SOAPMethod.createParamDef( paramNames )
      paramDef = []
      paramNames.each do | paramName |
	paramDef.push( [ 'in', paramName ] )
      end
      paramDef.push( [ 'retval', 'return' ] )
      paramDef
    end

  private

    def setParamDef
      @paramDef.each do | definition |
	ioType, name = definition

  	case ioType
  	when 'in'
	  @paramSignature.push( [ 'in', name ] )
	  @inParamNames.push( name )
  	when 'out'
	  @paramSignature.push( [ 'out', name ] )
	  @outParamNames.push( name )
  	when 'inout'
	  @paramSignature.push( [ 'inout', name ] )
	  @inoutParamNames.push( name )
  	when 'retval'
  	  if ( @retName )
	    raise MethodDefinitionError.new( 'Duplicated retval' )
  	  end
  	  @retName = name
  	else
  	  raise MethodDefinitionError.new( "Unknown type: #{ ioType }" )
  	end
      end
    end
  end


  class SOAPMethodRequest < SOAPMethod

    attr_reader :soapAction
  
    def initialize( namespace, name, paramDef = nil, soapAction = nil )
      super( namespace, name, paramDef )
      @soapAction = soapAction
    end

    def each
      eachParamName( 'in', 'inout' ) do | paramName |
	unless @inParam[ paramName ]
	  raise ParameterError.new( "Parameter: #{ paramName } was not given." )
	end
	yield( paramName, @inParam[ paramName ] )
      end
    end

    def dup
      req = self.type.new( @namespace, @name, @paramDef, @soapAction )
      req.encodingStyle = @encodingStyle
      req
    end

    def createMethodResponse
      response = SOAPMethodResponse.new( @namespace.dup, @name + 'Response', @paramDef.dup )
      response
    end
  end


  class SOAPMethodResponse < SOAPMethod

    def initialize( namespace, name, paramDef = nil )
      super( namespace, name, paramDef )
      @retVal = nil
    end

    def setRetVal( retVal )
      @retVal = retVal
      @retVal.name = 'return'
    end
  
    def each
      if @retName and !@retVal.is_a?( SOAPVoid )
	yield( @retName, @retVal )
      end

      eachParamName( 'out', 'inout' ) do | paramName |
	unless @outParam[ paramName ]
	  raise ParameterError.new( "Parameter: #{ paramName } was not given." )
	end
	yield( paramName, @outParam[ paramName ] )
      end
    end
  end


  # To return(?) void explicitly.
  #  def foo( inputVar )
  #    ...
  #    return SOAP::RPCUtils::SOAPVoid.new
  #  end
  class SOAPVoid < XSDBase
    include SOAPBasetype
    extend SOAPModuleUtils

  public
    def initialize()
      @namespace = RubyCustomTypeNamespace
      @name = nil
      @id = nil
      @precedents = []
      @parent = nil
    end
  end


  def RPCUtils.obj2soap( obj, mappingRegistry = MappingRegistry.new )
    mappingRegistry ||= MappingRegistry.new

    Thread.current[ :SOAPMarshalDataKey ] = {}
    soapObj = RPCUtils._obj2soap( obj, mappingRegistry )
    Thread.current[ :SOAPMarshalDataKey ] = nil

    soapObj
  end


  def RPCUtils.soap2obj( node, mappingRegistry = MappingRegistry.new )
    mappingRegistry ||= MappingRegistry.new

    Thread.current[ :SOAPMarshalDataKey ] = {}
    obj = RPCUtils._soap2obj( node, mappingRegistry )
    Thread.current[ :SOAPMarshalDataKey ] = nil

    obj
  end


  def RPCUtils.ary2soap( ary, typeNamespace = XSD::Namespace, type = XSD::AnyTypeLiteral, mappingRegistry = MappingRegistry.new )
    soapAry = SOAPArray.new( type )
    soapAry.typeNamespace = typeNamespace

    Thread.current[ :SOAPMarshalDataKey ] = {}
    ary.each do | ele |
      soapAry.add( RPCUtils._obj2soap( ele, mappingRegistry ))
    end
    Thread.current[ :SOAPMarshalDataKey ] = nil

    soapAry
  end

  def RPCUtils.ary2md( ary, rank, typeNamespace = XSD::Namespace, type = XSD::AnyTypeLiteral, mappingRegistry = MappingRegistry.new )
    mdAry = SOAPArray.new( type, rank )
    mdAry.typeNamespace = typeNamespace

    Thread.current[ :SOAPMarshalDataKey ] = {}
    addMDAry( mdAry, ary, [], mappingRegistry )
    Thread.current[ :SOAPMarshalDataKey ] = nil

    mdAry
  end


  def RPCUtils._obj2soap( obj, mappingRegistry )
    if obj.is_a?( SOAPBasetype )
      obj
    elsif obj.is_a?( SOAPStruct ) || obj.is_a?( SOAPArray )
      # Dive in to search non-SOAP data.
      obj.replace do | ele |
	RPCUtils._obj2soap( ele, mappingRegistry )
      end
      obj
    elsif referent = Thread.current[ :SOAPMarshalDataKey ][ obj.__id__ ]
      soapObj = SOAPReference.new
      soapObj.__setobj__( referent )
      soapObj
    else
      mappingRegistry.obj2soap( obj.type, obj )
    end
  end

  def RPCUtils._soap2obj( node, mappingRegistry )
    if node.is_a?( SOAPReference )
      target = node.__getobj__
      if referent = Thread.current[ :SOAPMarshalDataKey ][ target.id ]
	return referent
      else
	return RPCUtils._soap2obj( target, mappingRegistry )
      end
    end
    return mappingRegistry.soap2obj( node.type, node )
  end


  # Allow only (Letter | '_') (Letter | Digit | '-' | '_')* here.
  # Caution: '.' is not allowed here.
  # To follow XML spec., it should be NCName.
  #   (denied chars) => .[0-F][0-F]
  #   ex. a.b => a.2eb
  #
  def RPCUtils.getElementNameFromName( name )
    name.gsub( /([^a-zA-Z0-9:_-]+)/n ) {
      '.' << $1.unpack( 'H2' * $1.size ).join( '.' )
    }.gsub( /::/n, '..' )
  end

  def RPCUtils.getNameFromElementName( name )
    name.gsub( /\.\./n, '::' ).gsub( /((?:\.[0-9a-fA-F]{2})+)/n ) {
      [ $1.delete( '.' ) ].pack( 'H*' )
    }
  end

  def RPCUtils.getClassFromName( name )
    klass = Object
    name.split( '::' ).each do | klassStr |
      klass = klass.const_get( klassStr )
    end
    klass
  end

  class << RPCUtils
  private
    def addMDAry( mdAry, ary, indices, mappingRegistry )
      0.upto( ary.size - 1 ) do | idx |
       	if ary[ idx ].is_a?( Array )
  	  addMDAry( mdAry, ary[ idx ], indices + [ idx ], mappingRegistry )
   	else
  	  mdAry[ *( indices + [ idx ] ) ] = RPCUtils._obj2soap( ary[ idx ], mappingRegistry )
   	end
      end
    end
  end
end


end
