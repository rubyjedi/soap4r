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

  def decode( ns, entity )
    d = self.new
    d.namespace, d.name = ns.parse( entity.name )
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
  attr_accessor :parent

public

  def initialize( *vars )
    super( *vars )
    @namespace = EnvelopeNamespace
    @name = nil
    @id = nil
    @parent = nil
  end

  def encode( ns, name, parentArray = nil )
    attrs = []
    createNS( attrs, ns )
    if parentArray and parentArray.typeNamespace == @typeNamespace and
	parentArray.baseTypeName == @typeName
      # No need to add.
    else
      attrs.push( datatypeAttr( ns ))
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

  def createNS( attrs, ns )
    unless ns.assigned?( XSD::Namespace )
      tag = ns.assign( XSD::Namespace )
      attrs.push( Attr.new( 'xmlns:' << tag, XSD::Namespace ))
    end
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
  attr_accessor :parent
  attr_reader :extraAttributes

public

  def initialize( typeName )
    super( typeName, nil )
    @namespace = EnvelopeNamespace
    @name = nil
    @id = nil
    @parent = nil
    @extraAttributes = []
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

  def self.decode( ns, entity, refId )
    d = super( ns, entity )
    d.refId = refId
    d
  end
end

class SOAPNil < XSDNil
  include SOAPBasetype
  extend SOAPModuleUtils

public

  # Override the definition in SOAPBasetype.
  def initialize()
    @namespace = EnvelopeNamespace
    @name = nil
    @id = nil
    @parent = nil
  end

private

  # Override the definition in SOAPBasetype.
  def datatypeAttr( ns )
    Attr.new( ns.name( XSD::Namespace, XSD::NilLiteral ), '1' )
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

class SOAPInteger < XSDInteger
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

class SOAPBase64 < XSDBase64Binary
  include SOAPBasetype
  extend SOAPModuleUtils

public

  # Override the definition in SOAPBasetype.
  def initialize( *vars )
    super( *vars )
    @typeNamespace = EnvelopeNamespace
    @typeName = 'base64'
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
    if idx.is_a?( Integer )
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

  def map!
    @data.map! do | ele |
      yield( ele )
    end
  end

  def encode( ns, name, parentArray = nil )
    attrs = @extraAttributes.collect { | attr | attr.create( ns ) }
    createNS( attrs, ns )
    if parentArray and parentArray.typeNamespace == @typeNamespace and
	parentArray.baseTypeName == @typeName
      # No need to add.
    else
      attrs.push( datatypeAttr( ns ))
    end

    children = []
    0.upto( @array.length - 1 ) do | i |
      children.push( @data[ i ].encode( ns.clone, @array[ i ] ))
    end

    # Element.new( name, attrs, children )
    Node.initializeWithChildren( name, attrs, children )
  end

  def self.decode( ns, entity, typeNamespace, typeName )
    s = SOAPStruct.new( typeName )
    s.typeNamespace = typeNamespace
    s.namespace, s.name = ns.parse( entity.name )
    s
  end

private

  def datatypeAttr( ns )
    Attr.new( ns.name( XSD::InstanceNamespace, 'type' ), ns.name( @typeNamespace, @typeName ))
  end

  def createNS( attrs, ns )
    unless ns.assigned?( @namespace )
      tag = ns.assign( @namespace )
      attrs.push( Attr.new( 'xmlns:' << tag, @namespace ))
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

  def initialize( typeName = nil )
    super( typeName )
    @data = [ [] ]
    @variant = false
    @rank = 1
  end

  def set( newArray )
    raise NotImplementError.new( 'Partially transmittion does not supported' )
  end

  def add( newMember )
    if ( @rank != 1 )
      raise NotImplementError.new( 'Rank must be 1' )
    end
    if ( @data[ 0 ].empty? and !@typeName )
      @typeName = SOAPArray.getAtype( newMember.typeName, @rank )
      @typeNamespace = newMember.typeNamespace
    end
    if @typeName
      if !newMember.typeName
	newMember.typeName = @typeName
	newMember.typeNamespace = @typeNamespace
      end
    end
    if ( @typeName != newMember.typeName )
      @variant = true
    end
    @data[ 0 ] << newMember
  end

  def []( idx )
    if ( @rank != 1 )
      raise NotImplementError.new( 'Rank must be 1' )
    end
    if ( idx > @data[ 0 ].size )
      raise ArrayIndexOutOfBoundsError.new( 'In ' << @typeName )
    end
    @data[ 0 ][ idx ]
  end

  def each
    if ( @rank != 1 )
      raise NotImplementError.new( 'Rank must be 1' )
    end
    @data[ 0 ].each do | datum |
      yield( datum )
    end
  end

  def map!
    @data.map! do | ele |
      yield( ele )
    end
  end

  def encode( ns, name, parentArray = nil )
    attrs = @extraAttributes.collect { | attr | attr.create( ns ) }
    createNS( attrs, ns )
    if parentArray and parentArray.typeNamespace == @typeNamespace and
	parentArray.baseTypeName == @typeName
      # No need to add.
    else
      attrs.push( datatypeAttr( ns ))
    end

    childTypeName = contentTypeName().gsub( /\[,*\]/, ArrayEncodePostfix ) << ArrayEncodePostfix

    children = @data[ 0 ].collect { | child |
      child.encode( ns.clone, childTypeName, self )
    }

    # Element.new( name, attrs, children )
    Node.initializeWithChildren( name, attrs, children )
  end

  def isVariant?
    @variant
  end

  def contentTypeName()
    @typeName?  @typeName.sub( /\[,*\]$/, '' ) : ''
  end

  def baseTypeName()
    @typeName?  @typeName.sub( /(?:\[,*\])+$/, '' ) : ''
  end

private

  def datatypeAttr( ns )
    Attr.new( ns.name( EncodingNamespace, 'arrayType' ), ns.name( @typeNamespace, arrayTypeValue() ))
  end

  def createNS( attrs, ns )
    unless ns.assigned?( @namespace )
      tag = ns.assign( @namespace )
      attrs.push( Attr.new( 'xmlns:' << tag, @namespace ))
    end
    if @typeNamespace and !ns.assigned?( @typeNamespace )
      tag = ns.assign( @typeNamespace )
      attrs.push( Attr.new( 'xmlns:' << tag, @typeNamespace ))
    end
    unless ns.assigned?( EncodingNamespace )
      tag = ns.assign( EncodingNamespace )
      attrs.push( Attr.new( 'xmlns:' << tag, EncodingNamespace ))
    end
  end

  def arrayTypeValue()
    contentTypeName() << '[' << @data.collect { |i| i.size }.join( ',' ) << ']'
  end

  # Module function

public

  # DEBT: Check if getArrayType returns non-nil before invoking this method.
  def self.decode( ns, entity, typeNamespace, typeNameString )
    typeName, nofArray = parseType( typeNameString )
    s = SOAPArray.new( typeName )
    s.typeNamespace = typeNamespace
    s.namespace, s.name = ns.parse( entity.name )
    s
  end

private

  def self.getAtype( typeName, rank )
    "#{ typeName }[" << ',' * ( rank - 1 ) << ']'
  end

  TypeParseRegexp = Regexp.new( '^(.+)\[(\d*)\]$' )

  def self.parseType( string )
    TypeParseRegexp =~ string
    return $1, $2
  end
end


end
