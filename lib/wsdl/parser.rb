# WSDL4R - WSDL XML Instance parser library.
# Copyright (C) 2002 NAKAMURA Hiroshi.
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PRATICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 675 Mass
# Ave, Cambridge, MA 02139, USA.


require 'wsdl/wsdl'
require 'soap/namespace'
require 'soap/qname'
require 'soap/XMLSchemaDatatypes'
require 'wsdl/data'
require 'wsdl/xmlSchema/data'
require 'wsdl/soap/data'


module WSDL


class WSDLParser
  include WSDL

  class FormatDecodeError < Error; end
  class UnknownElementError < FormatDecodeError; end
  class UnknownAttributeError < FormatDecodeError; end
  class UnexpectedElementError < FormatDecodeError; end
  class ElemenConstraintError < FormatDecodeError; end

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
    attr_reader :ns
    attr_accessor :node

  private
    def initialize( ns = nil, node = nil )
      @ns = ns
      @node = node
    end
  end

public
  def initialize( opt = {} )
    @parseStack = nil
    @lastNode = nil
    @option = opt
  end

  def parse( stringOrReadable )
    @parseStack = []
    @lastNode = nil
    @textBuf = ''

    prologue

    doParse( stringOrReadable )

    epilogue

    @lastNode
  end

  def doParse( stringOrReadable )
    raise NotImplementError.new(
      'Method doParse must be defined in derived class.' )
  end

  def startElement( name, attrs )
    lastFrame = @parseStack.last
    ns = parent = nil
    if lastFrame
      ns = lastFrame.ns.clone
      parent = lastFrame.node
    else
      ::SOAP::NS.reset
      ns = ::SOAP::NS.new
      parent = nil
    end

    parseNS( ns, attrs )

    node = decodeTag( ns, name, attrs, parent )

    @parseStack << ParseFrame.new( ns, node )
  end

  def characters( text )
    lastFrame = @parseStack.last
    if lastFrame
      # Need not to be cloned because character does not have attr.
      ns = lastFrame.ns
      decodeText( ns, text )
    else
      p text if $DEBUG
    end
  end

  def endElement( name )
    lastFrame = @parseStack.pop
    decodeTagEnd( lastFrame.ns, lastFrame.node )
    @lastNode = lastFrame.node
  end

private
  def prologue
  end

  def epilogue
  end

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

  DefinitionsName = XSD::QName.new( Namespace, 'definitions' )
  def decodeTag( ns, name, attrs, parent )
    o = nil
    element = ns.parse( name )
    if !parent
      if element == DefinitionsName
	o = Definitions.parseElement( element )
      else
	raise UnknownElementError.new( "Unknown element #{ element }." )
      end
    else
      o = parent.parseElement( element )
      unless o
	raise UnknownElementError.new( "Unknown element #{ element }." )
      end
      o.parent = parent
    end
    attrs.each do | key, value |
      if /^xmlns/ !~ key
	attr = unless /:/ =~ key
	    XSD::QName.new( nil, key )
	  else
	    ns.parse( key )
	  end
	valueEle = unless /:/ =~ value
	    value
	  else
	    begin
	      ns.parse( value )
	    rescue
	      value
	    end
	  end
	o.parseAttr( attr, valueEle )
      end
    end
    o
  end

  def decodeTagEnd( ns, node )
    node.postParse
  end

  def decodeText( ns, text )
    @textBuf << text
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
].each do | lib |
  begin
    require lib
    loaded = true
    break
  rescue LoadError
  end
end
unless loaded
  raise RuntimeError.new( "XML processor module not found." )
end
