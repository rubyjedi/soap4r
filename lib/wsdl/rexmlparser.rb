=begin
SOAP4R - WSDL REXMLParser library.
Copyright (C) 2002 NAKAMURA Hiroshi.

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

require 'wsdl/parser'
require 'rexml/streamlistener'
require 'rexml/document'


module WSDL


class WSDLREXMLParser < WSDLParser
  include REXML::StreamListener

  def initialize( *vars )
    super( *vars )
  end

  def doParse( stringOrReadable )
    REXML::Document.parse_stream( stringOrReadable, self )
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
