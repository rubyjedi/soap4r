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
require 'soap/namespace'
require 'soap/nqxmlDocument'


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
  include NQXML

  attr_accessor :namespace
  attr_accessor :name
  attr_accessor :id
  attr_accessor :root
  attr_accessor :parent
  attr_accessor :position

public

  def initialize( *vars )
    super( *vars )
    @namespace = EnvelopeNamespace
    @name = nil
    @id = nil
    @parent = nil
    @position = nil
  end

  def encode( ns, name, parentEncodingStyle = nil, parentArray = nil )
    attrs = []
    addNSDeclAttr( attrs, ns )
    if parentEncodingStyle != EncodingNamespace
      addEncodingAttr( attrs, ns )
    end
    if parentArray && parentArray.typeNamespace == @typeNamespace &&
	parentArray.baseTypeName == @typeName
      # No need to add.
    else
      attrs.push( datatypeAttr( ns ))
    end

    if parentArray && parentArray.position
      attrs.push( positionAttr( parentArray.position, ns ))
    end

    if ( self.to_s.empty? )
      # Element.new( name, attrs )
      Node.initializeWithChildren( name, attrs )
    else
      # Element.new( name, attrs, Text.new( self.to_s ))
      Node.initializeWithChildren( name, attrs, Text.new( self.to_s ))
    end
  end

private

  def datatypeAttr( ns )
    Attr.new( ns.name( XSD::InstanceNamespace, 'type' ), ns.name( @typeNamespace, @typeName ))
  end

  def positionAttr( position, ns )
    Attr.new( ns.name( EncodingNamespace, AttrPosition ), '[' << position.join( ',' ) << ']' )
  end

  def addNSDeclAttr( attrs, ns )
    unless ns.assigned?( XSD::InstanceNamespace )
      tag = ns.assign( XSD::InstanceNamespace )
      attrs.push( Attr.new( 'xmlns:' << tag, XSD::InstanceNamespace ))
    end
    if @typeNamespace and !ns.assigned?( @typeNamespace )
      tag = ns.assign( @typeNamespace )
      attrs.push( Attr.new( 'xmlns:' << tag, @typeNamespace ))
    end
  end

  def addEncodingAttr( attrs, ns )
    attrs.push( Attr.new( ns.name( EnvelopeNamespace, AttrEncodingStyle ), EncodingNamespace ))
  end
end


###
## Mix-in module for SOAP compound type instances.
#
module SOAPCompoundtype
  include SOAP
  include NQXML

  attr_accessor :namespace
  attr_accessor :name
  attr_accessor :id
  attr_accessor :root
  attr_accessor :parent
  attr_accessor :position

  attr_reader :extraAttributes

public

  def initialize( typeName )
    super( typeName, nil )
    @namespace = EnvelopeNamespace
    @name = nil
    @id = nil
    @parent = nil
    @position = nil
    @extraAttributes = []
  end

private

  def positionAttr( position, ns )
    Attr.new( ns.name( EncodingNamespace, AttrPosition ), '[' << position.join( ',' ) << ']' )
  end

  def addEncodingAttr( attrs, ns )
    attrs.push( Attr.new( ns.name( EnvelopeNamespace, AttrEncodingStyle ), EncodingNamespace ))
  end
end


class SOAPExtraAttributes
  include NQXML

  def initialize( keyNamespace, keyName, valueNamespace, valueName )
    @keyNamespace = keyNamespace
    @keyName = keyName
    @valueNamespace = valueNamespace
    @valueName = valueName
  end

  def create( ns )
    key = if @keyNamespace
	ns.name( @keyNamespace, @keyName )
      else
	@keyName
      end
    value = if @valueNamespace
	ns.name( @valueNamespace, @valueName )
      else
	@valueName
      end
    Attr.new( key, value )
  end
end


###
## Basic datatypes.
#
class SOAPReference < NSDBase
  include SOAPBasetype
  extend SOAPModuleUtils

public

  attr_accessor :refId

  # Override the definition in SOAPBasetype.
  def initialize( refId = nil )
    @namespace = EnvelopeNamespace
    @name = nil
    @id = nil
    @parent = nil
    @refId = refId
    @obj = nil
  end

  def __getobj__
    @obj
  end

  def __setobj__( obj )
    @obj = obj
    # Copies NSDBase information
    obj.typeName = @typeName unless obj.typeName
    obj.typeNamespace = @typeNamespace unless obj.typeNamespace
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
end

