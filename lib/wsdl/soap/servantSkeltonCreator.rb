=begin
WSDL4R - Creating servant skelton code from WSDL.
Copyright (C) 2002, 2003  NAKAMURA, Hiroshi.

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
require 'wsdl/soap/methodDefCreatorSupport'


module WSDL
  module SOAP


class ServantSkeltonCreator
  include MethodDefCreatorSupport

  attr_reader :definitions

  def initialize(definitions)
    @definitions = definitions
  end

  def dump(porttype = nil)
    if porttype.nil?
      result = ""
      @definitions.porttypes.each do |type|
	result << dump_porttype(type.name)
	result << "\n"
      end
    else
      result = dump_porttype(porttype)
    end
    result
  end

private

  def dump_porttype(porttype)
    operations = @definitions.porttype(porttype).operations
    dump_op = ""
    operations.each do |operation|
      dump_op << dump_operation(operation)
    end
    return <<__EOD__
class #{ create_class_name(porttype) }
#{ dump_op.gsub(/^/, "  ").chomp }
end
__EOD__
  end

  def dump_operation(operation)
    name = operation.name.name
    input = operation.input
    output = operation.output
    fault = operation.fault
    signature = "#{ name }#{ dump_inputparam(input) }"
    result = ""
    result << dump_signature(operation)
    result << <<__EOD__
def #{ name }#{ dump_inputparam(input) }
  raise NotImplementedError.new
end

__EOD__
  end
end


  end
end
