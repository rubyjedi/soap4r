=begin
SOAP4R - EncodingStyle handler library
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
require 'soap/element'


module SOAP
  class EncodingStyleHandler
    @@handlerMap = {}
    @@defaultHandler = nil

    attr_reader :uri

    def initialize( uri )
      @uri = uri
      @@handlerMap[ uri ] = self
    end

    def decodeTag( ns, entity, parent )
      raise NotImplementError.new( 'Method decodeTag must be defined in derived class.' )
    end

    def decodeTagEnd( ns, node )
      raise NotImplementError.new( 'Method decodeTag must be defined in derived class.' )
    end

    def decodeText( ns, entity, parent )
      raise NotImplementError.new( 'Method decodeText must be defined in derived class.' )
    end

    def prologue
    end

    def epilogue
    end

    def EncodingStyleHandler.defaultHandler
      @@defaultHandler
    end

    def EncodingStyleHandler.defaultHandler=( handler )
      @@defaultHandler = handler
    end

    def EncodingStyleHandler.getHandler( uri )
      if @@handlerMap.has_key?( uri )
	@@handlerMap[ uri ]
      else
	@@defaultHandler
      end
    end

    def EncodingStyleHandler.each
      @@handlerMap.each do | key, value |
	yield( value )
      end
    end
  end
end
