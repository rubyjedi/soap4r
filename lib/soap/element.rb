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
require 'soap/qname'


module SOAP


###
## SOAP elements
#
module SOAPEnvelopeElement; end

class SOAPFault < SOAPStruct
  include SOAPEnvelopeElement
  include SOAPCompoundtype
  Name = XSD::QName.new( EnvelopeNamespace, 'Fault' )

public

  def faultcode
    self[ 'faultcode' ]
  end

  def faultstring
    self[ 'faultstring' ]
  end

  def faultactor
    self[ 'faultactor' ]
  end

  def detail
    self[ 'detail' ]
  end

  def faultcode=( rhs )
    self[ 'faultcode' ] = rhs
  end

  def faultstring=( rhs )
    self[ 'faultstring' ] = rhs
  end

  def faultactor=( rhs )
    self[ 'faultactor' ] = rhs
  end

  def detail=( rhs )
    self[ 'detail' ] = rhs
  end

  def initialize( faultCode = nil, faultString = nil, faultActor = nil, detail = nil )
    super( EleFaultName )
    @elementName = Name
    @encodingStyle = EncodingNamespace

    if faultCode
      self.faultcode = faultCode
      self.faultstring = faultString
      self.faultactor = faultActor
      self.detail = detail
      self.faultcode.elementName.name = 'faultcode' if self.faultcode
      self.faultstring.elementName.name = 'faultstring' if self.faultstring
      self.faultactor.elementName.name = 'faultactor' if self.faultactor
      self.detail.elementName.name = 'detail' if self.detail
    end
  end

  def encode( buf, ns, attrs = {}, indent = '' )
    SOAPGenerator.assignNamespace( attrs, ns, EnvelopeNamespace )
    SOAPGenerator.assignNamespace( attrs, ns, EncodingNamespace )
    attrs[ ns.name( AttrEncodingStyleName ) ] = EncodingNamespace
    name = ns.name( @elementName )
    SOAPGenerator.encodeTag( buf, name, attrs, indent )
    yield( self.faultcode, false )
    yield( self.faultstring, false)
    yield( self.faultactor, false )
    yield( self.detail, false ) if self.detail
    SOAPGenerator.encodeTagEnd( buf, name, indent, true )
  end
end


class SOAPBody < SOAPStruct
  include SOAPEnvelopeElement
  Name = XSD::QName.new( EnvelopeNamespace, 'Body' )

public

  def initialize( data = nil, isFault = false )
    super( nil )
    @elementName = Name
    @encodingStyle = nil
    @data = []
    @data << data if data
    @isFault = isFault
  end

  def encode( buf, ns, attrs = {}, indent = '' )
    name = ns.name( @elementName )
    SOAPGenerator.encodeTag( buf, name, attrs, indent )
    if @isFault
      yield( @data, true )
    else
      @data.each do | data |
	yield( data, true )
      end
    end
    SOAPGenerator.encodeTagEnd( buf, name, indent, true )
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

    raise SOAPParser::FormatDecodeError.new( 'No root element.' )
  end
end


class SOAPHeaderItem < NSDBase
  include SOAPEnvelopeElement
  include SOAPCompoundtype

public

  attr_accessor :content
  attr_accessor :mustUnderstand
  attr_accessor :encodingStyle

  def initialize( content, mustUnderstand = true, encodingStyle = nil )
    super( nil )
    @content = content
    @mustUnderstand = mustUnderstand
    @encodingStyle = encodingStyle || LiteralNamespace
  end

  def encode( buf, ns, attrs = {}, indent = '' )
    attrs.each do | key, value |
      @content.attr[ key ] = value
    end
    @content.attr[ ns.name( EnvelopeNamespace, AttrMustUnderstand ) ] =
      ( @mustUnderstand ? '1' : '0' )
    if @encodingStyle
      @content.attr[ ns.name( EnvelopeNamespace, AttrEncodingStyle ) ] =
      	@encodingStyle
    end
    @content.encodingStyle = @encodingStyle if !@content.encodingStyle
    yield( @content, true )
  end
end


class SOAPHeader < SOAPArray
  include SOAPEnvelopeElement
  Name = XSD::QName.new( EnvelopeNamespace, 'Header' )

  def initialize()
    super( nil, 1 )	# rank == 1
    @elementName = Name
    @encodingStyle = nil
  end

  def encode( buf, ns, attrs = {}, indent = '' )
    name = ns.name( @elementName )
    SOAPGenerator.encodeTag( buf, name, attrs, indent )
    @data.each do | data |
      yield( data, true )
    end
    SOAPGenerator.encodeTagEnd( buf, name, indent, true )
  end

  def length
    @data.length
  end
end


class SOAPEnvelope < NSDBase
  include SOAPEnvelopeElement
  include SOAPCompoundtype
  Name = XSD::QName.new( EnvelopeNamespace, 'Envelope' )

  attr_accessor :header
  attr_accessor :body
  attr_reader :refPool
  attr_reader :idPool

  def initialize( initHeader = nil, initBody = nil )
    super( nil )
    @elementName = Name
    @encodingStyle = nil
    @header = initHeader
    @body = initBody
    @refPool = []
    @idPool = []
  end

  def encode( buf, ns, attrs = {}, indent = '' )
    SOAPGenerator.assignNamespace( attrs, ns, EnvelopeNamespace,
      SOAPNamespaceTag )
    name = ns.name( @elementName )
    SOAPGenerator.encodeTag( buf, name, attrs, indent )

    yield( @header, true ) if @header and @header.length > 0
    yield( @body, true )

    SOAPGenerator.encodeTagEnd( buf, name, indent, true )
  end
end


end
