=begin
WSDL4R - Creating client skelton code from WSDL.
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


class ClientSkeltonCreator
  include MethodDefCreatorSupport

  attr_reader :definitions

  def initialize(definitions)
    @definitions = definitions
  end

  def dump(service_name)
    result = ""
    @definitions.service(service_name).ports.each do |port|
      result << dump_porttype(port.porttype.name)
      result << "\n"
    end
    result
  end

private

  def dump_porttype(name)
    drv_name = create_class_name(name)

    result = ""
    result << <<__EOD__
endpoint_url = ARGV.shift
obj = #{ drv_name }.new(endpoint_url)

# Uncomment the below line to see SOAP wiredumps.
# obj.wiredump_dev = STDERR

__EOD__
    @definitions.porttype(name).operations.each do |operation|
      result << dump_signature(operation)
      result << dump_input_init(operation.input) << "\n"
      result << dump_operation(operation) << "\n\n"
    end
    result
  end

  def dump_operation(operation)
    name = operation.name.name
    input = operation.input
    "puts obj.#{ create_method_name(name) }#{ dump_inputparam(input) }"
  end

  def dump_input_init(input)
    result = input.find_message.parts.collect { |part|
      "#{ uncapitalize(part.name) }"
    }.join(" = ")
    if result.empty?
      ""
    else
      result << " = nil"
    end
    result
  end
end


  end
end
