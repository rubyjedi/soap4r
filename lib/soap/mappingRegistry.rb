=begin
SOAP4R - RPC utility -- Mapping registry.
Copyright (C) 2000, 2001, 2002, 2003  NAKAMURA, Hiroshi.

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


require 'soap/rpcUtils'
require 'soap/mapping'


module SOAP
module RPC


class MappingRegistry < SOAP::Mapping::Registry
  def initialize(*arg)
    super
  end

  def add(obj_class, soap_class, factory, info = nil)
    if (info.size > 1)
      raise RuntimeError.new("Parameter signature changed.")
    end
    @map.add(obj_class, soap_class, factory, { :type => info[0] })
  end
  alias :set :add
end


end
end
