=begin
WSDL4R - Creating class definition from WSDL
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


require 'wsdl/data'
require 'wsdl/soap/methodDefCreatorSupport'


module WSDL
module SOAP


class ClassDefCreator
  include MethodDefCreatorSupport

  attr_reader :definitions

  def initialize(definitions)
    @definitions = definitions
    @complextypes = definitions.collect_complextypes
    @faulttypes = collect_faulttype(@definitions)
  end

  def dump(class_name = nil)
    result = ""
    if class_name
      result = dump_classdef(class_name)
    else
      @complextypes.each do |type|
	case type.compoundtype
	when :TYPE_STRUCT
	  result << dump_classdef(type.name)
	when :TYPE_ARRAY
	  result << dump_arraydef(type.name)
       	else
	  raise RuntimeError.new("Unknown complexContent definition...")
	end
	result << "\n"
      end
    end
    result
  end

private

  def dump_attrline(name)
    var_name = uncapitalize(name)
    return <<__EOD__
  def #{ name }
    @#{ var_name }
  end

  def #{ name }=(value)
    @#{ var_name } = value
  end

__EOD__
  end

  def dump_classdef(class_name)
    complextype = @complextypes[class_name]
    attr_lines = ""
    var_lines = ""
    init_lines = ""
    complextype.each_element do |ele_name, element|
      name = create_method_name(ele_name)
      type = element.type
      #attr_lines << "  attr_accessor :#{ name }	# #{ type }\n"
      attr_lines << dump_attrline(ele_name)
      init_lines << "    @#{ name } = #{ name }\n"
      unless var_lines.empty?
	var_lines << ",\n      "
      end
      var_lines << "#{ name } = nil"
    end
    attr_lines.chomp!
    init_lines.chomp!

    return <<__EOD__
# #{ class_name.namespace }
class #{ safe_class_name(class_name) }
  @@schema_type = "#{ class_name.name }"
  @@schema_ns = "#{ class_name.namespace }"

#{ attr_lines }
  def initialize(#{ var_lines })
#{ init_lines }
  end
end
__EOD__
  end

  def dump_arraydef(name)
    return <<__EOD__
# #{ name.namespace }
class #{ name.name } < Array
  # Contents type should be dumped here...
  @@schema_type = "#{ name.name }"
  @@schema_ns = "#{ name.namespace }"
end
__EOD__
  end

  def safe_class_name(name)
    if @faulttypes.index(name)
      "#{ name.name } < StandardError"
    else
      "#{ name.name }"
    end
  end

  def collect_faulttype(definitions)
    result = []
    collect_fault_messages(definitions).each do |message|
      parts = definitions.message(message).parts
      if parts.size != 1
	raise RuntimeError.new("Expects fault message to have 1 part.")
      end
      if result.index(parts[0].type).nil?
	result << parts[0].type
      end
    end
    result
  end

  def collect_fault_messages(definitions)
    result = []
    definitions.porttypes.each do |porttype|
      porttype.operations.each do |operation|
	if operation.fault && result.index(operation.fault.message).nil?
	  result << operation.fault.message
	end
      end
    end
    result
  end
end


end
end
