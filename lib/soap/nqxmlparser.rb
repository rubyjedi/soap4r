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
  def initialize(*vars)
    super(*vars)
    unless NQXML.const_defined?("XMLDecl")
      NQXML.const_set("XMLDecl", NilClass)
    end
    @charset_backup = nil
  end

  def prologue
    @charset_backup = $KCODE
    $KCODE = ::SOAP::Charset.charset_str(charset) if charset
  end

  def epilogue
    $KCODE = @charset_backup
  end

  def xmldecl_encoding=(charset)
    if self.charset.nil?
      @charset_backup = $KCODE
      $KCODE = ::SOAP::Charset.charset_str(charset) if charset
    end
    super
  end

  def do_parse(string_or_readable)
    tokenizer = NQXML::Tokenizer.new(string_or_readable)
    tokenizer.each do |entity|
      case entity
      when NQXML::Tag
	unless entity.isTagEnd
	  start_element(entity.name, entity.attrs)
	else
	  end_element(entity.name)
	end
      when NQXML::Text
	characters(entity.text)
      # NQXML::ProcessingInstruction is for nqxml version < 1.1.0
      when NQXML::XMLDecl, NQXML::ProcessingInstruction
	charset = entity.attrs['encoding']
	if charset
	  self.xmldecl_encoding = charset
	end
      when NQXML::Comment
	# Nothing to do.
      else
	raise FormatDecodeError.new("Unexpected XML: #{ entity }.")
      end
    end
  end

  add_factory(self)
end


end
