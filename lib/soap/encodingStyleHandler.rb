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

  class EncodingStyleError < Error; end

  class << self
  public
    def uri
      self::Namespace
    end

    def getHandler( uri )
      @@handlerMap[ uri ]
    end

    def each
      @@handlerMap.each do | key, value |
	yield( value )
      end
    end

  private
    def addHandler
      @@handlerMap[ self.uri ] = self
    end
  end

  attr_reader :charset

  def initialize( charset )
    @charset = charset
  end

  ###
  ## encode interface.
  #
  # Returns a XML instance as a string.
  def encodeData( ns, data, name, parent )
    raise NotImplementError.new( 'Method encodeData must be defined in derived class.' )
  end

  def encodePrologue
  end

  def encodeEpilogue
  end

  ###
  ## decode interface.
  #
  # Returns SOAP/OM data.
  def decodeTag( ns, name, attrs, parent )
    raise NotImplementError.new( 'Method decodeTag must be defined in derived class.' )
  end

  def decodeTagEnd( ns, name )
    raise NotImplementError.new( 'Method decodeTagEnd must be defined in derived class.' )
  end

  def decodeText( ns, text )
    raise NotImplementError.new( 'Method decodeText must be defined in derived class.' )
  end

  def decodePrologue
  end

  def decodeEpilogue
  end
end


end
