=begin
SOAP4R - NQXML document customization
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

require 'nqxml/document'
require 'nqxml/utils'


module NQXML
  def NQXML.encode(str)
    copy = str.gsub('&', '&amp;')
    copy.gsub!('<', '&lt;')
    copy.gsub!('>', '&gt;')
    copy.gsub!('"', '&quot;')
    copy.gsub!('\'', '&apos;')
    copy.gsub!("\r", '&#xd;')
    return copy
  end

  Attr = Struct.new( "Attr", :nodeName, :nodeValue )

  class Node
    def Node.initializeWithChildren( name, attrs, children = nil )
      newObj = self.new( Tag.new( name, {} ), nil )

      if attrs
	attrs.each do | attr |
	  newObj.entity.attrs[ attr.nodeName ] = attr.nodeValue
	end
      end

      if children
	if children.is_a?( Array )
	  children.each do | child |
	    newObj.addChildNode( child )
	  end
	elsif children.is_a?( NQXML::Node )
	  newObj.addChildNode( children )
	else
	  newObj.addChild( children )
	end
      end

      newObj
    end

    alias childNodes children

    def attributes
      entity.attrs.collect { | key, value |
	Attr.new( key, value )
      }
    end

    def nodeName
      entity.name
    end

    def nodeValue
      entity.text
    end

    def addChildNode( childNode )
      @children << childNode
    end
  end

  class NamedEntity
    alias nodeName name
  end
end
