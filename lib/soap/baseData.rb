=begin
SOAP4R - Base type library
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

require 'soap/soap'
require 'soap/XMLSchemaDatatypes'


module SOAP


###
## Mix-in module for SOAP base type classes.
#
module SOAPModuleUtils
  include SOAP

public

  def decode( ns, name )
    d = self.new
    d.namespace, d.name = ns.parse( name )
    d
  end
end


###
## Mix-in module for SOAP base type instances.
#
module SOAPBasetype
  include SOAP

  attr_accessor :encodingStyle

  attr_accessor :namespace
  attr_accessor :name
  attr_accessor :id
  attr_reader :precedents
  attr_accessor :root
  attr_accessor :parent
  attr_accessor :position

public

  def initialize( *vars )
    super( *vars )
    @encodingStyle = nil
    @namespace = nil
    @name = nil
    @id = nil
    @precedents = []
    @parent = nil
    @position = nil
  end
end


###
## Mix-in module for SOAP compound type instances.
#
module SOAPCompoundtype
  include SOAP

  attr_accessor :encodingStyle

  attr_accessor :namespace
  attr_accessor :name
  attr_accessor :id
  attr_reader :precedents
  attr_accessor :root
  attr_accessor :parent
  attr_accessor :position

public

  def initialize( typeName )
    super( typeName, nil )
    @encodingStyle = nil
    @namespace = nil
    @name = nil
    @id = nil
    @precedents = []
    @root = false
    @parent = nil
    @position = nil
  end
end


###
## Convenience datatypes.
#
class SOAPReference < NSDBase
  include SOAPBasetype
  extend SOAPModuleUtils

public

  attr_accessor :refId

  # Override the definition in SOAPBasetype.
  def initialize( refId = nil )
    super( nil, nil )
    @encodingStyle = nil
    @namespace = nil
    @name = nil
    @id = nil
    @precedents = []
    @root = false
    @parent = nil
    @refId = refId
    @obj = nil
  end

  def __getobj__
    @obj
  end

  def __setobj__( obj )
    @obj = obj
    @refId = SOAPReference.createId( @obj )
    @obj.id = @refId unless @obj.id
    @obj.precedents << self
    # Copies NSDBase information
    @obj.typeName = @typeName unless obj.typeName
    @obj.typeNamespace = @typeNamespace unless @obj.typeNamespace
  end

  # Why don't I use delegate.rb?
  # -> delegate requires target object type at initialize time.
  # Why don't I use forwardable.rb?
  # -> forwardable requires a list of forwarding methods.
  #
  # ToDo: Maybe I should use forwardable.rb and give it a methods list like
  # delegate.rb...
  #
  def method_missing( msg_id, *params )
    if @obj
      @obj.send( msg_id, *params )
    else
      nil
    end
  end

  def self.decode( ns, name, refId )
    d = super( ns, name )
    d.refId = refId
    d
  end

  def SOAPReference.createId( obj )
    'id' << obj.__id__.to_s
  end
end

class SOAPNil < XSDNil
  include SOAPBasetype
  extend SOAPModuleUtils

private

  # Override the definition in SOAPBasetype.
  def datatypeAttr( ns )
    Attr.new( ns.name( XSD::InstanceNamespace, XSD::NilLiteral ), XSD::NilValue )
  end
end

# SOAPRawString is for sending raw string.  In contrast to SOAPString,
# SOAP4R does not do XML encoding and does not convert its CES.  The string it
# holds is embedded to XML instance directly as a 'xsd:string'.
class SOAPRawString < XSDString
  include SOAPBasetype
  extend SOAPModuleUtils
end


###
## Basic datatypes.
#
class SOAPString < XSDString
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPBoolean < XSDBoolean
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPDecimal < XSDDecimal
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPFloat < XSDFloat
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPDouble < XSDDouble
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPDuration < XSDDuration
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPDateTime < XSDDateTime
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPTime < XSDTime
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPDate < XSDDate
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPGYearMonth < XSDGYearMonth
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPGYear < XSDGYear
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPGMonthDay < XSDGMonthDay
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPGDay < XSDGDay
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPGMonth < XSDGMonth
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPHexBinary < XSDHexBinary
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPBase64 < XSDBase64Binary
  include SOAPBasetype
  extend SOAPModuleUtils

public
  # Override the definition in SOAPBasetype.
  def initialize( *vars )
    super( *vars )
    @typeNamespace = EncodingNamespace
    @typeName = Base64Literal
  end

  def asXSD
    @typeNamespace = XSD::Namespace
    @typeName = XSD::Base64BinaryLiteral
  end
end

class SOAPAnyURI < XSDAnyURI
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPQName < XSDQName
  include SOAPBasetype
  extend SOAPModuleUtils
