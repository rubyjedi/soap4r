=begin
SOAP4R - SOAP XML Instance Generator library.
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


###
## CAUTION: MT-unsafe
#
class SOAPGenerator
  include SOAP

  class FormatEncodeError < Error; end

public

  attr_accessor :charset
  attr_accessor :defaultEncodingStyle
  attr_accessor :generateEncodeType

  def initialize( opt = {} )
    @refTarget = nil
    @handlers = {}
    @charset = opt[ :charset ] || Charset.getEncodingLabel
    @defaultEncodingStyle = opt[ :defaultEncodingStyle ] || EncodingNamespace
    @generateEncodeType = if opt.has_key?( :generateEncodeType )
	opt[ :generateEncodeType ]
      else
	true
      end
  end

  def generate( obj, io = nil )
    prologue
    @handlers.each do | uri, handler |
      handler.encodePrologue
    end

    io = '' if io.nil?

    NS.reset
    ns = NS.new
    io << xmlDecl
    encodeData( io, ns, true, obj, nil )

    @handlers.each do | uri, handler |
      handler.encodeEpilogue
    end
    epilogue

    io
  end

  def encodeData( buf, ns, qualified, obj, parent )
    if obj.is_a?( SOAPEnvelopeElement )
      encodeElement( buf, ns, qualified, obj, parent )
      return
    end

    if @refTarget && !obj.precedents.empty?
      @refTarget.add( obj.elementName.name, obj )
      ref = SOAPReference.new
      ref.elementName.name = obj.elementName.name
      ref.__setobj__( obj )
      obj.precedents.clear	# Avoid cyclic delay.
      obj.encodingStyle = parent.encodingStyle
      # SOAPReference is encoded here.
      obj = ref
    end

    encodingStyle = obj.encodingStyle
    # Children's encodingStyle is derived from its parent.
    encodingStyle ||= parent.encodingStyle if parent
    obj.encodingStyle = encodingStyle

    handler = getHandler( encodingStyle || @defaultEncodingStyle )
    unless handler
      raise FormatEncodeError.new(
        "Unknown encodingStyle: #{ encodingStyle }." )
    end

    if !obj.elementName.name
      raise FormatEncodeError.new( "Element name not defined: #{ obj }." )
    end

    handler.encodeData( buf, ns, qualified, obj, parent ) do | child, childQualified |
      encodeData( buf, ns.clone, childQualified, child, obj )
    end
    handler.encodeDataEnd( buf, ns, qualified, obj, parent )
  end

  def encodeElement( buf, ns, qualified, obj, parent )
    if obj.is_a?( SOAPBody )
      @refTarget = obj
      obj.encode( buf, ns ) do | child, childQualified |
        encodeData( buf, ns.clone, childQualified, child, obj )
      end
      @refTarget = nil
    else
      attrs = {}
      if obj.is_a?( SOAPEnvelope ) and @generateEncodeType
        SOAPGenerator.assignNamespace( attrs, ns, XSD::Namespace,
          XSDNamespaceTag )
        SOAPGenerator.assignNamespace( attrs, ns, XSD::InstanceNamespace,
          XSINamespaceTag )
      end
      obj.encode( buf, ns, attrs ) do | child, childQualified |
        encodeData( buf, ns.clone, childQualified, child, obj )
      end
    end
  end

  def self.assignNamespace( attrs, ns, namespace, tag = nil )
    unless ns.assigned?( namespace )
      tag = ns.assign( namespace, tag )
      attrs[ 'xmlns:' << tag ] = namespace
    end
  end

  def self.encodeTag( buf, elementName, attrs = nil, pretty = nil )
    if attrs
      buf << "<#{ elementName }"
      attrs.each do | key, value |
        buf << %Q[ #{ key }="#{ value }"]
      end
      buf << '>'
    else
      buf << "<#{ elementName }>"
    end
    buf << "\n" if pretty
  end

  def self.encodeTagEnd( buf, elementName, pretty = nil )
    buf << "</#{ elementName }>"
    buf << "\n" if pretty
  end

  EncodeMap = {
    '&' => '&amp;',
    '<' => '&lt;',
    '>' => '&gt;',
    '"' => '&quot;',
    '\'' => '&apos;',
    "\r" => '&#xd;'
  }
  EncodeCharRegexp = Regexp.new( "[#{EncodeMap.keys.join}]" )
  def self.encodeStr( str )
    str.gsub(EncodeCharRegexp) { |c| EncodeMap[c] }
  end

private

  def prologue
  end

  def epilogue
  end

  def getHandler( encodingStyle )
    unless @handlers.has_key?( encodingStyle )
      handler = SOAP::EncodingStyleHandler.getHandler( encodingStyle ).new(
	@charset )
      handler.generateEncodeType = @generateEncodeType
      handler.encodePrologue
      @handlers[ encodingStyle ] = handler
    end
    @handlers[ encodingStyle ]
  end

  def xmlDecl
    if @charset
      %Q[<?xml version="1.0" encoding="#{ @charset }" ?>\n]
    else
      %Q[<?xml version="1.0" ?>\n]
    end
  end
end


end
