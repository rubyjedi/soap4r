=begin
SOAP4R - SOAP NQXMLParser library.
Copyright (C) 2001, 2003 NAKAMURA Hiroshi.

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
require 'nqxml/tokenizer'
require 'nqxml/streamingparser'


module SOAP


class SOAPNQXMLLightWeightParser < SOAPParser
  def initialize( *vars )
    super( *vars )
    unless NQXML.const_defined?( "XMLDecl" )
      NQXML.const_set( "XMLDecl", NilClass )
    end
    @charsetBackup = nil
  end

  def prologue
    @charsetBackup = $KCODE
    $KCODE = Charset.getCharsetStr( charset )
  end

  def epilogue
    $KCODE = @charsetBackup
  end

  def setXMLDeclEncoding( charset )
    if self.charset.nil?
      @charsetBackup = $KCODE
      $KCODE = Charset.getCharsetStr( charset )
    end
    super
  end

  def doParse( stringOrReadable )
    tokenizer = NQXML::Tokenizer.new( stringOrReadable )
    tokenizer.each do | entity |
      case entity
      when NQXML::Tag
	unless entity.isTagEnd
	  startElement( entity.name, entity.attrs )
	else
	  endElement( entity.name )
	end
      when NQXML::Text
	characters( entity.text )
      # NQXML::ProcessingInstruction is for nqxml version < 1.1.0
      when NQXML::XMLDecl, NQXML::ProcessingInstruction
	charset = entity.attrs[ 'encoding' ]
	if charset
	  setXMLDeclEncoding( charset )
	end
      when NQXML::Comment
	# Nothing to do.
      else
	raise FormatDecodeError.new( "Unexpected XML: #{ entity }." )
      end
    end
  end

  setFactory( self )
end


=begin
class SOAPNQXMLStreamingParser < SOAPParser
  def initialize( *vars )
    super( *vars )
    unless NQXML.const_defined?( "XMLDecl" )
      NQXML.const_set( "XMLDecl", NilClass )
    end
  end

  def doParse( stringOrReadable )
    parser = NQXML::StreamingParser.new( stringOrReadable )
    parser.each do | entity |
      case entity
      when NQXML::Tag
	unless entity.isTagEnd
	  startElement( entity.name, entity.attrs )
	else
	  endElement( entity.name )
	end
      when NQXML::Text
	characters( entity.text )
      # NQXML::ProcessingInstruction is for nqxml version < 1.1.0
      when NQXML::XMLDecl, NQXML::ProcessingInstruction
	charset = entity.attrs[ 'encoding' ]
	if charset
	  setXMLDeclEncoding( charset )
	end
      when NQXML::Comment
	# Nothing to do.
      else
	raise FormatDecodeError.new( "Unexpected XML: #{ entity }." )
      end
    end
  end

  # setFactory( self )
end
=end


end
