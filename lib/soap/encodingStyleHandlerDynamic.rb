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

  def initialize( charset = nil )
    super( charset )
    @referencePool = []
    @idPool = []
    @textBuf = ''
    @firstTopElement = true
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
      assignNamespace( attrs, ns, data.elementName.namespace )
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
      buf << SOAPGenerator.encodeStr( @charset ?
	Charset.encodingToXML( data.to_s, @charset ) : data.to_s )
    when XSDAnySimpleType
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
    attr_reader :type
    attr_accessor :typeDef
    attr_reader :extraAttrs

    def initialize( handler, elementName, type, extraAttrs )
      super()
      @handler = handler
      @elementName = elementName
      @type = type
      @extraAttrs = extraAttrs
      @typeDef = nil
    end

    def toStruct
      o = SOAPStruct.decode( @elementName, @type )
      o.id = @id
      o.root = @root
      o.parent = @parent
      o.position = @position
      o.extraAttrs.update( @extraAttrs )
      @handler.decodeParent( @parent, o )
      o
    end

    def toString
      o = SOAPString.decode( @elementName )
      o.id = @id
      o.root = @root
      o.parent = @parent
      o.position = @position
      o.extraAttrs.update( @extraAttrs )
      @handler.decodeParent( @parent, o )
      o
    end

    def toNil
      o = SOAPNil.decode( @elementName )
      o.id = @id
      o.root = @root
      o.parent = @parent
      o.position = @position
      o.extraAttrs.update( @extraAttrs )
      @handler.decodeParent( @parent, o )
      o
    end
  end

  def decodeTag( ns, elementName, attrs, parent )
    # ToDo: check if @textBuf is empty...
    @textBuf = ''
    isNil, type, arrayType, root, offset, position, href, id, extraAttrs =
      decodeAttrs( ns, attrs )
    o = nil
    if isNil
      o = SOAPNil.decode( elementName )
    elsif href
      o = SOAPReference.decode( elementName, href )
      @referencePool << o
    elsif @decodeComplexTypes &&
	( parent.node.class != SOAPBody || @firstTopElement )
      # multi-ref element should be parsed by decodeTagByType.
      @firstTopElement = false
      o = decodeTagByWSDL( ns, elementName, type, parent.node, arrayType, extraAttrs )
    else
      o = decodeTagByType( ns, elementName, type, parent.node, arrayType, extraAttrs )
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
    if o.is_a?( SOAPCompoundtype )
      o.typeDef = nil
    end

    decodeTextBuf( o )
    @textBuf = ''
  end

  def decodeText( ns, text )
    # @textBuf is set at decodeTagEnd.
    @textBuf << text
  end

  def decodePrologue
    @referencePool.clear
    @idPool.clear
    @firstTopElement = true
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

  def contentRankSize( typeName )
    typeName.scan( /\[[\d,]*\]$/ )[ 0 ]
  end

  def contentTypeName( typeName )
    typeName.sub( /\[,*\]$/, '' )
  end

  def arrayTypeValue( ns, data )
    XSD::QName.new( data.arrayType.namespace,
      contentTypeName( data.arrayType.name ) <<
      '[' << data.size.join( ',' ) << ']' )
  end

  def encodeAttrs( ns, qualified, data, parent )
    return {} if data.is_a?( SOAPReference )
    attrs = {}

    if !parent || parent.encodingStyle != EncodingNamespace
      assignNamespace( attrs, ns, EnvelopeNamespace )
      assignNamespace( attrs, ns, EncodingNamespace )
      attrs[ ns.name( AttrEncodingStyleName ) ] = EncodingNamespace
      data.encodingStyle = EncodingNamespace
    end

    if data.is_a?( SOAPNil )
      assignNamespace( attrs, ns, XSD::InstanceNamespace )
      attrs[ ns.name( XSD::AttrNilName ) ] = XSD::NilValue
    elsif @generateEncodeType
      assignNamespace( attrs, ns, XSD::InstanceNamespace )
      if data.type.namespace
        assignNamespace( attrs, ns, data.type.namespace )
      end
      if data.is_a?( SOAPArray )
	if data.arrayType.namespace
          assignNamespace( attrs, ns, data.arrayType.namespace )
   	end
	attrs[ ns.name( AttrArrayTypeName ) ] =
	  ns.name( arrayTypeValue( ns, data ))
	if data.type.name
	  attrs[ ns.name( XSD::AttrTypeName ) ] = ns.name( data.type )
	end
      elsif parent && parent.is_a?( SOAPArray ) &&
	  ( parent.arrayType == data.type )
	# No need to add.
      elsif !data.type.namespace
	# No need to add.
      else
	attrs[ ns.name( XSD::AttrTypeName ) ] = ns.name( data.type )
      end
      data.extraAttrs.each do | key, value |
        assignNamespace( attrs, ns, key.namespace )
        attrs[ ns.name( key ) ] = value       # ns.name( value ) ?
      end
    end

    if data.id
      attrs[ 'id' ] = data.id
    end
    attrs
  end

  def assignNamespace( attrs, ns, namespace )
    unless ns.assigned?( namespace )
      tag = ns.assign( namespace )
      attrs[ 'xmlns:' << tag ] = namespace
    end
  end

  def decodeTagByWSDL( ns, elementName, typeStr, parent, arrayTypeStr, extraAttrs )
    if parent.class == SOAPBody
      type = @decodeComplexTypes[ elementName ]
      unless type
	raise EncodingStyleError.new( "Unknown operation '#{ elementName }'." )
      end
      o = SOAPStruct.new( elementName )
      o.typeDef = type
      return o
    end

    if parent.type == XSD::AnyTypeName
      return decodeTagByType( ns, elementName, typeStr, parent, arrayTypeStr, extraAttrs )
    end

    # parent.typeDef is nil is the parent is SOAPUnknown.  SOAPUnknown is
    # generated by decodeTagByType when its type is anyType.
    parentType = parent.typeDef || @decodeComplexTypes[ parent.type ]
    unless parentType
      raise EncodingStyleError.new( "Unknown type '#{ parent.type }'." )
    end
    typeName = parentType.getChildType( elementName.name )
    if typeName
      if ( klass = TypeMap[ typeName ] )
	return klass.decode( elementName )
      elsif typeName == XSD::AnyTypeName
	return decodeTagByType( ns, elementName, typeStr, parent, arrayTypeStr, extraAttrs )
      end
    end

    type = if typeName
	@decodeComplexTypes[ typeName ]
      else
	parentType.getChildLocalTypeDef( elementName.name )
      end
    unless type
      raise EncodingStyleError.new( "Unknown type '#{ typeName }'." )
    end

    case type.compoundType
    when :TYPE_STRUCT
      o = SOAPStruct.decode( elementName, typeName )
      o.typeDef = type
      return o
    when :TYPE_ARRAY
      expectedArrayType = type.getArrayType
      actualArrayType = if arrayTypeStr
	  XSD::QName.new( expectedArrayType.namespace,
	    contentTypeName( expectedArrayType.name ) <<
	    contentRankSize( arrayTypeStr ))
	else
       	  expectedArrayType
	end
      o = SOAPArray.decode( elementName, typeName, actualArrayType )
      o.typeDef = type
      return o
    end
    return nil
  end

  def decodeTagByType( ns, elementName, typeStr, parent, arrayTypeStr, extraAttrs )
    if arrayTypeStr
      type = typeStr ? ns.parse( typeStr ) : ValueArrayName
      node = SOAPArray.decode( elementName, type, ns.parse( arrayTypeStr ))
      node.extraAttrs.update( extraAttrs )
      return node
    end

    type = nil
    if typeStr
      type = ns.parse( typeStr )
    elsif parent.is_a?( SOAPArray )
      type = parent.arrayType
    else
      # Since it's in dynamic(without any type) encoding process,
      # assumes entity as its type itself.
      #   <SOAP-ENC:Array ...> => type Array in SOAP-ENC.
      #   <Country xmlns="foo"> => type Country in foo.
      type = elementName
    end

    if ( klass = TypeMap[ type ] )
      klass.decode( elementName )
    else
      # Unknown type... Struct or String
      SOAPUnknown.new( self, elementName, type, extraAttrs )
    end
  end

  def decodeTextBuf( node )
    case node
    when XSDHexBinary, XSDBase64Binary
      node.setEncoded( @textBuf )
    when XSDString
      if @charset
	node.set( Charset.encodingFromXML( @textBuf, @charset ))
      else
	node.set( @textBuf )
      end
    when SOAPNil
      # Nothing to do.
    when SOAPBasetype
      node.set( @textBuf )
    else
      # Nothing to do...
    end
  end

  NilLiteralMap = {
    'true' => true,
    '1' => true,
    'false' => false,
    '0' => false
  }
  RootLiteralMap = {
    '1' => 1,
    '0' => 0
  }
  def decodeAttrs( ns, attrs )
    isNil = false
    type = nil
    arrayType = nil
    root = nil
    offset = nil
    position = nil
    href = nil
    id = nil
    extraAttrs = {}

    attrs.each do | key, value |
      qname = ns.parse( key )
      case qname.namespace
      when XSD::InstanceNamespace
        case qname.name
        when XSD::NilLiteral
          isNil = NilLiteralMap[ value ] or
            raise EncodingStyleError.new( "Cannot accept attribute value: #{ value } as the value of xsi:#{ XSD::NilLiteral } (expected 'true', 'false', '1', or '0')." )
          next
        when XSD::AttrType
          type = value
          next
        end
      when EncodingNamespace
        case qname.name
        when AttrArrayType
          arrayType = value
          next
        when AttrRoot
          root = RootLiteralMap[ value ] or
            raise EncodingStyleError.new( "Illegal root attribute value: #{ value }." )
          next
        when AttrOffset
          offset = value
          next
        when AttrPosition
          position = value
          next
        end
      end
      if key == 'href'
        href = value
        next
      elsif key == 'id'
        id = value
        next
      end
      extraAttrs[ qname ] = value
    end

    return isNil, type, arrayType, root, offset, position, href, id, extraAttrs
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
