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
      self[ 'fault' ]
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
    RETVAL = 'retval'
    IN = 'in'
    OUT = 'out'
    INOUT = 'inout'

    attr_reader :paramDef
    attr_reader :inParam
    attr_reader :outParam

    def initialize( namespace, name, paramDef = nil )
      super( nil )
      @elementName = XSD::QName.new( namespace, name )
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
      @paramSignature.each do | ioType, name, paramType |
	if type.include?( ioType )
	  yield( name )
	end
      end
    end
  
    def setParams( params )
      params.each do | param, data |
        @inParam[ param ] = data
	data.elementName.name = param
      end
    end

    def setOutParams( params )
      params.each do | param, data |
	@outParam[ param ] = data
	data.elementName.name = param
      end
    end

# Defined in derived class.
#    def each
#      eachParamName( IN, INOUT ) do | name |
#	unless @inParam[ name ]
#	  raise ParameterError.new( "Parameter: #{ name } was not given." )
#	end
#	yield( name, @inParam[ name ] )
#      end
#    end

    def SOAPMethod.createParamDef( paramNames )
      paramDef = []
      paramNames.each do | paramName |
	paramDef.push( [ IN, paramName, nil ] )
      end
      paramDef.push( [ RETVAL, 'return', nil ] )
      paramDef
    end

    def SOAPMethod.getParamNames( paramDef )
      paramDef.collect { | ioType, name, type | name }
    end

  private

    def setParamDef
      @paramDef.each do | ioType, name, paramType |
  	case ioType
  	when IN
	  @paramSignature.push( [ IN, name, paramType ] )
	  @inParamNames.push( name )
  	when OUT
	  @paramSignature.push( [ OUT, name, paramType ] )
	  @outParamNames.push( name )
  	when INOUT
	  @paramSignature.push( [ INOUT, name, paramType ] )
	  @inoutParamNames.push( name )
  	when RETVAL
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
    attr_accessor :soapAction
  
    def SOAPMethodRequest.createRequest( namespace, name, *params )
      paramDef = []
      paramValue = []
      i = 0
      params.each do | param |
	paramName = "p#{ i }"
	i += 1
	paramDef << [ IN, nil, paramName ]
	paramValue << [ paramName, param ]
      end
      paramDef << [ RETVAL, nil, 'return' ]
      o = new( namespace, name, paramDef )
      o.setParams( paramValue )
      o
    end

    def initialize( namespace, name, paramDef = nil, soapAction = nil )
      super( namespace, name, paramDef )
      @soapAction = soapAction
    end

    def each
      eachParamName( IN, INOUT ) do | name |
	unless @inParam[ name ]
	  raise ParameterError.new( "Parameter: #{ name } was not given." )
	end
	yield( name, @inParam[ name ] )
      end
    end

    def dup
      req = self.class.new( @elementName.namespace, @elementName.name,
	@paramDef, @soapAction )
      req.encodingStyle = @encodingStyle
      req
    end

    def createMethodResponse
      response = SOAPMethodResponse.new( @elementName.namespace,
	@elementName.name + 'Response', @paramDef )
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
      @retVal.elementName.name = 'return'
    end
  
    def each
      if @retName and !@retVal.is_a?( SOAPVoid )
	yield( @retName, @retVal )
      end

      eachParamName( OUT, INOUT ) do | paramName |
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
  class SOAPVoid < XSDAnyType
    include SOAPBasetype
    extend SOAPModuleUtils
    Name = XSD::QName.new( RubyCustomTypeNamespace, nil )

  public
    def initialize()
      @elementName = Name
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


  def RPCUtils.ary2soap( ary, typeNamespace = XSD::Namespace,
      typeName = XSD::AnyTypeLiteral, mappingRegistry = MappingRegistry.new )
    soapAry = SOAPArray.new( XSD::QName.new( typeNamespace, typeName ))
    Thread.current[ :SOAPMarshalDataKey ] = {}
    ary.each do | ele |
      soapAry.add( RPCUtils._obj2soap( ele, mappingRegistry ))
    end
    Thread.current[ :SOAPMarshalDataKey ] = nil
    soapAry
  end

  def RPCUtils.ary2md( ary, rank, typeNamespace = XSD::Namespace,
      typeName = XSD::AnyTypeLiteral, mappingRegistry = MappingRegistry.new )
    mdAry = SOAPArray.new( XSD::QName.new( typeNamespace, typeName ), rank )
    Thread.current[ :SOAPMarshalDataKey ] = {}
    addMDAry( mdAry, ary, [], mappingRegistry )
    Thread.current[ :SOAPMarshalDataKey ] = nil
    mdAry
  end

  def RPCUtils.fault2exception( e, mappingRegistry = nil )
    detail = if e.detail
	RPCUtils.soap2obj( e.detail, mappingRegistry ) || ""
      else
      	""
      end
    if detail.is_a?( RPCUtils::SOAPException )
      begin
	raise detail.to_e
      rescue Exception => e2
  	detail.set_backtrace( e2 )
	raise
      end
    else
      e.detail = detail
      e.set_backtrace(
	if detail.is_a?( Array )
     	  detail.map! { |s|
  	    s.sub( /^/, @handler.endPoint + ':' )
	  }
     	else
  	  [ detail.to_s ]
	end
      )
      raise
    end
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
      mappingRegistry.obj2soap( obj.class, obj )
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
    return mappingRegistry.soap2obj( node.class, node )
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
    if /^[A-Z]/ !~ name
      return nil
    end
    klass = ::Object
    name.split( '::' ).each do | klassStr |
      if klass.const_defined?( klassStr )
	klass = klass.const_get( klassStr )
      else
	return nil
      end
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
