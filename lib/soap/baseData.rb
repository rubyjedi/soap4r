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
require 'xmltreebuilder'


###
## SOAP utility module for classes( not instances! )
#
class SOAPNS
  public

  attr_reader :defaultNamespace
  attr_reader :namespaceTag

  def initialize( initNamespace = {} )
    @namespaceTag = initNamespace
    @defaultNamespace = nil
  end

  def assign( namespace, name = nil )
    if ( @namespaceTag.has_key?( namespace ))
      false
    elsif ( name == '' )
      @defaultNamespace = namespace
      name
    elsif ( @namespaceTag.has_value?( name ))
      # Already assigned.  Should raise Error?
      name = SOAPNS.assign( namespace )
      @namespaceTag[ namespace ] = name
      name
    else
      name ||= SOAPNS.assign( namespace )
      @namespaceTag[ namespace ] = name
      name
    end
  end

  def []( namespace )
    if ( @namespaceTag.has_key?( namespace ))
      @namespaceTag[ namespace ]
    else
      nil
    end
  end

  def clone()
    SOAPNS.new( @namespaceTag.dup )
  end

  def name( namespace, name )
    if ( namespace == @defaultNamespace )
      name
    elsif @namespaceTag.has_key?( namespace )
      @namespaceTag[ namespace ] + ':' << name
    else
      raise FormatDecodeError.new( 'Namespace: ' << namespace << ' not defined yet.' )
    end
  end

  def compare( namespace, name, rhs )
    if ( namespace == @defaultNamespace )
      return true if ( name == rhs )
    end

    if @namespaceTag.has_key?( namespace )
      return (( @namespaceTag[ namespace ] + ':' << name ) == rhs )
    end

    return false
  end

  # $1 and $2 are necessary.
  ParseRegexp = Regexp.new( '^([^:]+)(?::(.+))?$' )

  def parse( elem )
    namespace = nil
    name = nil
    ParseRegexp =~ elem
    if $2
      namespace = @namespaceTag.index( $1 )
      name = $2
      if !namespace
	raise FormatDecodeError.new( 'Unknown namespace qualifier: ' << $1 )
      end
    elsif $1
      namespace = @defaultNamespace
      name = $1
    end
    if !name
      raise FormatDecodeError.new( "Illegal element format: #{ elem }" )
    end
    return namespace, name
  end

  private

  AssigningName = [ 0 ]

  def self.assign( namespace )
    AssigningName[ 0 ] += 1
    'n' << AssigningName[ 0 ].to_s
  end

  def self.reset()
    AssigningName[ 0 ] = 0
  end
end


###
## SOAP related datatypes.
#
module SOAPModuleUtils
  include SOAP
  include XML::SimpleTree

  public

  def decode( ns, elem )
    elem.normalize
    value = if elem.childNodes[0]
	elem.childNodes[0].nodeValue
      else
	''
      end
    d = self.new( value )
    d.namespace, = ns.parse( elem.nodeName )
    d
  end

  private

  def decodeChild( ns, elem, parentArrayType = nil )
    if isNull( ns, elem )
      return SOAPNull.decode( ns, elem )
    end

    if getArrayType( ns, elem )
      SOAPArray.decode( ns, elem )
    else
      type = getType( ns, elem ) || parentArrayType
      typeNamespace, typeNameString = ns.parse( type )
      if typeNamespace == XSD::Namespace
	case typeNameString
	when 'int'
	  SOAPInt.decode( ns, elem )
	when 'integer'
	  SOAPInteger.decode( ns, elem )
	when 'boolean'
	  SOAPBoolean.decode( ns, elem )
	when 'string'
	  SOAPString.decode( ns, elem )
	when 'timeInstant'
	  SOAPTimeInstant.decode( ns, elem )
	else
	  # Not supported... Decode as SOAPString by default.
	  SOAPString.decode( ns, elem )
	end
      else
        bOnlyText = true
        elem.childNodes.each do | child |
	  next if ( isEmptyText( child ))
	  bOnlyText = false
	  break
        end
        if bOnlyText
	  # No type is set. Decode as SOAPString by default.
	  SOAPString.decode( ns, elem )
        else
	  SOAPStruct.decode( ns, elem, parentArrayType )
        end
      end
    end
  end

  EmptyTextRegexp = Regexp.new( '\s*(?:\n\s*)*' )

  def isEmptyText( node )
    (( node.nodeName == '#text' ) and ( EmptyTextRegexp =~ node.nodeValue ))
  end

  def isNull( ns, elem )
    elem.attributes.each do | attr |
      if ( ns.compare( XSD::Namespace, 'null', attr.nodeName ))
	if attr.nodeValue == '1'
	  return true
	end
      end
    end
    false
  end

  def getType( ns, elem )
    elem.attributes.each do | attr |
      if ( ns.compare( XSD::InstanceNamespace, 'type', attr.nodeName ))
	return attr.nodeValue
      end
    end
    nil
  end

  def getArrayType( ns, elem )
    elem.attributes.each do | attr |
      if ( ns.compare( EncodingNamespace, 'arrayType', attr.nodeName ))
	return attr.nodeValue
      end
    end
    nil
  end

  # $1 is necessary.
  NSParseRegexp = Regexp.new( '^xmlns:?(.*)$' )

  def parseNS( ns, elem )
    return unless elem.attributes
    elem.attributes.each do | attr |
      next unless ( NSParseRegexp =~ attr.nodeName )
      # '' means 'default namespace'.
      tag = $1 || ''
      ns.assign( attr.nodeValue, tag )
    end
  end
