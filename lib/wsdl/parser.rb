=begin
WSDL4R - WSDL XML Instance parser library.
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

require 'xsd/qname'
require 'xsd/ns'
require 'xsd/charset'
require 'xsd/datatypes'
require 'wsdl/wsdl'
require 'wsdl/data'
require 'wsdl/xmlSchema/data'
require 'wsdl/soap/data'


module WSDL


class WSDLParser
  include WSDL

  class ParseError < Error; end
  class FormatDecodeError < Error; end
  class UnknownElementError < FormatDecodeError; end
  class UnknownAttributeError < FormatDecodeError; end
  class UnexpectedElementError < FormatDecodeError; end
  class ElementConstraintError < FormatDecodeError; end

  @@parser_factory = nil

  def self.factory
    @@parser_factory
  end

  def self.create_parser(opt = {})
    @@parser_factory.new(opt)
  end

  def self.add_factory(factory)
    if $DEBUG
      puts "Set #{ factory } as XML processor."
    end
    @@parser_factory = factory
  end

  class ParseFrame
    attr_reader :ns
    attr_reader :name
    attr_accessor :node

  private
    def initialize(ns, name, node)
      @ns = ns
      @name = name
      @node = node
    end
  end

public
  attr_accessor :charset

  def initialize(opt = {})
    @parsestack = nil
    @lastnode = nil
    @charset = opt[:charset]
  end

  def parse(string_or_readable)
    @parsestack = []
    @lastnode = nil
    @textbuf = ''

    prologue

    do_parse(string_or_readable)

    epilogue

    @lastnode
  end

  def do_parse(string_or_readable)
    raise NotImplementError.new(
      'Method do_parse must be defined in derived class.')
  end

  def start_element(name, attrs)
    lastframe = @parsestack.last
    ns = parent = nil
    if lastframe
      ns = lastframe.ns.clone
      parent = lastframe.node
    else
      ::SOAP::NS.reset
      ns = ::SOAP::NS.new
      parent = nil
    end

    parse_ns(ns, attrs)

    node = decode_tag(ns, name, attrs, parent)

    @parsestack << ParseFrame.new(ns, name, node)
  end

  def characters(text)
    lastframe = @parsestack.last
    if lastframe
      # Need not to be cloned because character does not have attr.
      ns = lastframe.ns
      decode_text(ns, text)
    else
      p text if $DEBUG
    end
  end

  def end_element(name)
    lastframe = @parsestack.pop
    unless name == lastframe.name
      raise UnexpectedElementError.new("Closing element name '#{ name }' does not match with opening element '#{ lastframe.name }'.")
    end
    decode_tag_end(lastframe.ns, lastframe.node)
    @lastnode = lastframe.node
  end

private
  def prologue
  end

  def epilogue
  end

  def xmldecl_encoding=(charset)
    if @charset.nil?
      @charset = charset
    else
      # Definition in a stream (like HTTP) has a priority.
      p "encoding definition: #{ charset } is ignored." if $DEBUG
    end
  end

  # $1 is necessary.
  NSParseRegexp = Regexp.new('^xmlns:?(.*)$')

  def parse_ns(ns, attrs)
    return unless attrs
    attrs.each do |key, value|
      next unless (NSParseRegexp =~ key)
      # '' means 'default namespace'.
      tag = $1 || ''
      ns.assign(value, tag)
    end
  end

  def decode_tag(ns, name, attrs, parent)
    o = nil
    element = ns.parse(name)
    if !parent
      if element == DefinitionsName
	o = Definitions.parse_element(element)
      else
	raise UnknownElementError.new("Unknown element #{ element }.")
      end
    else
      o = parent.parse_element(element)
      unless o
	raise UnknownElementError.new("Unknown element #{ element }.")
      end
      o.parent = parent
    end
    attrs.each do |key, value|
      if /^xmlns/ !~ key
	attr = unless /:/ =~ key
	    XSD::QName.new(nil, key)
	  else
	    ns.parse(key)
	  end
	value_ele = if /:/ !~ value
	    value
	  elsif /^http:/ =~ value and !ns.assigned_tag?('http')
	    value
	  else
	    begin
	      ns.parse(value)
	    rescue
	      value
	    end
	  end
	o.parse_attr(attr, value_ele)
      end
    end
    o
  end

  def decode_tag_end(ns, node)
    node.parse_epilogue
  end

  def decode_text(ns, text)
    @textbuf << text
  end
end


end


# Try to load XML processor.
loaded = false
[
  'wsdl/xmlscanner',
  'wsdl/xmlparser',
  'wsdl/rexmlparser',
  'wsdl/nqxmlparser',
].each do |lib|
  begin
    require lib
    loaded = true
    break
  rescue LoadError
  end
end
unless loaded
  raise RuntimeError.new("XML processor module not found.")
end
