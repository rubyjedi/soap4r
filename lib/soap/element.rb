=begin
SOAP4R - SOAP elements library
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


###
## SOAP elements
#
class SOAPFault < SOAPStruct
  include SOAPCompoundtype

public

  attr_accessor :faultcode
  attr_accessor :faultstring
  attr_accessor :faultactor
  attr_accessor :detail

  def initialize( faultCode = nil, faultString = nil, faultActor = nil, detail = nil )
    super( self.type.to_s )
    @namespace = EnvelopeNamespace
    @name = 'Fault'
    @encodingStyle = EncodingNamespace
    @faultcode = faultCode
    @faultstring = faultString
    @faultactor = faultActor
    @detail = detail
    @faultcode.name = 'faultcode' if @faultcode
    @faultstring.name = 'faultstring' if @faultstring
    @faultactor.name = 'faultactor' if @faultactor
    @detail.name = 'detail' if @detail
  end

  def encode( buf, ns )
    attrs = {}
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
    name = ns.name( @namespace, @name )
    SOAPGenerator.encodeTag( buf, name, attrs, true )
    yield( @faultcode, false )
    yield( @faultstring, false)
    yield( @faultactor, false )
    yield( @detail, false ) if @detail
    SOAPGenerator.encodeTagEnd( buf, name, true )
  end

  # Module function

public

  def self.decode( ns, elem )
    faultCode = nil
    faultString = nil
    faultActor = nil
    detail = nil
    options = []
    elem.childNodes.each do | child |
      next if ( isEmptyText( child ))
      childNS = ns.clone
      parseNS( childNS, child )

      if child.nodeName == 'faultcode'
	raise FormatDecodeError.new( 'Duplicated faultcode in Fault' ) if faultCode
	faultCode = SOAPString.decode( childNS, child )

      elsif child.nodeName == 'faultstring'
	raise FormatDecodeError.new( 'Duplicated faultstring in Fault' ) if faultString
	faultString = SOAPString.decode( childNS, child )

      elsif child.nodeName == 'faultactor'
	raise FormatDecodeError.new( 'Duplicated faultactor in Fault' ) if faultActor
	faultActor = SOAPString.decode( childNS, child )

      elsif child.nodeName == 'detail'
	raise FormatDecodeError.new( 'Duplicated detail in Fault' ) if detail
	detail = decodeChild( childNS, child )

      else
	options.push( decodeChild( childNS, child ))
      end
    end

    SOAPFault.new( faultCode, faultString, faultActor, detail, options )
  end
end


class SOAPBody < SOAPStruct

public

  def initialize( data = nil, isFault = false )
    super( self.type.to_s )
    @namespace = EnvelopeNamespace
    @name = 'Body'
    @encodingStyle = nil
    @data = []
    @data << data if data
    @isFault = isFault
  end

  def encode( buf, ns )
    name = ns.name( @namespace, @name )
    SOAPGenerator.encodeTag( buf, name, nil, true )
    if @isFault
      yield( @data, true )
    else
      @data.each do | data |
	yield( data, true )
      end
    end
    SOAPGenerator.encodeTagEnd( buf, name, true )
  end

  def rootNode
    @data.each do | node |
      if node.root == 1
	return node
      end
    end
    # No specified root...
    @data.each do | node |
      if node.root != 0
	return node
      end
    end

    raise FormatDecodeError.new( 'No root element.' )
  end
end


class SOAPHeaderItem < NSDBase
  include SOAPCompoundtype

public

  attr_reader :namespace
  attr_reader :name
  attr_accessor :content
  attr_accessor :mustUnderstand
  attr_accessor :encodingStyle

  def initialize( namespace, name, content, mustUnderstand = false, encodingStyle = nil )
    super( self.type.to_s )
    @namespace = namespace
    @name = name
    @encodingStyle = nil
    @content = content
    @mustUnderstand = mustUnderstand
    @encodingStyle = encodingStyle
  end

  def encode( buf, ns )
    attrs = {}
    attrs[ ns.name( EnvelopeNamespace, AttrMustUnderstand ) ] = ( @mustUnderstand ? '1' : '0' )
    attrs[ ns.name( EnvelopeNamespace, AttrEncodingStyle ) ] = @encodingStyle if @encodingStyle

    name = ns.name( @namespace, @name )
    SOAPGenerator.encodeTag( buf, name, attrs, true )
    yield( @content, false )
    SOAPGenerator.encodeTagEnd( buf, name, true )
  end

  # Module function

public

  def self.decode( ns, elem )
    mustUnderstand = nil
    encodingStyle = nil
    elem.attributes.each do | attr |
      name = attr.nodeName
      if ( ns.compare( EnvelopeNamespace, AttrMustUnderstand, name ))
	raise FormatDecodeError.new( 'Duplicated mustUnderstand in HeaderItem' ) if mustUnderstand
	mustUnderstand = attr.nodeValue
      elsif ( ns.compare( EnvelopeNamespace, AttrEncodingStyle, name ))
	raise FormatDecodeError.new( 'Duplicated encodingStyle in HeaderItem' ) if encodingStyle
    	encodingStyle = attr.nodeValue
      else
    	# raise FormatDecodeError.new( 'Unknown attribute: ' << name )
      end
    end
    elemNamespace, elemName = ns.parse( elem.nodeName )

    # Convert NodeList to simple Array.
    childArray = []
    elem.childNodes.each do | child |
      childArray.push( child )
    end

    SOAPHeaderItem.new( elemNamespace, elemName, childArray, mustUnderstand, encodingStyle )
  end
end


class SOAPHeader < SOAPArray
  def initialize()
    super( self.type.to_s, 1 )	# rank == 1
    @namespace = EnvelopeNamespace
    @name = 'Header'
    @encodingStyle = nil
  end

  def encode( buf, ns )
    name = ns.name( @namespace, @name )
    SOAPGenerator.encodeTag( buf, name, nil, true )
    @data.each do | data |
      yield( data, true )
    end
    SOAPGenerator.encodeTagEnd( buf, name, true )
  end

  def length
    @data.length
  end
end


class SOAPEnvelope < NSDBase
  include SOAPCompoundtype

  attr_accessor :header
  attr_accessor :body
  attr_reader :refPool
  attr_reader :idPool

  def initialize( initHeader = nil, initBody = nil )
    super( self.type.to_s )
    @namespace = EnvelopeNamespace
    @name = 'Envelope'
    @encodingStyle = nil
    @header = initHeader
    @body = initBody
    @refPool = []
    @idPool = []
  end

  def encode( buf, ns )
    attrs = {}
    tag = ns.assign( EnvelopeNamespace, SOAPNamespaceTag )
    attrs[ 'xmlns:' << tag ] = EnvelopeNamespace
    tag = ns.assign( XSD::Namespace, XSDNamespaceTag )
    attrs[ 'xmlns:' << tag ] = XSD::Namespace
    tag = ns.assign( XSD::InstanceNamespace, XSINamespaceTag )
    attrs[ 'xmlns:' << tag ] = XSD::InstanceNamespace

    name = ns.name( @namespace, @name )
    SOAPGenerator.encodeTag( buf, name, attrs, true )

    yield( @header, true ) if @header and @header.length > 0
    yield( @body, true )

    SOAPGenerator.encodeTagEnd( buf, name, true )
  end
end


end
