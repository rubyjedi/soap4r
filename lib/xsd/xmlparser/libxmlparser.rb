# encoding: UTF-8
# XSD4R - XMLParser XML parser library.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.

require 'libxml'

module XSD
module XMLParser


class LibXMLParser < XSD::XMLParser::Parser
  # Parses via XML::Reader rather than the SaxParser callbacks used before.
  # libxml-ruby's SAX2 callback (on_start_element_ns) never surfaces an
  # attribute's own namespace prefix to Ruby: the C extension
  # (ruby_xml_sax2_handler.c's start_element_ns_callback) only reads an
  # attribute's local name and value, discarding the prefix/URI slots that
  # libxml2 itself provides per attribute. That made it impossible to
  # recognize namespace-qualified attributes such as xsi:type, xsi:nil, and
  # xml:lang, which SOAP4R's demarshaller depends on to pick the right Ruby
  # type -- values silently fell back to an untyped SOAP::Mapping::Object,
  # or stayed raw strings instead of being cast to Integer/nil/etc. This gap
  # is still present as of libxml-ruby 6.0.0 (2026); it isn't a matter of
  # being on an old release.
  #
  # XML::Reader's per-attribute #name *does* return the full "prefix:local"
  # form (confirmed against libxml-ruby 2.8.0, the version pinned for Ruby
  # 1.9.3, through the current 3.x/6.x releases) -- matching exactly what
  # REXML's tag_start and Ox's attr callbacks already hand back, so this
  # mirrors their convention rather than trying to resolve namespace URIs
  # itself.
  def do_parse(string_or_readable)
    $stderr.puts "XSD::XMLParser::LibXMLParser.do_parse" if $DEBUG
    @charset = 'utf-8'
    string = string_or_readable.respond_to?(:read) ? string_or_readable.read : string_or_readable
    reader = ::LibXML::XML::Reader.string(string)
    while reader.read
      case reader.node_type
      when ::LibXML::XML::Reader::TYPE_ELEMENT
        name = reader.name
        attrs = read_attributes(reader)
        empty = reader.empty_element?
        start_element(name, attrs)
        end_element(name) if empty
      when ::LibXML::XML::Reader::TYPE_END_ELEMENT
        end_element(reader.name)
      when ::LibXML::XML::Reader::TYPE_TEXT,
           ::LibXML::XML::Reader::TYPE_CDATA,
           ::LibXML::XML::Reader::TYPE_SIGNIFICANT_WHITESPACE
        characters(reader.value)
      end
    end
  rescue ::LibXML::XML::Error => e
    raise ParseError.new(e.message)
  end

  add_factory(self)

  private

  # Attribute names come back in literal "prefix:local" form already (see
  # do_parse comment above), including xmlns:* declarations -- which are
  # themselves just attributes as far as the reader is concerned, so no
  # separate namespace-merging step is needed.
  def read_attributes(reader)
    attrs = {}
    return attrs unless reader.has_attributes?
    if reader.move_to_first_attribute == 1
      begin
        attrs[reader.name] = reader.value
      end while reader.move_to_next_attribute == 1
      reader.move_to_element
    end
    attrs
  end
end


end
end
