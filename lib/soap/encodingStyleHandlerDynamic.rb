=begin
SOAP4R - SOAP Dynamic EncodingStyle handler library
Copyright (C) 2001 NAKAMURA Hiroshi.

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

require 'soap/encodingStyleHandler'


module SOAP


class SOAPEncodingStyleHandlerDynamic < EncodingStyleHandler
  Namespace = SOAP::EncodingNamespace
  addHandler
  attr_accessor :encodeType

  def initialize
    @referencePool = []
    @idPool = []
    @textBuf = ''
    @encodeType = true
    @decodeComplexTypes = nil
    @decodeTopElementCount = 0
  end


  ###
  ## encode interface.
  #
  def encodeData( buf, ns, qualified, data, parent )
    attrs = encodeAttrs( ns, qualified, data, parent )

    if parent && parent.is_a?( SOAPArray ) && parent.position
      attrs[ ns.name( AttrPositionName ) ] =
	'[' << parent.position.join( ',' ) << ']'
    end

    name = nil
    if qualified and data.elementName.namespace
      if !ns.assigned?( data.elementName.namespace )
	tag = ns.assign( data.elementName.namespace )
	attrs[ 'xmlns:' << tag ] = data.elementName.namespace
      end
      name = ns.name( data.elementName )
    else
      name = data.elementName.name
    end

    case data
    when SOAPReference
      attrs[ 'href' ] = '#' << data.refId
      SOAPGenerator.encodeTag( buf, name, attrs, false )
    when SOAPRawString
      SOAPGenerator.encodeTag( buf, name, attrs, false )
      buf << data.to_s
    when XSDString
      SOAPGenerator.encodeTag( buf, name, attrs, false )
      buf << SOAPGenerator.encodeStr( Charset.encodingToXML( data.to_s ))
    when XSDAnyType
      SOAPGenerator.encodeTag( buf, name, attrs, false )
      buf << SOAPGenerator.encodeStr( data.to_s )
    when SOAPStruct
      SOAPGenerator.encodeTag( buf, name, attrs, true )
      data.each do | key, value |
	yield( value, false )
      end
    when SOAPArray
      SOAPGenerator.encodeTag( buf, name, attrs, true )
      data.traverse do | child, *rank |
	unless data.sparse
	  data.position = nil
	else
	  data.position = rank
	end
	yield( child, false )
      end
    else
      raise EncodingStyleError.new( "Unknown object:#{ data } in this encodingStyle." )
    end
  end

  def encodeDataEnd( buf, ns, qualified, data, parent )
    name = nil
    if qualified and data.elementName.namespace
      name = ns.name( data.elementName )
    else
      name = data.elementName.name
    end
    SOAPGenerator.encodeTagEnd( buf, name, true )
  end


  ###
  ## decode interface.
  #
  class SOAPTemporalObject
    attr_accessor :parent
    attr_accessor :position
    attr_accessor :id
    attr_accessor :root

    def initialize
      @parent = nil
      @position = nil
      @id = nil
      @root = nil
    end
  end

  class SOAPUnknown < SOAPTemporalObject
    def initialize( handler, ns, name, type )
      super()
      @handler = handler
      @ns = ns
      @name = name
      @type = type
    end

    def toStruct
      o = SOAPStruct.decode( @ns, @name, @type )
      o.id = @id
      o.root = @root
      o.parent = @parent
      o.position = @position
      @handler.decodeParent( @parent, o )
      o
    end

    def toString
      o = SOAPString.decode( @ns, @name )
      o.id = @id
      o.root = @root
      o.parent = @parent
      o.position = @position
      @handler.decodeParent( @parent, o )
      o
    end

    def toNil
      o = SOAPNil.decode( @ns, @name )
      o.id = @id
      o.root = @root
      o.parent = @parent
      o.position = @position
      @handler.decodeParent( @parent, o )
      o
    end
  end

  def decodeTag( ns, name, attrs, parent )
    # ToDo: check if @textBuf is empty...
    @textBuf = ''
    isNil, type, arrayType, reference, id, root, offset, position =
      decodeAttrs( ns, attrs )
    o = nil
    if isNil
      o = SOAPNil.decode( ns, name )
    elsif reference
      o = SOAPReference.decode( ns, name, reference )
      @referencePool << o
    elsif @decodeComplexTypes && @decodeTopElementCount == 0
      # multi-ref element should be parsed by decodeTagByType.
      @decodeTopElementCount += 1
      o = decodeTagByWSDL( ns, name, type, parent.node )
    elsif arrayType
      type = ns.parse( arrayType )
      o = SOAPArray.decode( ns, name, type )
    else
      o = decodeTagByType( ns, name, type, parent.node )
    end

    if o.is_a?( SOAPArray )
      if offset
	o.offset = decodeArrayPosition( offset )
	o.sparse = true
      else
	o.sparse = false
      end
    end

    o.parent = parent
    o.id = id 
    o.root = root
    o.position = position

    unless o.is_a?( SOAPTemporalObject )
      @idPool << o if o.id
      decodeParent( parent, o )
    end
    o
  end

  def decodeTagEnd( ns, node )
    o = node.node
    if o.is_a?( SOAPUnknown )
      newNode = if /\A\s*\z/ =~ @textBuf
	o.toStruct
      else
	o.toString
      end
      if newNode.id
	@idPool << newNode
      end
      node.replaceNode( newNode )
      o = node.node
    end

    decodeTextBuf( o )
    @textBuf = ''
  end

  def decodeText( ns, text )
    # @textBuf is set at decodeTagEnd.
    @textBuf << text
  end

  def decodeComplexTypes=( complexTypes )
    @decodeComplexTypes = complexTypes
  end

  def decodePrologue
    @referencePool.clear
    @idPool.clear
    @decodeTopElementCount = 0
  end

  def decodeEpilogue
    decodeResolveId
  end

  def decodeParent( parent, node )
    case parent.node
    when SOAPUnknown
      newParent = parent.node.toStruct
      node.parent = newParent
      if newParent.id
	@idPool << newParent
      end
      parent.replaceNode( newParent )
      decodeParent( parent, node )

    when SOAPStruct
      parent.node.add( node.elementName.name, node )
      node.parent = parent.node

    when SOAPArray
      if node.position
	parent.node[ *( decodeArrayPosition( node.position )) ] = node
	parent.node.sparse = true
      else
	parent.node.add( node )
      end
      node.parent = parent.node

    when SOAPBasetype
      raise EncodingStyleError.new( "SOAP base type must not have a child." )

    else
      raise EncodingStyleError.new( "Illegal parent: #{ parent.node }." )
    end
  end

