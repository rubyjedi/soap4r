=begin
WSDL4R - WSDL import definition.
Copyright (C) 2002 NAKAMURA Hiroshi.

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


require 'wsdl/info'


module WSDL


class Import < Info
  attr_reader :namespace
  attr_reader :location
  attr_reader :content

  def initialize
    super
    @namespace = nil
    @location = nil
    @content = nil
  end

  def parseElement( element )
    nil
  end

  NamespaceAttrName = Name.new( nil, 'namespace' )
  LocationAttrName = Name.new( nil, 'location' )
  def parseAttr( attr, value )
    case attr
    when NamespaceAttrName
      @namespace = value
      if @content
	@content.setTargetNamespace( @namespace )
      end
    when LocationAttrName
      @location = value
      @content = import( @location )
      @content.root = root
      if @namespace
	@content.setTargetNamespace( @namespace )
      end
    else
      raise WSDLParser::UnknownAttributeError.new( "Unknown attr #{ attr }." )
    end
  end

private

  def import( location )
    require 'http-access2'
    c = HTTPAccess2::Client.new( ENV[ 'http_proxy' ] || ENV[ 'HTTP_PROXY' ] )
    content = c.getContent( location )
    WSDL::WSDLParser.createParser.parse( content )
  end
end


end
