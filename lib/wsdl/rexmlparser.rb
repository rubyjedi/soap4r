=begin
WSDL4R - WSDL REXMLParser library.
Copyright (C) 2002, 2003  NAKAMURA, Hiroshi.

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

  def initialize(*vars)
    super(*vars)
  end

  def prologue
  end

  def do_parse(string_or_readable)
    source = nil
    source = REXML::SourceFactory.create_from(string_or_readable)
    source.encoding = charset if charset
    # Listener passes a String in utf-8.
    @charset = 'utf-8'
    REXML::Document.parse_stream(source, self)
  end

  def epilogue
  end

  def tag_start(name, attrs)
    start_element(name, attrs)
  end

  def tag_end(name)
    end_element(name)
  end

  def text(text)
    characters(text)
  end

  def xmldecl(version, encoding, standalone)
    # Version should be checked.
  end

  add_factory(self)
end


end
