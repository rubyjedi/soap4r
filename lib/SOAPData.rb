=begin
SOAP4R
Copyright (C) 2000 NAKAMURA Hiroshi.

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

require 'SOAP'
require 'XMLSchemaDatatypes'
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
      raise FormatDecodeError.new( 'Illegal element format: ' << elem )
    end
    return namespace, name
  end

  private

  AssigningName = [ 0 ]

  def SOAPNS.assign( namespace )
    AssigningName[ 0 ] += 1
    'n' << AssigningName[ 0 ].to_s
  end

  def SOAPNS.reset()
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

  def decodeChild( ns, elem )
    if isNull( ns, elem )
      return SOAPNull.decode( ns, elem )
    end

    case getType( ns, elem )
    when 'boolean'
      SOAPBoolean.decode( ns, elem )
    when 'string'
      SOAPString.decode( ns, elem )
    when 'timeInstant'
      SOAPTimeInstant.decode( ns, elem )
    when 'integer'
      SOAPInteger.decode( ns, elem )
    when /\[\d*\]$/
      SOAPArray.decode( ns, elem )
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
	SOAPStruct.decode( ns, elem )
      end
    end
  end

  EmptyTextRegexp = Regexp.new( '\s*(?:\n\s*)*' )

  def isEmptyText( node )
    (( node.nodeName == '#text' ) and ( EmptyTextRegexp =~ node.nodeValue ))
  end

  def isNull( ns, elem )
    elem.attributes.each do | attr |
      if ( ns.compare( XSD::InstanceNamespace, 'null', '1' ))
	return true
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

  public

  attr_reader :attrs

  def initialize( *vars )
    super( *vars )

# SOAP Basetype is a XSD type.  No need to reset @namespace.
#    @namespace = EnvelopeNamespace

  end

  def encode( ns, namespace, name )
    attrs = []
    unless ns[ XSD::Namespace ]
      tag = ns.assign( XSD::Namespace )
      attrs.push( Attr.new( 'xmlns:' << tag, XSD::Namespace ))
    end

    # @typeName is in XSDBase
    attrs.push( datatypeAttr( ns ))

    if ( self.to_s.empty? )
      #Element.new( ns.name( namespace, name ), attrs )
      Element.new( name, attrs )
    else
      #Element.new( ns.name( namespace, name ), attrs, Text.new( self.to_s ))
      Element.new( name, attrs, Text.new( self.to_s ))
    end
  end

  def ==( rhs )
    self.data == rhs
  end

  private

  def datatypeAttr( ns )
    Attr.new( ns.name( XSD::InstanceNamespace, 'type' ), ns.name( @namespace, @typeName ))
  end
end


###
## Basic datatypes.
#
class SOAPNull < XSDNull
  extend SOAPModuleUtils
  include SOAPBasetypeUtils

  private

  # Override the definition in SOAPBasetypeUtils.
  def datatypeAttr( ns )
    Attr.new( ns.name( XSD::Namespace, 'null' ), '1' )
  end

  # Override the definition in SOAPModuleUtils
  def decode( ns, elem )
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

class SOAPTimeInstant < XSDTimeInstant
  extend SOAPModuleUtils
  include SOAPBasetypeUtils
end


###
## Compound datatypes.
#
class SOAPCompoundBase < NSDBase
  extend SOAPModuleUtils

  public

  def initialize( typeName )
    super( typeName, EnvelopeNamespace )
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
    if ( idx > array.size )
      raise ArrayIndexOutOfBoundsError.new( 'In ' << @typeName )
    end
    @array[ idx ]
  end

  def has_key?( name )
    @data.has_key?( name )
  end

  def each
    @array.each do | key |
      yield( key, @data[ key ] )
    end
  end

  def encode( ns, namespace, name )
    attrs = []
    unless ns[ @namespace ]
      tag = ns.assign( @namespace )
      attrs.push( Attr.new( 'xmlns:' << tag, @namespace ))
    end

    attrs.push( Attr.new( ns.name( XSD::InstanceNamespace, 'type' ), ns.name( @namespace, @typeName )))

    children = @array.collect { | child |
      @data[ child ].encode( ns.clone, namespace, child )
    }

    #Element.new( ns.name( namespace, name ), attrs, children )
    Element.new( name, attrs, children )
  end

  def decode( ns, elem )
    namespace, name = ns.parse( elem.nodeName )
    s = SOAPStruct.new( name )
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
  module_function :decode

  private

  def addMember( name, initMember = nil )
    initMember = SOAPNull.new() unless initMember

    instance_eval <<-EOS
      def #{ name }()
	@data[ '#{ name }' ]
      end

      def #{ name }=( newMember )
	@data[ '#{ name }' ] = newMember
      end
    EOS

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
    @data = []
    @variant = false
  end

  def set( newArray )
    raise NotImplementError.new( 'Partially transmittion does not supported' )
  end

  def add( newMember )
    if ( @data.empty? and !@typeName )
      @typeName = newMember.typeName
    end
    if ( @typeName != newMember.typeName )
      @variant = true
    end
    @data << newMember
  end

  def []( idx )
    if ( idx > @data.size )
      raise ArrayIndexOutOfBoundsError.new( 'In ' << @typeName )
    end
    @data[ idx ]
  end

  def each
    @data.each do | datum |
      yield( datum )
    end
  end

  def encode( ns, namespace, name )
    children = @data.collect { | child |
      child.encode( ns.clone, namespace, @typeName )
    }
    attr = Attr.new( ns.name( XSD::InstanceNamespace, 'type' ),
      ns.name( namespace, createType( @typeName, @data.size )))
    #Element.new( ns.name( namespace, name ), attr, children )
    Element.new( name, attr, children )
  end

  def isVariant?
    @variant
  end

  # Module function

  public

  def decode( ns, elem )
    typeNamespace, typeNameString = ns.parse( getType( ns, elem ))
    typeName, nofArray = parseType( typeNameString )
    s = SOAPArray.new( typeName )
    s.namespace, = ns.parse( elem.nodeName )

    i = 0
    elem.childNodes.each do | child |
      childNS = ns.clone
      parseNS( childNS, child )
      next if ( isEmptyText( child ))
      s.add( decodeChild( childNS, child ))
      i += 1
      if ( nofArray and ( i > nofArray.to_i ))
	raise ArrayIndexOutOfBoundsError.new( 'In ' << elem.nodeName )
      end
    end
    s
  end
  module_function :decode

  private

  def createType( typeName, length = nil )
    "#{ typeName }[#{ length }]"
  end
  module_function :createType

  TypeParseRegexp = Regexp.new( '^(.+)\[(\d*)\]$' )

  def parseType( string )
    TypeParseRegexp =~ string
    return $1, $2
  end
  module_function :parseType
end
