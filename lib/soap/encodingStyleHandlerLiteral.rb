=begin
SOAP4R - XML Literal EncodingStyle handler library
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


class EncodingStyleHandlerLiteral < EncodingStyleHandler
  Namespace = SOAP::LiteralNamespace
  addHandler

  def initialize( charset = nil )
    super( charset )
    @textBuf = ''
  end


  ###
  ## encode interface.
  #
  def encodeData( buf, ns, qualified, data, parent, indent = '' )
    attrs = {}
    name = if qualified and data.elementName.namespace
        SOAPGenerator.assignNamespace( attrs, ns, data.elementName.namespace )
        ns.name( data.elementName )
      else
        data.elementName.name
      end

    case data
    when SOAPRawString
      SOAPGenerator.encodeTag( buf, name, attrs, indent )
      buf << data.to_s
    when XSDString
      SOAPGenerator.encodeTag( buf, name, attrs, indent )
      buf << SOAPGenerator.encodeStr( @charset ?
	Charset.encodingToXML( data.to_s, @charset ) : data.to_s )
    when XSDAnySimpleType
      SOAPGenerator.encodeTag( buf, name, attrs, indent )
      buf << SOAPGenerator.encodeStr( data.to_s )
    when SOAPStruct
      SOAPGenerator.encodeTag( buf, name, attrs, indent )
      data.each do | key, value |
	value.elementName.namespace = data.elementName.namespace if !value.elementName.namespace
        yield( value, true )
      end
    when SOAPArray
      SOAPGenerator.encodeTag( buf, name, attrs, indent )
      data.traverse do | child, *rank |
	data.position = nil
        yield( child, true )
      end
    when SOAPElement
      SOAPGenerator.encodeTag( buf, name, attrs.update( data.extraAttrs ),
        indent )
      buf << data.text if data.text
      data.each do | key, value |
	value.elementName.namespace = data.elementName.namespace if !value.elementName.namespace
        yield( value, data.qualified )
      end
    else
      raise EncodingStyleError.new( "Unknown object:#{ data } in this encodingStyle." )
    end
  end

  def encodeDataEnd( buf, ns, qualified, data, parent )
    name = if qualified and data.elementName.namespace
        ns.name( data.elementName )
      else
        data.elementName.name
      end
    SOAPGenerator.encodeTagEnd( buf, name, indent )
  end


  ###
  ## decode interface.
  #
  class SOAPTemporalObject
    attr_accessor :parent

    def initialize
      @parent = nil
    end
  end

  class SOAPUnknown < SOAPTemporalObject
    def initialize( handler, elementName )
      super()
      @handler = handler
      @elementName = elementName
    end

    def toStruct
      o = SOAPStruct.decode( @elementName, XSD::AnyTypeName )
      o.parent = @parent
      @handler.decodeParent( @parent, o )
      o
    end

    def toString
      o = SOAPString.decode( @elementName )
      o.parent = @parent
      @handler.decodeParent( @parent, o )
      o
    end

    def toNil
      o = SOAPNil.decode( @elementName )
      o.parent = @parent
      @handler.decodeParent( @parent, o )
      o
    end
  end

  def decodeTag( ns, elementName, attrs, parent )
    # ToDo: check if @textBuf is empty...
    @textBuf = ''
    o = SOAPUnknown.new( self, elementName )
    o.parent = parent
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
  end

  def decodeEpilogue
  end

  def decodeParent( parent, node )
    case parent.node
    when SOAPUnknown
      newParent = parent.node.toStruct
      node.parent = newParent
      parent.replaceNode( newParent )
      decodeParent( parent, node )

    when SOAPStruct
      parent.node.add( node.name, node )

    when SOAPArray
      if node.position
	parent.node[ *( decodeArrayPosition( node.position )) ] = node
	parent.node.sparse = true
      else
	parent.node.add( node )
      end

    when SOAPBasetype
      raise EncodingStyleError.new( "SOAP base type must not have a child." )

    else
      # SOAPUnknown does not have parent.
      # raise EncodingStyleError.new( "Illegal parent: #{ parent }." )
    end
  end

private

  def decodeTextBuf( node )
    if node.is_a?( XSDString )
      if @charset
	node.set( Charset.encodingFromXML( @textBuf, @charset ))
      else
	node.set( @textBuf )
      end
    else
      # Nothing to do...
    end
  end
end

EncodingStyleHandlerLiteral.new


end