end

module SOAPBasetypeUtils
  include SOAP
  include XML::SimpleTree

  attr_accessor :namespace

  public

  def initialize( *vars )
    super( *vars )
    @namespace = EnvelopeNamespace
  end

  def encode( ns, name, parentArray = nil )
    attrs = []
    createNS( attrs, ns )
    if parentArray and parentArray.typeNamespace == @typeNamespace and
	parentArray.contentTypeName == @typeName
      # No need to add.
    else
      attrs.push( datatypeAttr( ns ))
    end

    if ( self.to_s.empty? )
      Element.new( name, attrs )
    else
      Element.new( name, attrs, Text.new( self.to_s ))
    end
  end

  def ==( rhs )
    self.data == rhs
  end

  private

  def datatypeAttr( ns )
    Attr.new( ns.name( XSD::InstanceNamespace, 'type' ), ns.name( @typeNamespace, @typeName ))
  end

  def createNS( attrs, ns )
    unless ns[ XSD::Namespace ]
      tag = ns.assign( XSD::Namespace )
      attrs.push( Attr.new( 'xmlns:' << tag, XSD::Namespace ))
    end
  end
end


###
## Basic datatypes.
#
class SOAPNull < XSDNull
  extend SOAPModuleUtils
  include SOAPBasetypeUtils

  public

  # Override the definition in SOAPBasetypeUtils.
  def initialize()
    @namespace = EnvelopeNamespace
  end

  private

  # Override the definition in SOAPBasetypeUtils.
  def datatypeAttr( ns )
    Attr.new( ns.name( XSD::Namespace, 'null' ), '1' )
  end

  # Override the definition in SOAPModuleUtils
  def self.decode( ns, elem )
    d = self.new()
    d.namespace, = ns.parse( elem.nodeName )
    d
  end
end

class SOAPBoolean < XSDBoolean
  extend SOAPModuleUtils
  include SOAPBasetypeUtils
end

class SOAPString < XSDString
  extend SOAPModuleUtils
  include SOAPBasetypeUtils
end

class SOAPInteger < XSDInteger
  extend SOAPModuleUtils
  include SOAPBasetypeUtils
end

class SOAPInt < XSDInt
  extend SOAPModuleUtils
  include SOAPBasetypeUtils
end

class SOAPTimeInstant < XSDTimeInstant
  extend SOAPModuleUtils
  include SOAPBasetypeUtils
end


###
## Compound datatypes.
#
class SOAPCompoundBase < NSDBase
  extend SOAPModuleUtils

  attr_accessor :namespace

  public

  def initialize( typeName )
    super( typeName, nil )
    @namespace = EnvelopeNamespace
  end
end


