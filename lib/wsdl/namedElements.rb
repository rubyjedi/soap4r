=begin
WSDL4R - WSDL named element collection for WSDL.
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


class NamedElements
  include Enumerable

  def initialize
    @elements = []
  end

  def dup
    o = NamedElements.new
    o.elements = @elements.dup
    o
  end

  def size
    @elements.size
  end

  def []( idx )
    if idx.is_a?( Numeric )
      @elements[ idx ]
    else
      @elements.find { | item | item.name == idx }
    end
  end

  def each
    @elements.each do | element |
      yield( element )
    end
  end

  def <<( rhs )
    @elements << rhs
  end

  def concat( rhs )
    @elements.concat( rhs.elements )
  end

protected

  def elements=( rhs )
    @elements = rhs
  end

  def elements
    @elements
  end
end

end
