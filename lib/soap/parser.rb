=begin
SOAP4R - SOAP Parser library.
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
require 'soap/baseData'
require 'soap/encoding'


module SOAP


class SOAPParser
  include SOAP

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

  def initialize( opt )
    @parseStack = nil
    @lastNode = nil
    @option = opt
    if @option.has_key?( 'defaultEncodingStyleHandler' )
      EncodingStyleHandler.defaultHandler = @option[ 'defaultEncodingStyleHandler' ]
    end
  end

  def parse( stringOrReadable )
    @parseStack = []
    @lastNode = nil

    prologue

    doParse( stringOrReadable )
    unless @parseStack.empty?
      raise FormatDecodeError.new( "Unbalanced tag in XML." )
    end

    epilogue

    @lastNode
  end

protected

  def tag( entity )
    unless entity.isTagEnd
      lastFrame = @parseStack.last
      ns = parent = parentEncodingStyle = nil
      if lastFrame
	ns = lastFrame.ns.clone
	parent = lastFrame.node
	parentEncodingStyle = lastFrame.encodingStyle
      else
	ns = NS.new
	parent = ParseFrame::NodeContainer.new( nil )
	parentEncodingStyle = nil
      end

      parseNS( ns, entity )
      encodingStyle, root = getEncodingStyle( ns, entity )

      # Children's encodingStyle is derived from its parent.
      encodingStyle ||= parentEncodingStyle

      node = decodeTag( ns, entity, parent, encodingStyle )

      @parseStack << ParseFrame.new( ns, node, encodingStyle )
    else
      lastFrame = @parseStack.pop
      decodeTagEnd( lastFrame.ns, lastFrame.node, lastFrame.encodingStyle )
      @lastNode = lastFrame.node.node
    end
  end

  def text( entity )
    lastFrame = @parseStack.last
    if lastFrame
      ns = lastFrame.ns.clone
      parent = lastFrame.node
      encodingStyle = lastFrame.encodingStyle
      decodeText( ns, entity, parent, encodingStyle )
    else
      # Ignore Text outside of SOAP Envelope.
      p entity if $DEBUG
    end
  end

private

  # $1 is necessary.
  NSParseRegexp = Regexp.new( '^xmlns:?(.*)$' )

  def parseNS( ns, entity )
    return unless entity.attrs
    entity.attrs.each do | key, value |
      next unless ( NSParseRegexp =~ key )
      # '' means 'default namespace'.
      tag = $1 || ''
      ns.assign( value, tag )
    end
  end

  def getEncodingStyle( ns, entity )
    entity.attrs.each do | key, value |
      if ( ns.compare( EnvelopeNamespace, AttrEncodingStyle, key ))
	return value
      end
    end
    nil
  end

  def decodeTag( ns, entity, parent, encodingStyle )
    o = nil
    handler = SOAP::EncodingStyleHandler.getHandler( encodingStyle )

    # SOAP Envelope parsing.
    namespace, name = ns.parse( entity.name )
    if (( namespace == EnvelopeNamespace ) ||
	( @option.has_key?( 'allowUnqualifiedElement' ) && namespace.nil? ))
      if name == 'Envelope'
	o = SOAPEnvelope.new
      elsif name == 'Header'
	unless parent.node.is_a?( SOAPEnvelope )
	  raise FormatDecodeError.new( "Header should be a child of Envelope." )
	end
	o = SOAPHeader.new
	parent.node.header = o
      elsif name == 'Body'
	unless parent.node.is_a?( SOAPEnvelope )
	  raise FormatDecodeError.new( "Body should be a child of Envelope." )
	end
	o = SOAPBody.new
	parent.node.body = o
      elsif name == 'Fault'
	unless parent.node.is_a?( SOAPBody )
	  raise FormatDecodeError.new( "Fault should be a child of Body." )
	end
	o = SOAPFault.new
	parent.node.setFault( o )
      end
    end

    unless o and namespace.nil?
      if name == 'faultcode'
	o = SOAPString.decode( ns, entity )
	parent.node.faultCode = o
      elsif name == 'faultstring'
	o = SOAPString.decode( ns, entity )
	parent.node.faultString = o
      elsif name == 'faultactor'
	o = SOAPString.decode( ns, entity )
	parent.node.faultActor = o
      elsif name == 'detail'
	if handler
	  o = handler.decodeTag( ns, entity, parent )
	else
	  o = SOAPString.decode( ns, entity )
	end
	parent.node.detail = o
      end
    end

    # Encoding based parsing.
    unless o
      if handler
	o = handler.decodeTag( ns, entity, parent )
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

    handler = SOAP::EncodingStyleHandler.getHandler( encodingStyle )
    if handler
      handler.decodeTagEnd( ns, node )
    else
      raise FormatDecodeError.new( "Unknown encodingStyle: #{ encodingStyle }." )
    end
  end

  def decodeText( ns, entity, parent, encodingStyle )
    handler = SOAP::EncodingStyleHandler.getHandler( encodingStyle )

    if handler
      handler.decodeText( ns, entity, parent )
    else
      # How should I do?
      # parent.node.set( entity.text )
    end
  end

  def prologue
    SOAP::EncodingStyleHandler.each do | handler |
      handler.decodePrologue
    end
  end

  def epilogue
    SOAP::EncodingStyleHandler.each do | handler |
      handler.decodeEpilogue
    end
  end
end


class SOAPNQXMLLightWeightParser < SOAPParser
  def initialize( *vars )
    super( *vars )
    require 'nqxml/tokenizer'
  end

  def doParse( stringOrReadable )
    tokenizer = NQXML::Tokenizer.new( stringOrReadable )
    tokenizer.each do | entity |
      case entity
      when NQXML::Tag
	tag( entity )
      when NQXML::Text
	text( entity )
      when NQXML::ProcessingInstruction
	# ToDo...
      when NQXML::Comment
	# Nothing to do.
      else
	raise FormatDecodeError.new( "Unexpected XML: #{ entity }." )
      end
    end
  end
end

class SOAPNQXMLStreamingParser < SOAPParser
  def initialize
    super
    require 'nqxml/streamingparser'
  end

  def doParse( stringOrReadable )
    parser = NQXML::StreamingParser.new( stringOrReadable )
    parser.each do | entity |
      case entity
      when NQXML::Tag
	tag( entity )
      when NQXML::Text
	text( entity )
      when NQXML::ProcessingInstruction
	# ToDo...
      when NQXML::Comment
	# Nothing to do.
      else
	raise FormatDecodeError.new( "Unexpected XML: #{ entity }." )
      end
    end
  end
end

class SOAPXMLParserParser < SOAPParser
  def initialize( stringOrReadable )
    raise NotImplementError.new
  end

  def doParse
  end
end


end
