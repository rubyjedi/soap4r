# WSDL4R - Creating method code support from WSDL.
# Copyright (C) 2002, 2003  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/data'
require 'soap/mapping'
require 'soap/mapping/typeMap'


module WSDL
module SOAP


module MethodDefCreatorSupport
  def basetype_mapped_class(name)
    ::SOAP::TypeMap[name]
  end

  def create_class_name(name)
    if klass = basetype_mapped_class(name)
      ::SOAP::Mapping::DefaultRegistry.find_mapped_obj_class(klass.name)
    else
      result = capitalize(name.name)
      unless /^[A-Z]/ =~ result
	result = "C_#{ name }"
      end
      result
    end
  end
  module_function :create_class_name

  def create_method_name(qname)
    uncapitalize(qname.name)
  end
  module_function :create_method_name

  def dump_signature(operation)
    name = operation.name.name
    input = operation.input
    output = operation.output
    fault = operation.fault
    fault_string = fault.empty? ? '#   (undefined)' :
      (fault.collect { |f| dump_inout_type(f).chomp }).join(', ')
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
#{ fault_string }
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
    "#   N/A\n"
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
