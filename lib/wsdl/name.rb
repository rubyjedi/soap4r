=begin
WSDL4R - XML name definition.
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


module WSDL


class Name
  attr_accessor :namespace
  attr_accessor :name

  def initialize( namespace = nil, name = nil )
    @namespace = namespace
    @name = name
  end

  def ==( rhs )
    ( @namespace == rhs.namespace && @name == rhs.name )
  end

  def ===( rhs )
    ( self == rhs )
  end
  
  def to_s
    "{#{ namespace }}#{ name }"
  end
end


end
