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

  def initialize
    super( EncodingNamespace )
    @referencePool = []
    @idPool = []
    @textBuf = ''
  end


  ###
  ## encode interface.
  #
  def encodeData( buf, ns, qualified, data, parent )
    attrs = {}

  if !data.is_a?( SOAPReference )

    if !parent || parent.encodingStyle != EncodingNamespace
      if !ns.assigned?( EnvelopeNamespace )
	tag = ns.assign( EnvelopeNamespace )
	attrs[ 'xmlns:' << tag ] = EnvelopeNamespace
      end
      if !ns.assigned?( EncodingNamespace )
	tag = ns.assign( EncodingNamespace )
	attrs[ 'xmlns:' << tag ] = EncodingNamespace
      end
      attrs[ ns.name( EnvelopeNamespace, AttrEncodingStyle ) ] =
	EncodingNamespace
      data.encodingStyle = EncodingNamespace
    end

    if !ns.assigned?( XSD::InstanceNamespace )
      tag = ns.assign( XSD::InstanceNamespace )
      attrs[ 'xmlns:' << tag ] = XSD::InstanceNamespace
    end

    if data.typeNamespace and !ns.assigned?( data.typeNamespace )
      tag = ns.assign( data.typeNamespace )
      attrs[ 'xmlns:' << tag ] = data.typeNamespace
    end

    if data.is_a?( SOAPArray )
      attrs[ ns.name( EncodingNamespace, 'arrayType' ) ] =
	ns.name( data.typeNamespace, arrayTypeValue( ns, data ) ) 
      if data.typeName
	attrs[ ns.name( XSD::InstanceNamespace, 'type' ) ] =
	  ns.name( EncodingNamespace, 'Array' )
      end
    elsif parent && parent.is_a?( SOAPArray ) &&
	parent.typeNamespace == data.typeNamespace &&
     	parent.baseTypeName == data.typeName
      # No need to add.
    elsif !data.typeName
      # No need to add.
    elsif data.is_a?( SOAPNil )
      attrs[ ns.name( XSD::InstanceNamespace, XSD::NilLiteral ) ] =
	XSD::NilValue
    else
      attrs[ ns.name( XSD::InstanceNamespace, 'type' ) ] =
	ns.name( data.typeNamespace, data.typeName )
    end

    if data.id
      attrs[ 'id' ] = data.id
    end

  end

    if parent && parent.is_a?( SOAPArray ) && parent.position
      attrs[ ns.name( EncodingNamespace, AttrPosition ) ] =
	'[' << parent.position.join( ',' ) << ']'
    end

    name = nil
    if qualified and data.namespace
      if !ns.assigned?( data.namespace )
	tag = ns.assign( data.namespace )
	attrs[ 'xmlns:' << tag ] = data.namespace
      end
      name = ns.name( data.namespace, data.name )
    else
      name = data.name
    end

    case data
    when SOAPReference
      attrs[ 'href' ] = '#' << data.refId
      SOAPGenerator.encodeTag( buf, name, attrs, false )
    when SOAPBasetype
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
    if qualified and data.namespace
      name = ns.name( data.namespace, data.name )
    else
      name = data.name
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
    def initialize( handler, ns, name, typeNamespace, typeName )
      super()
      @handler = handler
      @ns = ns
      @name = name
      @typeNamespace = typeNamespace
      @typeName = typeName
    end

    def toStruct
      o = SOAPStruct.decode( @ns, @name, @typeNamespace, @typeName )
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

    elsif arrayType
      typeNamespace, typeNameString = ns.parse( arrayType )
      o = SOAPArray.decode( ns, name, typeNamespace, typeNameString )
      if offset
	o.offset = decodeArrayPosition( offset )
	o.sparse = true
      else
	o.sparse = false
      end
      # ToDo: xsi:type should be checked here...

    elsif reference
      o = SOAPReference.decode( ns, name, reference )
      @referencePool << o

    else
      typeNamespace = typeNameString = nil
      if type
	typeNamespace, typeNameString = ns.parse( type )
      elsif parent.node.is_a?( SOAPArray )
	typeNamespace, typeNameString =
	  parent.node.typeNamespace, parent.node.typeName
      else
	# Since it's in dynamic(without any type) encoding process,
	# assumes entity as its type itself.
	#   <SOAP-ENC:Array ...> => type Array in SOAP-ENC.
	#   <Country xmlns="foo"> => type Country in foo.
	typeNamespace, typeNameString = ns.parse( name )
      end

      if typeNamespace == XSD::Namespace
	o = decodeTagAsXSD( ns, typeNameString, name )
	unless o
      	  # Not supported...
	  raise EncodingStyleError.new( "Type xsd:#{ typeNameString } have not supported." )
	end

      elsif typeNamespace == EncodingNamespace
	o = decodeTagAsSOAPENC( ns, typeNameString, name )
	unless o
	  # Not supported...
	  raise EncodingStyleError.new( "Type SOAP-ENC:#{ typeNameString } have not supported." )
	end

      else
	# Unknown type... Struct or String
	o = SOAPUnknown.new( self, ns, name, typeNamespace, typeNameString )

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

  def decodePrologue
    @referencePool.clear
    @idPool.clear
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

    when SOAPReference
      raise EncodingStyleError.new( "Reference node must not have a child." )

    when SOAPStruct
      parent.node.add( node.name, node )
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
      # SOAPUnknown does not have parent.
      # raise EncodingStyleError.new( "Illegal parent: #{ parent }." )
    end
  end

private

  ArrayEncodePostfix = 'Ary'

  def contentTypeName( data )
    data.typeName ? data.typeName.sub( /\[,*\]$/, '' ) : ''
  end

  def arrayTypeValue( ns, data )
    contentTypeName( data ) << '[' << data.size.join( ',' ) << ']'
  end

  XSDBaseTypeMap = {
    XSD::DecimalLiteral => SOAPDecimal,
    XSD::IntegerLiteral => SOAPInteger,
    XSD::LongLiteral => SOAPLong,
    XSD::IntLiteral => SOAPInt,
    XSD::FloatLiteral => SOAPFloat,
    XSD::DoubleLiteral => SOAPDouble,
    XSD::BooleanLiteral => SOAPBoolean,
    XSD::StringLiteral => SOAPString,
    XSD::DateTimeLiteral => SOAPDateTime,
    XSD::DateLiteral => SOAPDate,
    XSD::TimeLiteral => SOAPTime,
    XSD::HexBinaryLiteral => SOAPHexBinary,
    XSD::Base64BinaryLiteral => SOAPBase64,
  }

  SOAPBaseTypeMap = {
    SOAP::Base64Literal => SOAPBase64,
  }

  def decodeTagAsXSD( ns, typeNameString, name )
    if typeNameString == XSD::AnyTypeLiteral
      SOAPUnknown.new( self, ns, name, XSD::Namespace, typeNameString )
    elsif XSDBaseTypeMap.has_key?( typeNameString )
      XSDBaseTypeMap[ typeNameString ].decode( ns, name )
    else
      nil
    end
  end

  def decodeTagAsSOAPENC( ns, typeNameString, name )
    if XSDBaseTypeMap.has_key?( typeNameString )
      XSDBaseTypeMap[ typeNameString ].decode( ns, name )
    elsif SOAPBaseTypeMap.has_key?( typeNameString )
      SOAPBaseTypeMap[ typeNameString ].decode( ns, name )
    else
      nil
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
      node.set( @textBuf ) unless @textBuf.empty?
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
