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

  attr_accessor :faultCode
  attr_accessor :faultString
  attr_accessor :faultActor
  attr_accessor :detail
  attr_reader :options

  def initialize( faultCode = nil, faultString = nil, faultActor = nil, detail = nil, options = [] )
    super( self.type.to_s )
    @faultCode = faultCode
    @faultString = faultString
    @faultActor = faultActor
    @detail = detail
    @options = options
  end

  def encode( ns )
    faultElems = [ @faultCode.encode( ns, 'faultcode' ),
      @faultString.encode( ns, 'faultstring' ),
      @faultActor.encode( ns, 'faultactor' ) ]
    faultElems.push( @detail.encode( ns, 'detail' )) if @detail
    @options.each do | opt |
      paramElem.push( opt.encode( ns ))
    end

    # Element.new( ns.name( EnvelopeNamespace, 'Fault' ), nil, faultElems )
    Node.initializeWithChildren( ns.name( EnvelopeNamespace, 'Fault' ), nil, faultElems )
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
    @data = []
    @data << data if data
    @isFault = isFault
  end

  def encode( ns )
    attrs = []
    contents = nil
    if @isFault
      contents = @data.encode( ns )
    else
      attrs.push( Attr.new( ns.name( EnvelopeNamespace, AttrEncodingStyle ), EncodingNamespace ))
      contents = @data.collect { | item | item.encode( ns ) }
    end

    # Element.new( ns.name( EnvelopeNamespace, 'Body' ), attrs, contents )
    Node.initializeWithChildren( ns.name( EnvelopeNamespace, 'Body' ), attrs, contents )
  end

  def rootNode
    @data.each do | node |
      if node.root
	return node
      end
    end
    @data[0]
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
    @content = content
    @mustUnderstand = mustUnderstand
    @encodingStyle = encodingStyle
  end

  def encode( ns )
    return nil if @name.empty?
    attrs = []
    attrs.push( Attr.new( ns.name( EnvelopeNamespace, AttrMustUnderstand ), ( @mustUnderstand ? '1' : '0' )))
    attrs.push( Attr.new( ns.name( EnvelopeNamespace, AttrEncodingStyle ), @encodingStyle )) if @encodingStyle

    # Element.new( ns.name( @namespace, @name ), attrs, @content )
    Node.initializeWithChildren( ns.name( @namespace, @name ), attrs, @content )
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
    super( self.type.to_s )
  end

  def encode( ns )
    children = @data.collect { | child |
      child.encode( ns.clone )
    }

    # Element.new( ns.name( EnvelopeNamespace, 'Header' ), nil, children )
    Node.initializeWithChildren( ns.name( EnvelopeNamespace, 'Header' ), nil, children )
  end

  def length
    @data[ 0 ].length
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
    @header = initHeader
    @body = initBody
    @refPool = []
    @idPool = []
  end

  def encode( ns )
    # Namespace preloading.
    attrs = []
    ns.eachNamespace do | namespace, tag |
      if ( tag == '' )
	attrs << Attr.new( 'xmlns' , namespace )
      else
	attrs << Attr.new( 'xmlns:' << tag, namespace )
      end
    end

    contents = []
    contents.push( @header.encode( ns )) if @header and @header.length > 0
    contents.push( @body.encode( ns ))

    # Element.new( ns.name( EnvelopeNamespace, 'Envelope' ), attrs, contents )
    Node.initializeWithChildren( ns.name( EnvelopeNamespace, 'Envelope' ), attrs, contents )
  end
end


end
