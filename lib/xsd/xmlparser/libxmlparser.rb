# encoding: UTF-8
# XSD4R - XMLParser XML parser library.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.

### WIP, 2015-June-13:  
###
### LibXML drops namespaces on Elements *AND* Attributes, which makes it impossible
### to correctly associate Namespaces on Namespace-Declared Element Attributes when
### more than one namespace exists.
###
### This issue is evident when you run test/soap/test_cookie.rb
###

require 'libxml'

module XSD
module XMLParser


class LibXMLParser < XSD::XMLParser::Parser
  include ::LibXML::XML::SaxParser::Callbacks

  def do_parse(string_or_readable)
    # string = string_or_readable.respond_to?(:read) ? string_or_readable.read : string_or_readable

    @charset = 'utf-8'
    string = StringIO.new(string_or_readable)
    parser = LibXML::XML::SaxParser.io(string)
    parser.callbacks = self
    parser.parse
  end

  ENTITY_REF_MAP = {
    'lt' => '<',
    'gt' => '>',
    'amp' => '&',
    'quot' => '"',
    'apos' => '\''
  }

  #def on_internal_subset(name, external_id, system_id)
  #  nil
  #end

  #def on_is_standalone()
  #  nil
  #end

  #def on_has_internal_subset()
  #  nil
  #end

  #def on_has_external_subset()
  #  nil
  #end

  #def on_start_document()
  #  nil
  #end

  #def on_end_document()
  #  nil
  #end

  def on_start_element_ns (name, attr_hash, prefix, uri, namespaces)
    prefixed_ns = attr_hash.merge(Hash[namespaces.map{|k,v| ["xmlns:#{k}",v]}])
    if prefix.nil?
      start_element(name, prefixed_ns)
    else
      start_element("#{prefix}:#{name}", prefixed_ns)
    end
  end

  def on_end_element_ns (name, prefix, uri)
    if prefix.nil?
      end_element(name)
    else
      end_element("#{prefix}:#{name}")
    end
  end

  def on_start_element (name, attr_hash)
    # start_element(name, attr_hash)
  end

  def on_end_element(name)
    # end_element(name)
  end

  def on_reference(name)
    characters(ENTITY_REF_MAP[name])
  end

  def on_characters(chars)
    characters(chars)
  end

  #def on_processing_instruction(target, data)
  #  nil
  #end

  #def on_comment(msg)
  #  nil
  #end

  def on_parser_warning(msg)
    warn(msg)
  end

  def on_parser_error(msg)
    raise ParseError.new(msg)
  end

  def on_parser_fatal_error(msg)
    raise ParseError.new(msg)
  end

  def on_cdata_block(cdata)
    characters(cdata)
  end

  def on_external_subset(name, external_id, system_id)
    nil
  end

  add_factory(self)
end


end
end
