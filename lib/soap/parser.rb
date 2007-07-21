# SOAP4R - SOAP XML Instance Parser library.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'xsd/xmlparser'
require 'soap/soap'
require 'soap/ns'
require 'soap/baseData'
require 'soap/encodingstyle/handler'


module SOAP


class Parser
  include SOAP

  class ParseError < Error; end
  class FormatDecodeError < ParseError; end
  class UnexpectedElementError < ParseError; end

private

  class ParseFrame
    attr_reader :node
    attr_reader :name
    attr_reader :ns
    attr_reader :encodingstyle
    attr_reader :handler

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

    def initialize(ns, name, node, encodingstyle, handler)
      @ns = ns
      @name = name
      @node = NodeContainer.new(node)
      @encodingstyle = encodingstyle
      @handler = handler
    end

    # to avoid memory consumption
    def update(ns, name, node, encodingstyle, handler)
      @ns = ns
      @name = name
      @node.replace_node(node)
      @encodingstyle = encodingstyle
      @handler = handler
      self
    end
  end

public

  attr_accessor :envelopenamespace
  attr_accessor :default_encodingstyle
  attr_accessor :decode_typemap
  attr_accessor :allow_unqualified_element

  def initialize(opt = {})
    @opt = opt
    @parser = XSD::XMLParser.create_parser(self, opt)
    @parsestack = nil
    @recycleframe = nil
    @lastnode = nil
    @handlers = {}
    @envelopenamespace = opt[:envelopenamespace] || EnvelopeNamespace
    @default_encodingstyle = opt[:default_encodingstyle] || EncodingNamespace
    @decode_typemap = opt[:decode_typemap] || nil
    @allow_unqualified_element = opt[:allow_unqualified_element] || false
  end

  def charset
    @parser.charset
  end

  def parse(string_or_readable)
    @parsestack = []
    @lastnode = nil

    @handlers.each do |uri, handler|
      handler.decode_prologue
    end

    @parser.do_parse(string_or_readable)

    unless @parsestack.empty?
      raise FormatDecodeError.new("Unbalanced tag in XML.")
    end

    @handlers.each do |uri, handler|
      handler.decode_epilogue
    end

    @lastnode
  end

  def start_element(name, attrs)
    lastframe = @parsestack.last
    ns = parent = parent_encodingstyle = nil
    if lastframe
      ns = lastframe.ns
      parent = lastframe.node
      parent_encodingstyle = lastframe.encodingstyle
    else
      ns = SOAP::NS.new
      parent = ParseFrame::NodeContainer.new(nil)
      parent_encodingstyle = nil
    end
    # ns might be the same
    ns, attrs = XSD::XMLParser.filter_ns(ns, attrs)
    encodingstyle = find_encodingstyle(ns, attrs)
    # Children's encodingstyle is derived from its parent.
    if encodingstyle.nil?
      if parent.node.is_a?(SOAPHeader)
        encodingstyle = LiteralNamespace
      else
        encodingstyle = parent_encodingstyle || @default_encodingstyle
      end
    end
    handler = find_handler(encodingstyle)
    unless handler
      raise FormatDecodeError.new("Unknown encodingStyle: #{ encodingstyle }.")
    end
    node = decode_tag(ns, name, attrs, parent, handler)
    if @recycleframe
      @parsestack << @recycleframe.update(ns, name, node, encodingstyle, handler)
      @recycleframe = nil
    else
      @parsestack << ParseFrame.new(ns, name, node, encodingstyle, handler)
    end
  end

  def characters(text)
    lastframe = @parsestack.last
    if lastframe
      # Need not to be cloned because character does not have attr.
      decode_text(lastframe.ns, text, lastframe.handler)
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
    decode_tag_end(lastframe.ns, lastframe.node, lastframe.handler)
    @lastnode = lastframe.node.node
    @recycleframe = lastframe
  end

private

  def find_encodingstyle(ns, attrs)
    attrs.each do |key, value|
      if (ns.compare(@envelopenamespace, AttrEncodingStyle, key))
	return value
      end
    end
    nil
  end

  def decode_tag(ns, name, attrs, parent, handler)
    ele = ns.parse(name)
    # Envelope based parsing.
    if ((ele.namespace == @envelopenamespace) ||
	(@allow_unqualified_element && ele.namespace.nil?))
      o = decode_soap_envelope(ns, ele, attrs, parent)
      return o if o
    end
    # Encoding based parsing.
    return handler.decode_tag(ns, ele, attrs, parent)
  end

  def decode_tag_end(ns, node, handler)
    return handler.decode_tag_end(ns, node)
  end

  def decode_text(ns, text, handler)
    handler.decode_text(ns, text)
  end

  def decode_soap_envelope(ns, ele, attrs, parent)
    o = nil
    if ele.name == EleEnvelope
      o = SOAPEnvelope.new
      if ext = @opt[:external_content]
	ext.each do |k, v|
	  o.external_content[k] = v
	end
      end
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
      if parent.node.is_a?(SOAPBody)
        o = SOAPFault.new
        parent.node.fault = o
      elsif parent.node.is_a?(SOAPEnvelope)
        # live.com server returns SOAPFault as a direct child of SOAPEnvelope.
        # support it even if it's not spec compliant.
        warn("Fault must be a child of Body.")
        body = SOAPBody.new
        parent.node.body = body
        o = SOAPFault.new
        body.fault = o
      else
        raise FormatDecodeError.new("Fault should be a child of Body.")
      end
    end
    o.extraattr.update(attrs) if o
    o
  end

  def find_handler(encodingstyle)
    unless @handlers.key?(encodingstyle)
      handler_factory = SOAP::EncodingStyle::Handler.handler(encodingstyle) ||
	SOAP::EncodingStyle::Handler.handler(EncodingNamespace)
      handler = handler_factory.new(@parser.charset)
      handler.decode_typemap = @decode_typemap
      handler.decode_prologue
      @handlers[encodingstyle] = handler
    end
    @handlers[encodingstyle]
  end
end


end