end


class SOAPInteger < XSDInteger
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPLong < XSDLong
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPInt < XSDInt
  include SOAPBasetype
  extend SOAPModuleUtils
end


###
## Compound datatypes.
#
class SOAPStruct < NSDBase
  include SOAPCompoundtype
  include Enumerable

public

  def initialize( typeName = nil )
    super( typeName )
    @array = []
    @data = []
  end

  def to_s()
    str = ''
    self.each do | key, data |
      str << "#{ key }: #{ data }\n"
    end
    str
  end

  def add( name, newMember )
    addMember( name, newMember )
  end

  def []( idx )
    if idx.is_a?( Range )
      @data[ idx ]
    elsif idx.is_a?( Integer )
      if ( idx > @array.size )
        raise ArrayIndexOutOfBoundsError.new( 'In ' << @typeName )
      end
      @data[ idx ]
    else
      if @array.include?( idx )
	@data[ @array.index( idx ) ]
      else
	nil
      end
    end
  end

  def []=( idx, data )
    if @array.include?( idx )
      @data[ @array.index( idx ) ] = data
    else
      add( idx, data )
    end
  end

  def has_key?( name )
    @array.include?( name )
  end

  def members
    @array
  end

  def each
    0.upto( @array.length - 1 ) do | i |
      yield( @array[ i ], @data[ i ] )
    end
  end

  def replace
    members.each do | member |
      self[ member ] = yield( self[ member ] )
    end
  end

  def self.decode( ns, name, typeNamespace, typeName )
    s = SOAPStruct.new( typeName )
    s.typeNamespace = typeNamespace
    s.namespace, s.name = ns.parse( name )
    s
  end

private

  def addMember( name, initMember = nil )
    initMember = SOAPNil.new() unless initMember
    @array.push( name )
    initMember.name = name
    @data.push( initMember )
  end
end


# SOAPElement is not typed so it does not derive NSDBase.
class SOAPElement
  include SOAPCompoundtype
  include Enumerable

public

  attr_accessor :qualified

  def initialize( namespace, name, text = nil )
    @encodingStyle = LiteralNamespace
    @namespace = namespace
    @name = name

    @id = nil
    @precedents = []
    @root = false
    @parent = nil
    @position = nil

    @qualified = false
    @array = []
    @data = []
    @attrs = {}		# Should I allow plural attributes?
    @text = text
  end

  # Attribute interface.
  def attr
    @attrs
  end

  # Text interface.
  attr_accessor :text

  # Element interfaces.
  def add( newMember )
    addMember( newMember.name, newMember )
  end

  def []( idx )
    if @array.include?( idx )
      @data[ @array.index( idx ) ]
    else
      nil
    end
  end

  def []=( idx, data )
    if @array.include?( idx )
      @data[ @array.index( idx ) ] = data
    else
      add( data )
    end
  end

  def has_key?( name )
    @array.include?( name )
  end

  def members
    @array
  end

  def each
    0.upto( @array.length - 1 ) do | i |
      yield( @array[ i ], @data[ i ] )
    end
  end

  def self.decode( ns, name )
    o = SOAPElement.new
    o.namespace, o.name = ns.parse( name )
    o
  end

private

  def addMember( name, initMember = nil )
    initMember = SOAPNil.new() unless initMember
    addAccessor( name )
    @array.push( name )
    initMember.name = name
    @data.push( initMember )
  end

  def addAccessor( name )
    methodName = name
    if self.methods.include?( methodName )
      methodName = safeAccessorName( methodName )
    end
    begin
      instance_eval <<-EOS
        def #{ methodName }()
	  @data[ @array.index( '#{ name }' ) ]
        end

        def #{ methodName }=( newMember )
	  @data[ @array.index( '#{ name }' ) ] = newMember
        end
      EOS
    rescue SyntaxError
      methodName = safeAccessorName( methodName )
      retry
    end
  end

  def safeAccessorName( name )
    "var_" << name.gsub( /[^a-zA-Z0-9_]/, '' )
  end
end


class SOAPArray < NSDBase
  include SOAPCompoundtype
  include Enumerable

