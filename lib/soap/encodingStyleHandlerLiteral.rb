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

require 'soap/encoding'
require 'soap/nqxmlDocument'


module SOAP


class SOAPEncodingStyleHandlerLiteral < EncodingStyleHandler

  LiteralEncodingNamespace = 'http://xml.apache.org/xml-soap/literalxml'

  def initialize
    super( LiteralEncodingNamespace )
    @referencePool = []
    @idPool = []
    @textBuf = ''
  end


  ###
  ## encode interface.
  #
  def encodeData( ns, data, name, parent )
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

  class SOAPLiteral < SOAPTemporalObject
    attr_accessor :data
    attr_reader :name

    def initialize( name )
      super()
      @name = name
      @data = String.new( '' )
    end
  end

  def decodeTag( ns, name, attrs, parent )
    # ToDo: check if @textBuf is empty...
    @textBuf = ''
    o = SOAPLiteral.new( name )
    o.data << "<#{ o.name }"
    attrs.each do | key, value |
      o.data << " #{ key }=\"#{ value }\""
    end
    o.data << ">"
    o.parent = parent
    o
  end

  def decodeTagEnd( ns, node )
    o = node.node
    if o.is_a?( SOAPLiteral )
      decodeTextBuf( o )
      o.data << "</#{ o.name }>"
    end
    o.parent.node.data << o.data if o.parent.node
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

private

  def decodeTextBuf( node )
    node.data << @textBuf
  end
end

SOAPEncodingStyleHandlerLiteral.new


end