class SOAPNil < XSDNil
  include SOAPBasetype
  extend SOAPModuleUtils

private

  # Override the definition in SOAPBasetype.
  def datatypeAttr( ns )
    Attr.new( ns.name( XSD::Namespace, XSD::NilLiteral ), XSD::NilValue )
  end
end

class SOAPBoolean < XSDBoolean
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPString < XSDString
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

class SOAPDecimal < XSDDecimal
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

class SOAPDateTime < XSDDateTime
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPDate < XSDDate
  include SOAPBasetype
  extend SOAPModuleUtils
end

class SOAPTime < XSDTime
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

  def addNSDeclAttr( attrs, ns )
    unless ns.assigned?( XSD::InstanceNamespace )
      tag = ns.assign( XSD::InstanceNamespace )
      attrs.push( Attr.new( 'xmlns:' << tag, XSD::InstanceNamespace ))
    end
    if @typeNamespace and !ns.assigned?( @typeNamespace )
      tag = ns.assign( @typeNamespace )
      attrs.push( Attr.new( 'xmlns:' << tag, @typeNamespace ))
    end
  end
end


###
## Compound datatypes.
#
class SOAPStruct < NSDBase
  include SOAPCompoundtype
  include Enumerable

public

  def initialize( typeName )
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
      if @array.member?( idx )
	@data[ @array.index( idx ) ]
      else
	nil
      end
    end
  end

  def []=( idx, data )
    if @array.member?( idx )
      @data[ @array.index( idx ) ] = data
    else
      add( idx, data )
    end
  end

  def has_key?( name )
    @array.member?( name )
  end

  def members
    @array
  end

  def each
    0.upto( @array.length - 1 ) do | i |
      yield( @array[ i ], @data[ i ] )
    end
  end

  def encode( ns, name, parentEncodingStyle = nil, parentArray = nil )
    attrs = @extraAttributes.collect { | attr | attr.create( ns ) }
    addNSDeclAttr( attrs, ns )
    if parentEncodingStyle != EncodingNamespace
      addEncodingAttr( attrs, ns )
    end
    if parentArray && parentArray.typeNamespace == @typeNamespace &&
	parentArray.baseTypeName == @typeName
      # No need to add.
    else
      attrs.push( datatypeAttr( ns ))
    end

    if parentArray && parentArray.position
      attrs.push( positionAttr( parentArray.position, ns ))
    end

    children = []
    0.upto( @array.length - 1 ) do | i |
      children.push( @data[ i ].encode( ns.clone, @array[ i ], EncodingNamespace ))
    end

    # Element.new( name, attrs, children )
    Node.initializeWithChildren( name, attrs, children )
  end

  def self.decode( ns, name, typeNamespace, typeName )
    s = SOAPStruct.new( typeName )
    s.typeNamespace = typeNamespace
    s.namespace, s.name = ns.parse( name )
    s
  end

private

  def datatypeAttr( ns )
    Attr.new( ns.name( XSD::InstanceNamespace, 'type' ), ns.name( @typeNamespace, @typeName ))
  end

  def addNSDeclAttr( attrs, ns )
    unless ns.assigned?( EncodingNamespace )
      tag = ns.assign( EncodingNamespace )
      attrs.push( Attr.new( 'xmlns:' << tag, EncodingNamespace ))
    end
    unless ns.assigned?( @namespace )
      tag = ns.assign( @namespace )
      attrs.push( Attr.new( 'xmlns:' << tag, @namespace ))
    end
    unless ns.assigned?( XSD::InstanceNamespace )
      tag = ns.assign( XSD::InstanceNamespace )
      attrs.push( Attr.new( 'xmlns:' << tag, XSD::InstanceNamespace ))
    end
    if @typeNamespace and !ns.assigned?( @typeNamespace )
      tag = ns.assign( @typeNamespace )
      attrs.push( Attr.new( 'xmlns:' << tag, @typeNamespace ))
    end
  end

  def addMember( name, initMember = nil )
    initMember = SOAPNil.new() unless initMember
    methodName = name.dup

    begin
      instance_eval <<-EOS
        def #{ methodName }()
	  @data[ @array.index( '#{ methodName }' ) ]
        end

        def #{ methodName }=( newMember )
	  @data[ @array.index( '#{ methodName }' ) ] = newMember
        end
      EOS
    rescue SyntaxError
      methodName = "var_" << methodName.gsub( /[^a-zA-Z0-9_]/, '' )
      retry
    end

    @array.push( name )
    @data.push( initMember )
  end