class SOAPStruct < SOAPCompoundBase
  include Enumerable

  public

  attr_reader :array
  attr_reader :data

  def initialize( typeName )
    super( typeName )
    @array = []
    @data = {}
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
      if ( idx > array.size )
        raise ArrayIndexOutOfBoundsError.new( 'In ' << @typeName )
      end
      @data[ @array[ idx ]]
    else
      if has_key?( idx )
	@data[ idx ]
      else
	nil
      end
    end
  end

  def []=( idx, data )
    if @array.member?( idx )
      @data[ idx ] = data
    else
      add( idx, data )
    end
  end

  def has_key?( name )
    @data.has_key?( name )
  end

  def each
    @array.each do | key |
      yield( key, @data[ key ] )
    end
  end

  def encode( ns, name, parentArray = nil )
    attrs = []
    createNS( attrs, ns )
    if parentArray and parentArray.typeNamespace == @typeNamespace and
	parentArray.contentTypeName == @typeName
      # No need to add.
    else
      attrs.push( datatypeAttr( ns ))
    end

    children = @array.collect { | child |
      @data[ child ].encode( ns.clone, child )
    }

    Element.new( name, attrs, children )
  end

  def self.decode( ns, elem, parentArrayType = nil )
    namespace, name = ns.parse( elem.nodeName )
    s = nil
    type = getType( ns, elem ) || parentArrayType
    if type
      typeNamespace, typeNameString = ns.parse( type )
      s = SOAPStruct.new( typeNameString )
      s.typeNamespace = typeNamespace
    else
      # 'return' element?
      s = SOAPStruct.new( name )
    end

    s.namespace = namespace

    elem.childNodes.each do | child |
      childNS = ns.clone
      parseNS( childNS, child )
      next if ( isEmptyText( child ))
      childName = ns.parse( child.nodeName )[1]
      s.add( childName, decodeChild( childNS, child ))
    end
    s
  end

  private

  def datatypeAttr( ns )
    Attr.new( ns.name( XSD::InstanceNamespace, 'type' ), ns.name( @typeNamespace, @typeName ))
  end

  def createNS( attrs, ns )
    unless ns[ @namespace ]
      tag = ns.assign( @namespace )
      attrs.push( Attr.new( 'xmlns:' << tag, @namespace ))
    end
    if @typeNamespace and !ns[ @typeNamespace ]
      tag = ns.assign( @typeNamespace )
      attrs.push( Attr.new( 'xmlns:' << tag, @typeNamespace ))
    end
  end

  def addMember( name, initMember = nil )
    initMember = SOAPNull.new() unless initMember
    methodName = name.dup

    begin
      instance_eval <<-EOS
        def #{ methodName }()
	  @data[ '#{ methodName }' ]
        end

        def #{ methodName }=( newMember )
	  @data[ '#{ methodName }' ] = newMember
        end
      EOS
    rescue SyntaxError
      methodName = "var_" << methodName
      retry
    end

    @array.push( name )
    @data[ name ] = initMember
  end
end

class SOAPArray < SOAPCompoundBase
  include Enumerable

  public

  attr_reader :data

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

  def encode( ns, name, parentArray = nil )
    attrs = []
    createNS( attrs, ns )
    if parentArray and parentArray.typeNamespace == @typeNamespace and
	parentArray.contentTypeName == @typeName
      # No need to add.
    else
      attrs.push( datatypeAttr( ns ))
    end

    childTypeName = contentTypeName() << 'Array'

    children = @data[ 0 ].collect { | child |
      child.encode( ns.clone, childTypeName, self )
    }
    Element.new( name, attrs, children )
  end

  def isVariant?
    @variant
  end

  def contentTypeName()
    @typeName?  @typeName.dup.sub( /\[,*\]$/, '' ) : ''
  end

  private

  def datatypeAttr( ns )
    Attr.new( ns.name( EncodingNamespace, 'arrayType' ), ns.name( @typeNamespace, arrayTypeValue() ))
  end

  def createNS( attrs, ns )
    unless ns[ @namespace ]
      tag = ns.assign( @namespace )
      attrs.push( Attr.new( 'xmlns:' << tag, @namespace ))
    end
    if @typeNamespace and !ns[ @typeNamespace ]
      tag = ns.assign( @typeNamespace )
      attrs.push( Attr.new( 'xmlns:' << tag, @typeNamespace ))
    end
    unless ns[ EncodingNamespace ]
      tag = ns.assign( EncodingNamespace )
      attrs.push( Attr.new( 'xmlns:' << tag, EncodingNamespace ))
    end
  end

  def arrayTypeValue()
    contentTypeName() << '[' << @data.collect { |i| i.size }.join( ',' ) << ']'
  end

  # Module function

  public

  def self.decode( ns, elem )
    typeNamespace, typeNameString = ns.parse( getArrayType( ns, elem ))
    typeName, nofArray = parseType( typeNameString )
    s = SOAPArray.new( typeName )
    s.namespace, = ns.parse( elem.nodeName )

    i = 0
    elem.childNodes.each do | child |
      childNS = ns.clone
      parseNS( childNS, child )
      next if ( isEmptyText( child ))
      s.add( decodeChild( childNS, child, childNS.name( typeNamespace, typeName )))
      i += 1
      if ( nofArray and ( i > nofArray.to_i ))
	raise ArrayIndexOutOfBoundsError.new( 'In ' << elem.nodeName )
      end
    end
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