private

  ArrayEncodePostfix = 'Ary'

  def contentTypeName( type )
    type.name ? type.name.sub( /\[,*\]$/, '' ) : ''
  end

  def arrayTypeValue( ns, data )
    contentTypeName( data.type ) << '[' << data.size.join( ',' ) << ']'
  end

  def encodeAttrs( ns, qualified, data, parent )
    return {} if data.is_a?( SOAPReference )
    attrs = {}

    if !parent || parent.encodingStyle != EncodingNamespace
      if !ns.assigned?( EnvelopeNamespace )
	tag = ns.assign( EnvelopeNamespace )
	attrs[ 'xmlns:' << tag ] = EnvelopeNamespace
      end
      if !ns.assigned?( EncodingNamespace )
	tag = ns.assign( EncodingNamespace )
	attrs[ 'xmlns:' << tag ] = EncodingNamespace
      end
      attrs[ ns.name( AttrEncodingStyleName ) ] = EncodingNamespace
      data.encodingStyle = EncodingNamespace
    end

    if data.is_a?( SOAPNil )
      attrs[ ns.name( XSD::AttrNilName ) ] = XSD::NilValue
    end

    if data.is_a?( SOAPNil )
      if !ns.assigned?( XSD::InstanceNamespace )
       	tag = ns.assign( XSD::InstanceNamespace )
	attrs[ 'xmlns:' << tag ] = XSD::InstanceNamespace
      end
      attrs[ ns.name( XSD::AttrNilName ) ] = XSD::NilValue
    elsif @encodeType
      if !ns.assigned?( XSD::InstanceNamespace )
       	tag = ns.assign( XSD::InstanceNamespace )
	attrs[ 'xmlns:' << tag ] = XSD::InstanceNamespace
      end
      if data.type.namespace and !ns.assigned?( data.type.namespace )
	tag = ns.assign( data.type.namespace )
	attrs[ 'xmlns:' << tag ] = data.type.namespace
      end
      if data.is_a?( SOAPArray )
	attrs[ ns.name( AttrArrayTypeName ) ] = ns.name( XSD::QName.new(
	  data.type.namespace, arrayTypeValue( ns, data ))) 
	if data.type.name
	  attrs[ ns.name( XSD::AttrTypeName ) ] = ns.name( ValueArrayName )
	end
      elsif parent && parent.is_a?( SOAPArray ) && XSD::QName.new(
	  parent.type.namespace, parent.baseTypeName ) == data.type
	# No need to add.
      elsif !data.type.name
	# No need to add.
      else
	attrs[ ns.name( XSD::AttrTypeName ) ] = ns.name( data.type )
      end
    end

    if data.id
      attrs[ 'id' ] = data.id
    end
    attrs
  end

  def decodeTagByWSDL( ns, name, typeStr, parentNode )
    if parentNode.is_a?( SOAPBody )
      qname = ns.parse( name )
      type = @decodeComplexTypes[ qname ]
      unless type
	raise EncodingStyleError.new( "Unknown operation '#{ qname }'." )
      end
      SOAPStruct.new( qname )
    else
      parentType = @decodeComplexTypes[ parentNode.type ]
      typeName = parentType.getChildrenType( name )
      if ( klass = TypeMap[ typeName ] )
	klass.decode( ns, name )
      else
	type = @decodeComplexTypes[ typeName ]
	case type.compoundType
	when :TYPE_STRUCT
	  SOAPStruct.new( typeName.dup )
	when :TYPE_ARRAY
	  o = SOAPArray.decode( ns, name, type.getArrayType )
	  o.type = typeName.dup
	  o
	end
      end
    end
  end

  def decodeTagByType( ns, name, typeStr, parentNode )
    type = nil
    if typeStr
      type = ns.parse( typeStr )
    elsif parentNode.is_a?( SOAPArray )
      type = parentNode.type
    else
      # Since it's in dynamic(without any type) encoding process,
      # assumes entity as its type itself.
      #   <SOAP-ENC:Array ...> => type Array in SOAP-ENC.
      #   <Country xmlns="foo"> => type Country in foo.
      type = ns.parse( name )
    end

    if ( klass = TypeMap[ type ] )
      klass.decode( ns, name )
    else
      # Unknown type... Struct or String
      SOAPUnknown.new( self, ns, name, type )
    end
  end

  def decodeTextBuf( node )
    case node
    when XSDHexBinary, XSDBase64Binary
      node.setEncoded( @textBuf )
    when XSDString
      encoded = Charset.encodingFromXML( @textBuf )
      node.set( encoded )
    when SOAPNil
      # Nothing to do.
    when SOAPBasetype
      node.set( @textBuf )
    else
      # Nothing to do...
    end
  end

  def decodeAttrs( ns, attrs )
    isNil = false
    type = nil
    arrayType = nil
    reference = nil
    id = nil
    root = nil
    offset = nil
    position = nil

    attrs.each do | key, value |
      if ( ns.compare( XSD::InstanceNamespace, XSD::NilLiteral, key ))
	# isNil = (( value == 'true' ) || ( value == '1' ))
	if (( value == 'true' ) || ( value == '1' ))
	  isNil = true
	elsif (( value == 'false' ) || ( value == '0' ))
	  isNil = false
	else
	  raise EncodingStyleError.new( "Cannot accept attribute value: #{ value } as the value of xsi:#{ XSD::NilLiteral } (expected 'true', 'false', '1', or '0')." )
	end
      elsif ( ns.compare( XSD::InstanceNamespace, XSD::AttrType, key ))
	type = value
      elsif ( ns.compare( EncodingNamespace, AttrArrayType, key ))
	arrayType = value
      elsif ( key == 'href' )
	reference = value
      elsif ( key == 'id' )
	id = value
      elsif ( ns.compare( EncodingNamespace, AttrRoot, key ))
	if value == '1'
	  root = 1
	elsif value == '0'
	  root = 0
	else
	  raise EncodingStyleError.new( "Illegal root attribute value: #{ value }." )
	end
      elsif ( ns.compare( EncodingNamespace, AttrOffset, key ))
	offset = value
      elsif ( ns.compare( EncodingNamespace, AttrPosition, key ))
	position = value
      end
    end

    return isNil, type, arrayType, reference, id, root, offset, position
  end

  def decodeArrayPosition( position )
    /^\[(.+)\]$/ =~ position
    $1.split( ',' ).collect { |s| s.to_i }
  end

  def decodeResolveId
    count = @referencePool.length	# To avoid infinite loop
    while !@referencePool.empty? && count > 0
      @referencePool = @referencePool.find_all { | ref |
	o = @idPool.find { | item |
	  ( '#' << item.id == ref.refId )
	}
	unless o
	  raise EncodingStyleError.new( "Unresolved reference: #{ ref.refId }." )
	end
	if o.is_a?( SOAPReference )
	  true
	else
	  ref.__setobj__( o )
	  false
	end
      }
      count -= 1
    end
  end
end

SOAPEncodingStyleHandlerDynamic.new


end
