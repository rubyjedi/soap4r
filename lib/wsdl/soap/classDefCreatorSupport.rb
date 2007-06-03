# WSDL4R - Creating class code support from WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'soap/mapping'
require 'soap/mapping/typeMap'
require 'xsd/codegen/gensupport'


module WSDL
module SOAP


module ClassDefCreatorSupport
  include XSD::CodeGen::GenSupport

  def create_class_name(qname, modulepath = nil)
    if klass = basetype_mapped_class(qname)
      ::SOAP::Mapping::DefaultRegistry.find_mapped_obj_class(klass).name
    else
      name = safeconstname(qname.name)
      if modulepath
        [modulepath, name].join('::')
      else
        name
      end
    end
  end

  def basetype_mapped_class(name)
    ::SOAP::TypeMap[name]
  end

  def dump_method_signature(operation, element_definitions)
    name = operation.name
    input = operation.input
    output = operation.output
    fault = operation.fault
    signature = "#{ name }#{ dump_inputparam(input) }"
    str = <<__EOD__
# SYNOPSIS
#   #{name}#{dump_inputparam(input)}
#
# ARGS
#{dump_inout_type(input, element_definitions).chomp}
#
# RETURNS
#{dump_inout_type(output, element_definitions).chomp}
#
__EOD__
    unless fault.empty?
      str <<<<__EOD__
# RAISES
#{dump_fault_type(fault, element_definitions)}
#
__EOD__
    end
    str
  end

  def dq(ele)
    ele.dump
  end

  def ndq(ele)
    ele.nil? ? 'nil' : dq(ele)
  end

  def sym(ele)
    ':' + ele.id2name
  end

  def nsym(ele)
    ele.nil? ? 'nil' : sym(ele)
  end

  def dqname(qname)
    qname.dump
  end

private

  def dump_inout_type(param, element_definitions)
    if param
      message = param.find_message
      params = ""
      message.parts.each do |part|
        name = safevarname(part.name)
        if part.type
          typename = safeconstname(part.type.name)
          qname = part.type
          params << add_at("#   #{name}", "#{typename} - #{qname}\n", 20)
        elsif part.element
          ele = element_definitions[part.element]
          if ele.type
            typename = safeconstname(ele.type.name)
            qname = ele.type
          else
            typename = safeconstname(ele.name.name)
            qname = ele.name
          end
          params << add_at("#   #{name}", "#{typename} - #{qname}\n", 20)
        end
      end
      unless params.empty?
        return params
      end
    end
    "#   N/A\n"
  end

  def dump_inputparam(input)
    message = input.find_message
    params = ""
    message.parts.each do |part|
      params << ", " unless params.empty?
      params << safevarname(part.name)
    end
    if params.empty?
      ""
    else
      "(#{ params })"
    end
  end

  def add_at(base, str, pos)
    if base.size >= pos
      base + ' ' + str
    else
      base + ' ' * (pos - base.size) + str
    end
  end

  def dump_fault_type(fault, element_definitions)
    fault.collect { |ele|
      dump_inout_type(ele, element_definitions).chomp
    }.join("\n")
  end
end


end
end
