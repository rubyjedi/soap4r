=begin
WSDL4R - Creating method code support from WSDL.
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
require 'wsdl/data'
require 'soap/mappingRegistry'
require 'soap/typeMap'


module WSDL
  module SOAP


module MethodDefCreatorSupport
  def basetype_mapped_class(name)
    ::SOAP::TypeMap[name]
  end

  def create_class_name(name)
    if klass = basetype_mapped_class(name)
      ::SOAP::RPCUtils::DefaultMappingRegistry.find_mapped_obj_class(
	klass.name)
    else
      result = capitalize(name.name)
      unless /^[A-Z]/ =~ result
	result = "C_#{ name }"
      end
      result
    end
  end
  module_function :create_class_name

  def create_method_name(name)
    uncapitalize(name)
  end
  module_function :create_method_name

  def dump_signature(operation)
    name = operation.name.name
    input = operation.input
    output = operation.output
    fault = operation.fault
    signature = "#{ name }#{ dump_inputparam(input) }"
    return <<__EOD__
# SYNOPSIS
#   #{ signature}
#
# ARGS
#{ dump_inout_type(input).chomp }
#
# RETURNS
#{ dump_inout_type(output).chomp }
#
# RAISES
#{ dump_inout_type(fault).chomp }
#
__EOD__
  end
  module_function :dump_signature

  def dump_inout_type(param)
    if param
      message = param.find_message
      params = ""
      message.parts.each do |part|
        params << "#   #{ uncapitalize(part.name) }\t\t#{ create_class_name(part.type) } - #{ part.type }\n"
      end
      unless params.empty?
        return params
      end
    end
    "#    N/A\n"
  end
  module_function :dump_inout_type

  def dump_inputparam(input)
    message = input.find_message
    params = ""
    message.parts.each do |part|
      params << ", " unless params.empty?
      params << uncapitalize(part.name)
    end
    if params.empty?
      ""
    else
      "(#{ params })"
    end
  end
  module_function :dump_inputparam

  def capitalize(target)
    target.sub(/^([a-z])/) { $1.tr!('[a-z]', '[A-Z]') }
  end
  module_function :capitalize

  def uncapitalize(target)
    target.sub(/^([A-Z])/) { $1.tr!('[A-Z]', '[a-z]') }
  end
  module_function :uncapitalize
end


  end
end
