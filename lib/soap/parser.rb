=begin
SOAP4R - SOAP XML Instance Parser library.
Copyright (C) 2001, 2003  NAKAMURA, Hiroshi.

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


require 'xsd/ns'
require 'soap/soap'
require 'soap/baseData'
require 'soap/encodingStyleHandler'


module SOAP


class SOAPParser
  include SOAP

  class ParseError < Error; end
  class FormatDecodeError < Error; end
  class UnexpectedElementError < Error; end

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

private

  class ParseFrame
    attr_reader :node
    attr_reader :name
    attr_reader :ns, :encodingstyle

    class NodeContainer
      def initialize(node)
	@node = node
      end

      def node
	@node
      end

      def replace_node(node)
	@node = node
      end
    end

  public

    def initialize(ns, name, node, encodingstyle)
      @ns = ns
      @name = name
      self.node = node
      @encodingstyle = encodingstyle
    end

    def node=(node)
      @node = NodeContainer.new(node)
    end
  end

public

  attr_accessor :charset
  attr_accessor :default_encodingstyle
  attr_accessor :decode_typemap
  attr_accessor :allow_unqualified_element

  def initialize(opt = {})
    @parsestack = nil
    @lastnode = nil
    @handlers = {}
    @charset = opt[:charset] || 'us-ascii'
    @default_encodingstyle = opt[:default_encodingstyle] || EncodingNamespace
    @decode_typemap = opt[:decode_typemap] || nil
    @allow_unqualified_element = opt[:allow_unqualified_element] || false
  end

  def parse(string_or_readable)
    @parsestack = []
    @lastnode = nil

    prologue
    @handlers.each do |uri, handler|
      handler.decode_prologue
    end

    do_parse(string_or_readable)

    unless @parsestack.empty?
      raise FormatDecodeError.new("Unbalanced tag in XML.")
    end

    @handlers.each do |uri, handler|
      handler.decode_epilogue
    end
    epilogue

    @lastnode
  end

  def do_parse(string_or_readable)
    raise NotImplementError.new('Method do_parse must be defined in derived class.')
  end

  def start_element(name, attrs)
    lastframe = @parsestack.last
    ns = parent = parent_encodingstyle = nil
    if lastframe
      ns = lastframe.ns.clone
      parent = lastframe.node
      parent_encodingstyle = lastframe.encodingstyle
    else
      NS.reset
      ns = NS.new
      parent = ParseFrame::NodeContainer.new(nil)
      parent_encodingstyle = nil
    end

    attrs = parse_ns(ns, attrs)
    encodingstyle = find_encodingstyle(ns, attrs)

    # Children's encodingstyle is derived from its parent.
    encodingstyle ||= parent_encodingstyle || @default_encodingstyle

    node = decode_tag(ns, name, attrs, parent, encodingstyle)

    @parsestack << ParseFrame.new(ns, name, node, encodingstyle)
  end

  def characters(text)
    lastframe = @parsestack.last
    if lastframe
      # Need not to be cloned because character does not have attr.
      ns = lastframe.ns
      parent = lastframe.node
      encodingstyle = lastframe.encodingstyle
      decode_text(ns, text, encodingstyle)
    else
      # Ignore Text outside of SOAP Envelope.
      p text if $DEBUG
    end
  end

  def end_element(name)
    lastframe = @parsestack.pop
    unless name == lastframe.name
      raise UnexpectedElementError.new("Closing element name '#{ name }' does not match with opening element '#{ lastframe.name }'.")
    end
    decode_tag_end(lastframe.ns, lastframe.node, lastframe.encodingstyle)
    @lastnode = lastframe.node.node
  end

private

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
    return attrs if attrs.nil? or attrs.empty?
    newattrs = {}
    attrs.each do |key, value|
      if (NSParseRegexp =~ key)
        # '' means 'default namespace'.
        tag = $1 || ''
        ns.assign(value, tag)
      else
        newattrs[key] = value
      end
    end
    newattrs
  end

  def find_encodingstyle(ns, attrs)
    attrs.each do |key, value|
      if (ns.compare(EnvelopeNamespace, AttrEncodingStyle, key))
	return value
      end
    end
    nil
  end

  def decode_tag(ns, name, attrs, parent, encodingstyle)
    ele = ns.parse(name)

    # Envelope based parsing.
    if ((ele.namespace == EnvelopeNamespace) ||
	(@allow_unqualified_element && ele.namespace.nil?))
      o = decode_soap_envelope(ns, ele, attrs, parent)
      return o if o
    end

    # Encoding based parsing.
    handler = find_handler(encodingstyle)
    if handler
      return handler.decode_tag(ns, ele, attrs, parent)
    else
      raise FormatDecodeError.new("Unknown encodingStyle: #{ encodingstyle }.")
    end
  end

  def decode_tag_end(ns, node, encodingstyle)
    return unless encodingstyle

    handler = find_handler(encodingstyle)
    if handler
      return handler.decode_tag_end(ns, node)
    else
      raise FormatDecodeError.new("Unknown encodingStyle: #{ encodingstyle }.")
    end
  end

  def decode_text(ns, text, encodingstyle)
    handler = find_handler(encodingstyle)

    if handler
      handler.decode_text(ns, text)
    else
      # How should I do?
    end
  end

  def decode_soap_envelope(ns, ele, attrs, parent)
    o = nil
    if ele.name == EleEnvelope
      o = SOAPEnvelope.new
    elsif ele.name == EleHeader
      unless parent.node.is_a?(SOAPEnvelope)
	raise FormatDecodeError.new("Header should be a child of Envelope.")
      end
      o = SOAPHeader.new
      parent.node.header = o
    elsif ele.name == EleBody
      unless parent.node.is_a?(SOAPEnvelope)
	raise FormatDecodeError.new("Body should be a child of Envelope.")
      end
      o = SOAPBody.new
      parent.node.body = o
    elsif ele.name == EleFault
      unless parent.node.is_a?(SOAPBody)
	raise FormatDecodeError.new("Fault should be a child of Body.")
      end
      o = SOAPFault.new
      parent.node.fault = o
    end
    o.parent = parent if o
    o
  end

  def prologue
  end

  def epilogue
  end

  def find_handler(encodingstyle)
    unless @handlers.key?(encodingstyle)
      handler_factory = SOAP::EncodingStyleHandler.handler(encodingstyle) ||
	SOAP::EncodingStyleHandler.handler(EncodingNamespace)
      handler = handler_factory.new(@charset)
      handler.decode_typemap = @decode_typemap
      handler.decode_prologue
      @handlers[encodingstyle] = handler
    end
    @handlers[encodingstyle]
  end
end


end
