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

  def startElement( name, attrs )
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

    parseNS( ns, attrs )
    encodingStyle = getEncodingStyle( ns, attrs )

    # Children's encodingStyle is derived from its parent.
    encodingStyle ||= parentEncodingStyle || EncodingStyleHandler.defaultHandler

    node = decodeTag( ns, name, attrs, parent, encodingStyle )

    @parseStack << ParseFrame.new( ns, node, encodingStyle )
  end

  def cdata( text )
    lastFrame = @parseStack.last
    if lastFrame
      ns = lastFrame.ns.clone
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
#    if lastFrame.node.node.name != name
#      raise FormatDecodeError.new( "Open element/close element mismatch: #{ lastFrame.node.node.name } and #{ name }." )
#    end
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
    handler = SOAP::EncodingStyleHandler.getHandler( encodingStyle )

    # SOAP Envelope parsing.
    namespace, lname = ns.parse( name )
    if (( namespace == EnvelopeNamespace ) ||
	( @option.has_key?( 'allowUnqualifiedElement' ) && namespace.nil? ))
      if lname == 'Envelope'
	o = SOAPEnvelope.new
      elsif lname == 'Header'
	unless parent.node.is_a?( SOAPEnvelope )
	  raise FormatDecodeError.new( "Header should be a child of Envelope." )
	end
	o = SOAPHeader.new
	parent.node.header = o
      elsif lname == 'Body'
	unless parent.node.is_a?( SOAPEnvelope )
	  raise FormatDecodeError.new( "Body should be a child of Envelope." )
	end
	o = SOAPBody.new
	parent.node.body = o
      elsif lname == 'Fault'
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

    handler = SOAP::EncodingStyleHandler.getHandler( encodingStyle )
    if handler
      handler.decodeTagEnd( ns, node )
    else
      raise FormatDecodeError.new( "Unknown encodingStyle: #{ encodingStyle }." )
    end
  end

  def decodeText( ns, text, encodingStyle )
    handler = SOAP::EncodingStyleHandler.getHandler( encodingStyle )

    if handler
      handler.decodeText( ns, text )
    else
      # How should I do?
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
	unless entity.isTagEnd
	  startElement( entity.name, entity.attrs )
	else
	  endElement( entity.name )
	end
      when NQXML::Text
	cdata( entity.text )
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
  def initialize( *vars )
    super( *vars )
    require 'nqxml/streamingparser'
  end

  def doParse( stringOrReadable )
    parser = NQXML::StreamingParser.new( stringOrReadable )
    parser.each do | entity |
      case entity
      when NQXML::Tag
	unless entity.isTagEnd?
	  startElement( entity.name, entity.attrs )
	else
	  endElement( entity.name )
	end
      when NQXML::Text
	cdata( entity )
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


end