end


class SOAPArray < NSDBase
  include SOAPCompoundtype
  include Enumerable

public

  ArrayEncodePostfix = 'Ary'

  attr_reader :offset, :rank
  attr_accessor :sparse, :size, :sizeFixed

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

  def set( newArray )
    raise NotImplementError.new( 'Partially transmittion does not supported' )
  end

  def add( newMember )
    self[ *( @offset ) ] = newMember
    offsetNext
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
      raise ArgumentError.new( "Given #{ idxAry.size } params does not match rank: #{ @rank }" )
    end

    0.upto( idxAry.size - 1 ) do | i |
      if idxAry[ i ] + 1 > @size[ i ]
	@size[ i ] = idxAry[ i ] + 1
      end
    end

    data = retrieve( idxAry[ 0..-2 ] )
    data[ idxAry.last ] = value

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

  def each
    @data.each do | data |
      yield( data )
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
	yield( v, *rank ) unless v.is_a?( SOAPNil )
      end
    end
  end

  def soap2array
    ary = []
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

    ary
  end

  def encode( ns, name, parentEncodingStyle = nil, parentArray = nil )
    attrs = @extraAttributes.collect { | attr | attr.create( ns ) }
    addNSDeclAttr( attrs, ns )
    if parentEncodingStyle != EncodingNamespace
      addEncodingAttr( attrs, ns )
    end

    attrs.push( arrayTypeAttr( ns ))
    attrs.push( datatypeAttr( ns ))

    if parentArray && parentArray.position
      attrs.push( positionAttr( parentArray.position, ns ))
    end

    childTypeName = contentTypeName().gsub( /\[,*\]/, ArrayEncodePostfix ) << ArrayEncodePostfix

    children = []
    traverse do | child, *rank |
      unless @sparse
	@position = nil
      else
	@position = rank
      end
      children << child.encode( ns.clone, childTypeName, EncodingNamespace, self )
    end

    # Element.new( name, attrs, children )
    Node.initializeWithChildren( name, attrs, children )
  end

  def contentTypeName()
    @typeName?  @typeName.sub( /\[,*\]$/, '' ) : ''
  end

  def baseTypeName()
    @typeName?  @typeName.sub( /(?:\[,*\])+$/, '' ) : ''
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

  def datatypeAttr( ns )
    Attr.new( ns.name( XSD::InstanceNamespace, 'type' ), ns.name( EncodingNamespace, 'Array' ))
  end

  def arrayTypeAttr( ns )
    Attr.new( ns.name( EncodingNamespace, 'arrayType' ), ns.name( @typeNamespace, arrayTypeValue() ))
  end

  def addNSDeclAttr( attrs, ns )
    unless ns.assigned?( EncodingNamespace )
      tag = ns.assign( EncodingNamespace )
      attrs.push( Attr.new( 'xmlns:' << tag, EncodingNamespace ))
    end
    unless ns.assigned?( @namespace )
      tag = ns.assign( @namespace )
      attrs.push( Attr.new( 'xmlns:' << tag, @namespace ))
    end
    unless ns.assigned?( XSD::InstanceNamespace )
      tag = ns.assign( XSD::InstanceNamespace )
      attrs.push( Attr.new( 'xmlns:' << tag, XSD::InstanceNamespace ))
    end
    if @typeNamespace and !ns.assigned?( @typeNamespace )
      tag = ns.assign( @typeNamespace )
      attrs.push( Attr.new( 'xmlns:' << tag, @typeNamespace ))
    end
  end

  def arrayTypeValue()
    contentTypeName() << '[' << @size.join( ',' ) << ']'
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
