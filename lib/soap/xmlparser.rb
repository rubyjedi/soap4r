=begin
SOAP4R - SOAP xmlparser library.
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

require 'soap/parser'
require 'xmlparser'


module SOAP


class SOAPXMLParser < SOAPParser
  def initialize( stringOrReadable )
    super
  end

  def doParse( stringOrReadable )
    parser = XML::Parser.new
    parser.parse( stringOrReadable ) do | type, entity, data |
      case type
      when XML::Parser::START_ELEM
	tag( NQXML::Tag.new( entity, data, false ))
      when XML::Parser::END_ELEM
	tag( NQXML::Tag.new( entity, nil, true ))
      when XML::Parser::CDATA
	text( NQXML::Text.new( data ))
      else
	raise FormatDecodeError.new( "Unexpected XML: #{ entity }." )
      end
    end
  end
end


end