public

  ArrayEncodePostfix = 'Ary'

  attr_accessor :sparse

  attr_reader :offset, :rank
  attr_accessor :size, :sizeFixed

  def initialize( typeName = nil, rank = 1 )
    super( typeName )
    @rank = rank
    @data = Array.new
    @sparse = false
    @offset = Array.new( rank, 0 )
    @size = Array.new( rank, 0 )
    @sizeFixed = false
    @position = nil
  end

  def offset=( var )
    @offset = var
    @sparse = true
  end

  def add( newMember )
    self[ *( @offset ) ] = newMember
  end

  def []( *idxAry )
    if idxAry.size != @rank
      raise ArgumentError.new( "Given #{ idxAry.size } params does not match rank: #{ @rank }" )
    end

    retrieve( idxAry )
  end

  def []=( *idxAry )
    value = idxAry.slice!( -1 )

    if idxAry.size != @rank
      raise ArgumentError.new( "Given #{ idxAry.size } params(#{ idxAry }) does not match rank: #{ @rank }" )
    end

    0.upto( idxAry.size - 1 ) do | i |
      if idxAry[ i ] + 1 > @size[ i ]
	@size[ i ] = idxAry[ i ] + 1
      end
    end

    data = retrieve( idxAry[ 0..-2 ] )
    data[ idxAry.last ] = value

    if value.is_a?( SOAPBasetype ) || value.is_a?( SOAPCompoundtype )
      value.name = 'item'

      # Sync type
      unless @typeName
	@typeName = SOAPArray.getAtype( value.typeName, @rank )
	@typeNamespace = value.typeNamespace
      end

      unless value.typeName
	value.typeName = @typeName
	value.typeNamespace = @typeNamespace
      end
    end

    @offset = idxAry
    offsetNext
  end

  def each
    @data.each do | data |
      yield( data )
    end
  end

  def replace
    @data = doDeepMap( @data ) do | ele |
      yield( ele )
    end
  end

  def doDeepMap( ary, &block )
    ary.collect do | ele |
      if ele.is_a?( Array )
	doDeepMap( ele, &block )
      else
	newObj = block.call( ele )
	newObj.name = 'item'
	newObj
      end
    end
  end

  def include?( var )
    traverseData( @data ) do | v, *rank |
      if v.is_a?( SOAPBasetype ) && v.data == var
	return true
      end
    end
    false
  end

  def traverse
    traverseData( @data ) do | v, *rank |
      unless @sparse
       yield( v )
      else
       yield( v, *rank ) if v && !v.is_a?( SOAPNil )
      end
    end
  end

  def soap2array( ary )
    traverseData( @data ) do | v, *position |
      iteAry = ary
      1.upto( position.size - 1 ) do | rank |
	idx = position[ rank - 1 ]
	if iteAry[ idx ].nil?
	  iteAry = iteAry[ idx ] = Array.new
	else
	  iteAry = iteAry[ idx ]
	end
      end
      if block_given?
	iteAry[ position.last ] = yield( v )
      else
	iteAry[ position.last ] = v
      end
    end
  end

  def baseTypeName()
    @typeName ?  @typeName.sub( /(?:\[,*\])+$/, '' ) : ''
  end

  def position
    @position
  end

private

  def retrieve( idxAry )
    data = @data
    1.upto( idxAry.size ) do | rank |
      idx = idxAry[ rank - 1 ]
      if data[ idx ].nil?
	data = data[ idx ] = Array.new
      else
	data = data[ idx ]
      end
    end
    data
  end

  def traverseData( data, rank = 1 )
    0.upto( rankSize( rank ) - 1 ) do | idx |
      if rank < @rank
	traverseData( data[ idx ], rank + 1 ) do | *v |
	  v[ 1, 0 ] = idx
       	  yield( *v )
	end
      else
	yield( data[ idx ], idx )
      end
    end
  end

  def rankSize( rank )
    @size[ rank - 1 ]
  end

  def offsetNext
    move = false
    idx = @offset.size - 1
    while !move && idx >= 0
      @offset[ idx ] += 1
      if @sizeFixed
	if @offset[ idx ] < @size[ idx ]
	  move = true
	else
	  @offset[ idx ] = 0
	  idx -= 1
	end
      else
	move = true
      end
    end
  end

  # Module function

public

  # DEBT: Check if getArrayType returns non-nil before invoking this method.
  def self.decode( ns, name, typeNamespace, typeNameString )
    typeName, nofArray = parseType( typeNameString )
    o = SOAPArray.new( typeName, nofArray.count( ',' ) + 1 )

    size = []
    nofArray.split( ',' ).each do | s |
      if s.empty?
	size.clear
	break
      else
	size << s.to_i
      end
    end

    unless size.empty?
      o.size = size
      o.sizeFixed = true
    end

    o.typeNamespace = typeNamespace
    o.namespace, o.name = ns.parse( name )
    o
  end

private

  def self.getAtype( typeName, rank )
    "#{ typeName }[" << ',' * ( rank - 1 ) << ']'
  end

  TypeParseRegexp = Regexp.new( '^(.+)\[([\d,]*)\]$' )

  def self.parseType( string )
    TypeParseRegexp =~ string
    return $1, $2
  end
end


end
