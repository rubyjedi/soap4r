=begin
SOAP4R - SOAP Header handler library
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
require 'soap/namespace'


module SOAP


class HeaderHandler
  @@handlers = {}

  attr_reader :uri

  def initialize(namespace, name)
    @name = NS.normalizedName(namespace, name)
    @@handlers[@name] = self
  end


  def process(soap_obj)
    raise NotImplementError.new('Method process must be defined in derived class.')
  end


  ###
  ## Class interface
  #
  def EncodingStyleHandler.handler(namespace, name)
    normalizedName = NS.normalizedName(namespace, name)
    @@handlers[normalizedName]
  end

  def EncodingStyleHandler.each
    @@handlers.each do |key, value|
      yield(value)
    end
  end
end


end
