# WSDL4R - Creating driver code from WSDL.
# Copyright (C) 2002, 2003  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/soap/methodDefCreatorSupport'


module WSDL
module SOAP


class MethodDefCreator
  include MethodDefCreatorSupport

  attr_reader :definitions

  def initialize(definitions)
    @definitions = definitions
    @complextypes = @definitions.collect_complextypes
    @types = nil
  end

  def dump(porttype)
    @types = []
    result = ""
    operations = @definitions.porttype(porttype).operations
    binding = @definitions.porttype_binding(porttype)
    operations.each do |operation|
      op_bind = binding.operations[operation.name]
      result << ",\n" unless result.empty?
      result << dump_method(operation, op_bind).chomp
    end
    return result, @types
  end

private

  def dump_method(operation, binding)
    name = create_method_name(operation.name)
    name_as = operation.name.name
    params = collect_parameter(operation)
    soapaction = binding.soapoperation.soapaction
    namespace = binding.input.soapbody.namespace
    paramstr = param2str(params)
    if paramstr.empty?
      paramstr = '[]'
    else
      paramstr = "[\n" << paramstr << "]"
    end
    return <<__EOD__
[#{ dq(name_as) }, #{ dq(name) }, #{ paramstr }, #{ soapaction ? dq(soapaction) : "nil" }, #{ dq(namespace) }]
__EOD__
  end

  def collect_parameter(operation)
    result = operation.inputparts.collect { |part|
      collect_type(part.type)
      param_set('in', definedtype(part.type), part.name)
    }
    outparts = operation.outputparts
    if outparts.size > 0
      retval = outparts[0]
      collect_type(retval.type)
      result << param_set('retval', definedtype(retval.type), retval.name)
      cdr(outparts).each { |part|
	collect_type(part.type)
	result << param_set('out', definedtype(part.type), part.name)
      }
    end
    result
  end

  def definedtype(type)
    if mapped = basetype_mapped_class(type)
      [mapped]
    else
      definedtype = @complextypes[type]
      if definedtype.nil?
	raise RuntimeError.new("Type: #{type} not found.")
      end
      case definedtype.compoundtype
      when :TYPE_STRUCT
	['::SOAP::SOAPStruct', type.namespace, type.name]
      when :TYPE_ARRAY
	arytype = definedtype.find_arytype
	ns = arytype.namespace
	name = arytype.name.sub(/\[(?:,)*\]$/, '')
	['::SOAP::SOAPArray', ns, name]
      else
	raise NotImplementedError.new("Must not reach here.")
      end
    end
  end

  def param_set(io_type, type, name)
    [io_type, type, name]
  end

  def collect_type(type)
    # ignore inline type definition.
    return if type.nil?
    @types << type
    return unless @complextypes[type]
    @complextypes[type].each_element do |name, element|
      collect_type(element.type)
    end
  end

  def param2str(params)
    params.collect { |param|
      "  [#{ dq(param[0]) }, #{ dq(param[2]) },\n" <<
      "   #{ type2str(param[1]) }]"
    }.join(",\n")
  end

  def type2str(type)
    if type.size == 1
      "[#{ type[0] }]" 
    else
      "[#{ type[0] }, #{ dq(type[1]) }, #{ dq(type[2]) }]" 
    end
  end

  def dq(ele)
    "\"" << ele << "\""
  end

  def cdr(ary)
    result = ary.dup
    result.shift
    result
  end
end


end
end
