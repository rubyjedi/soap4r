=begin
SOAP4R - SOAP XML Instance Parser library.
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

require 'soap/soap'
require 'soap/charset'
require 'soap/baseData'
require 'soap/encodingStyleHandler'
require 'soap/namespace'


module SOAP


class SOAPParser
  include SOAP

  class FormatDecodeError < Error; end

  def self.adjustKCode
    false
  end

  @@parserFactory = nil

  def self.factory
    @@parserFactory
  end

  def self.createParser( opt = {} )
    @@parserFactory.new( opt )
  end

  def self.setFactory( factory )
    if $DEBUG
      puts "Set #{ factory } as XML processor."
    end
    @@parserFactory = factory
  end

private
  class ParseFrame
    attr_reader :node
    attr_reader :ns, :encodingStyle

  private

    class NodeContainer
      def initialize( node )
	@node = node
      end

      def node
	@node
      end

      def replaceNode( node )
	@node = node
      end
    end

  public

    def initialize( ns = nil, node = nil, encodingStyle = nil )
      @ns = ns
      self.node = node
      @encodingStyle = encodingStyle
    end

    def node=( node )
      @node = NodeContainer.new( node )
    end
  end

public

  def initialize( opt = {} )
    @parseStack = nil
    @lastNode = nil
    @option = opt
    @handlers = {}
    @decodeComplexTypes = @option[ 'decodeComplexTypes' ] || nil
    EncodingStyleHandler.defaultHandler =
      EncodingStyleHandler.getHandler( @option[ 'defaultEncodingStyle' ] ||
      EncodingNamespace )
  end

  def parse( stringOrReadable )
    @parseStack = []
    @lastNode = nil

    prologue
    @handlers.each do | uri, handler |
      handler.decodePrologue
    end

    doParse( stringOrReadable )

    unless @parseStack.empty?
      raise FormatDecodeError.new( "Unbalanced tag in XML." )
    end

    @handlers.each do | uri, handler |
      handler.decodeEpilogue
    end
    epilogue

    @lastNode
  end

  def doParse( stringOrReadable )
    raise NotImplementError.new( 'Method doParse must be defined in derived class.' )
  end

  def startElement( name, attrs )
    lastFrame = @parseStack.last
    ns = parent = parentEncodingStyle = nil
    if lastFrame
      ns = lastFrame.ns.clone
      parent = lastFrame.node
      parentEncodingStyle = lastFrame.encodingStyle
    else
      NS.reset
      ns = NS.new
      parent = ParseFrame::NodeContainer.new( nil )
      parentEncodingStyle = nil
    end

    parseNS( ns, attrs )
    encodingStyle = getEncodingStyle( ns, attrs )

    # Children's encodingStyle is derived from its parent.
    encodingStyle ||= parentEncodingStyle || EncodingStyleHandler.defaultHandler.uri

    node = decodeTag( ns, name, attrs, parent, encodingStyle )

    @parseStack << ParseFrame.new( ns, node, encodingStyle )
  end

  def characters( text )
    lastFrame = @parseStack.last
    if lastFrame
      # Need not to be cloned because character does not have attr.
      ns = lastFrame.ns
      parent = lastFrame.node
      encodingStyle = lastFrame.encodingStyle
      decodeText( ns, text, encodingStyle )
    else
      # Ignore Text outside of SOAP Envelope.
      p text if $DEBUG
    end
  end

  def endElement( name )
    lastFrame = @parseStack.pop
    decodeTagEnd( lastFrame.ns, lastFrame.node, lastFrame.encodingStyle )
    @lastNode = lastFrame.node.node
  end

private

  # $1 is necessary.
  NSParseRegexp = Regexp.new( '^xmlns:?(.*)$' )

  def parseNS( ns, attrs )
    return unless attrs
    attrs.each do | key, value |
      next unless ( NSParseRegexp =~ key )
      # '' means 'default namespace'.
      tag = $1 || ''
      ns.assign( value, tag )
    end
  end

  def getEncodingStyle( ns, attrs )
    attrs.each do | key, value |
      if ( ns.compare( EnvelopeNamespace, AttrEncodingStyle, key ))
	return value
      end
    end
    nil
  end

  def decodeTag( ns, name, attrs, parent, encodingStyle )
    o = nil
    handler = getHandler( encodingStyle )

    # SOAP Envelope parsing.
    element = ns.parse( name )
    if (( element.namespace == EnvelopeNamespace ) ||
	( @option.has_key?( 'allowUnqualifiedElement' ) &&
	element.namespace.nil? ))
      if element.name == 'Envelope'
	o = SOAPEnvelope.new
      elsif element.name == 'Header'
	unless parent.node.is_a?( SOAPEnvelope )
	  raise FormatDecodeError.new( "Header should be a child of Envelope." )
	end
	o = SOAPHeader.new
	parent.node.header = o
      elsif element.name == 'Body'
	unless parent.node.is_a?( SOAPEnvelope )
	  raise FormatDecodeError.new( "Body should be a child of Envelope." )
	end
	o = SOAPBody.new
	parent.node.body = o
      elsif element.name == 'Fault'
	unless parent.node.is_a?( SOAPBody )
	  raise FormatDecodeError.new( "Fault should be a child of Body." )
	end
	o = SOAPFault.new
	parent.node.setFault( o )
      end
    end

    # Encoding based parsing.
    unless o
      if handler
	o = handler.decodeTag( ns, name, attrs, parent )
      else
	# SOAPAny?
	raise FormatDecodeError.new( "Unknown encodingStyle: #{ encodingStyle }." )
      end
    else
      o.parent = parent
    end

    o
  end

  def decodeTagEnd( ns, node, encodingStyle )
    return unless encodingStyle

    handler = getHandler( encodingStyle )
    if handler
      handler.decodeTagEnd( ns, node )
    else
      raise FormatDecodeError.new( "Unknown encodingStyle: #{ encodingStyle }." )
    end
  end

  def decodeText( ns, text, encodingStyle )
    handler = getHandler( encodingStyle )

    if handler
      handler.decodeText( ns, text )
    else
      # How should I do?
    end
  end

  def prologue
  end

  def epilogue
  end

  def getHandler( encodingStyle )
    unless @handlers.has_key?( encodingStyle )
      handler = SOAP::EncodingStyleHandler.getHandler( encodingStyle ).new
      handler.decodeComplexTypes = @decodeComplexTypes
      handler.decodePrologue
      @handlers[ encodingStyle ] = handler
    end
    @handlers[ encodingStyle ]
  end
end


end
