=begin
SOAP4R - SOAP XMLScan parser library.
Copyright (C) 2002, 2003 NAKAMURA Hiroshi.

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

require 'soap/parser'
require 'xmlscan/scanner'


module SOAP


class SOAPXMLScanner < SOAPParser
  def initialize( *vars )
    super( *vars )
  end

  def prologue
  end

  def doParse( stringOrReadable )
    @scanner = XMLScan::XMLScanner.new( Visitor.new( self ))
    @scanner.kcode = Charset.getCharsetStr( charset )
    @scanner.parse( stringOrReadable )
  end

  def setScannerKCode( charset )
    @scanner.kcode = Charset.getCharsetStr( charset )
    setXMLDeclEncoding( charset )
  end

  def epilogue
  end

  class Visitor; include XMLScan::Visitor
    ENTITY_REF_MAP = {
      'lt' => '<',
      'gt' => '>',
      'amp' => '&',
      'quot' => '"',
      'apos' => '\''
    }

    def initialize( dest )
      @dest = dest
      @attrs = {}
      @currentAttr = nil
    end

    def parse_error( msg )
      raise ParseError.new( msg )
    end

    def wellformed_error( msg )
      raise NotWellFormedError.new( msg )
    end

    def valid_error( msg )
      raise NotValidError.new( msg )
    end

    def warning( msg )
      p msg if $DEBUG
    end

    def on_xmldecl
    end

    def on_xmldecl_version( str )
      # 1.0 expected.
    end

    def on_xmldecl_encoding( str )
      @dest.setScannerKCode( str )
    end

    def on_xmldecl_standalone( str )
    end

    def on_xmldecl_other( name, value )
    end

    def on_xmldecl_end
    end

    def on_doctype( root, pubid, sysid )
      raise FormatDecodeError.new( "SOAP does not allow doctype." )
    end

    def on_prolog_space( str )
    end

    def on_comment( str )
      raise FormatDecodeError.new( "SOAP does not allow comment." )
    end

    def on_pi( target, pi )
      raise FormatDecodeError.new( "SOAP does not allow PI." )
    end

    def on_chardata( str )
      @dest.characters( str )
    end

    def on_cdata( str )
      raise FormatDecodeError.new( "SOAP does not allow CDATA." )
    end

    def on_etag( name )
      @dest.endElement( name )
    end

    def on_entityref( ref )
      @dest.characters( ENTITY_REF_MAP[ ref ] )
    end

    def on_charref( code )
      @dest.characters( [ code ].pack( 'U' ))
    end

    def on_charref_hex( code )
      on_charref( code )
    end

    def on_start_document
    end

    def on_end_document
    end

    def on_stag( name )
      @attrs = {}
    end

    def on_attribute( name )
      @attrs[ name ] = @currentAttr = ''
    end

    def on_attr_value( str )
      @currentAttr << str
    end

    def on_attr_entityref( ref )
      @currentAttr << ENTITY_REF_MAP[ ref ]
    end

    def on_attr_charref( code )
      @currentAttr << [ code ].pack( 'U' )
    end

    def on_attr_charref_hex( code )
      on_attr_charref( code )
    end

    def on_attribute_end( name )
    end

    def on_stag_end_empty( name )
      on_stag_end( name )
      on_etag( name )
    end

    def on_stag_end( name )
      @dest.startElement( name, @attrs )
    end
  end

  setFactory( self )
end


end
