=begin
SOAP4R - SOAP REXMLParser library.
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
require 'rexml/streamlistener'
require 'rexml/document'


module SOAP


class SOAPREXMLParser < SOAPParser
  include REXML::StreamListener

  def initialize( *vars )
    super( *vars )
  end

  def prologue
  end

  def doParse( stringOrReadable )
    source = nil
    if REXML::VERSION_MAJOR < 2 or
	( REXML::VERSION_MAJOR == 2 and REXML::VERSION_MINOR <= 4 )
      source = if charset
	  ::SOAP::Charset.codeConv( stringOrReadable, charset, 'UTF8' )
	else
	  stringOrReadable
	end
    else
      source = REXML::SourceFactory.create_from( stringOrReadable )
      source.encoding = charset if charset
    end
    # Listener passes a String in utf-8.
    @charset = 'utf-8'
    REXML::Document.parse_stream( source, self )
  end

  def epilogue
  end

  def tag_start( name, attrs )
    startElement( name, attrs )
  end

  def tag_end( name )
    endElement( name )
  end

  def text( text )
    characters( text )
  end

  def xmldecl( version, encoding, standalone )
    # Version should be checked.
  end

  setFactory( self )
end


end
