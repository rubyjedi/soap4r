=begin
WSDL4R - WSDL XMLScan parser library.
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

require 'soap/parser'
require 'xmlscan/scanner'


module WSDL


class WSDLXMLScanner < WSDLParser
  def initialize(*vars)
    super(*vars)
    @charset_backup = nil
  end

  def epilogue
    $KCODE = @charset_backup if @charset_backup
  end

  def do_parse(string_or_readable)
    @scanner = XMLScan::XMLScanner.new(Visitor.new(self))
    if @scanner.respond_to?(:kcode)
      @scanner.kcode = ::SOAP::Charset.charset_str(charset) if charset
    else
      @charset_backup = $KCODE
      $KCODE = ::SOAP::Charset.charset_str(charset) if charset
    end
    @scanner.parse(string_or_readable)
  end

  def scanner_kcode=(charset)
    if @scanner.respond_to?(:kcode)
      @scanner.kcode = ::SOAP::Charset.charset_str(charset) if charset
    elsif self.charset.nil?
      @charset_backup = $KCODE
      $KCODE = ::SOAP::Charset.charset_str(charset) if charset
    end
    self.xmldecl_encoding = charset
  end

  class Visitor; include XMLScan::Visitor
    ENTITY_REF_MAP = {
      'lt' => '<',
      'gt' => '>',
      'amp' => '&',
      'quot' => '"',
      'apos' => '\''
    }

    def initialize(dest)
      @dest = dest
      @attrs = {}
      @curattr = nil
    end

    def parse_error(msg)
      raise WSDLParser::ParseError.new(msg)
    end

    def wellformed_error(msg)
      raise NotWellFormedError.new(msg)
    end

    def valid_error(msg)
      raise NotValidError.new(msg)
    end

    def warning(msg)
      p msg if $DEBUG
    end

    # def on_xmldecl; end

    def on_xmldecl_version(str)
      # 1.0 expected.
    end

    def on_xmldecl_encoding(str)
      @dest.scanner_kcode = str
    end

    # def on_xmldecl_standalone(str); end

    # def on_xmldecl_other(name, value); end

    # def on_xmldecl_end; end

    # def on_doctype(root, pubid, sysid); end

    # def on_prolog_space(str); end

    # def on_comment(str); end

    # def on_pi(target, pi); end

    def on_chardata(str)
      @dest.characters(str)
    end

    # def on_cdata(str); end

    def on_etag(name)
      @dest.end_element(name)
    end

    def on_entityref(ref)
      @dest.characters(ENTITY_REF_MAP[ref])
    end

    def on_charref(code)
      @dest.characters([code].pack('U'))
    end

    def on_charref_hex(code)
      on_charref(code)
    end

    # def on_start_document; end

    # def on_end_document; end

    def on_stag(name)
      @attrs = {}
    end

    def on_attribute(name)
      @attrs[name] = @curattr = ''
    end

    def on_attr_value(str)
      @curattr << str
    end

    def on_attr_entityref(ref)
      @curattr << ENTITY_REF_MAP[ref]
    end

    def on_attr_charref(code)
      @curattr << [code].pack('U')
    end

    def on_attr_charref_hex(code)
      on_attr_charref(code)
    end

    # def on_attribute_end(name); end

    def on_stag_end_empty(name)
      on_stag_end(name)
      on_etag(name)
    end

    def on_stag_end(name)
      @dest.start_element(name, @attrs)
    end
  end

  add_factory(self)
end


end
