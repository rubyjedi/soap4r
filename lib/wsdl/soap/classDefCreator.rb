# WSDL4R - Creating class definition from WSDL
# Copyright (C) 2002, 2003  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/data'
require 'wsdl/soap/classDefCreatorSupport'
require 'xsd/codegen'


module WSDL
module SOAP


class ClassDefCreator
  include ClassDefCreatorSupport

  def initialize(complextypes, definitions = nil)
    @complextypes = complextypes
    @faulttypes = definitions ? collect_faulttype(definitions) : []
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

  def dump_classdef(qname)
    complextype = @complextypes[qname]
    if @faulttypes.index(qname)
      c = XSD::CodeGen::ClassDef.new(create_class_name(qname), ::StandardError)
    else
      c = XSD::CodeGen::ClassDef.new(create_class_name(qname))
    end
    c.comment = "#{ qname.namespace }"
    c.def_classvar("schema_type", qname.name.dump)
    c.def_classvar("schema_ns", qname.namespace.dump)
    init_lines = ""
    params = []
    complextype.each_element do |element|
      c.def_attr(element.name.name, true, safevarname(element.name.name))
      name = safevarname(element.name.name)
      init_lines << "@#{ name } = #{ name }\n"
      params << "#{ name } = nil"
    end
    c.def_method("initialize", *params) do
      init_lines
    end
    c.dump
  end

  def dump_arraydef(qname)
    c = XSD::CodeGen::ClassDef.new(create_class_name(qname), ::Array)
    c.comment = "#{ qname.namespace }"
    c.def_classvar("schema_type", qname.name.dump)
    c.def_classvar("schema_ns", qname.namespace.dump)
    c.dump
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
	operation.fault.each do |fault|
	  if result.index(fault.message).nil?
	    result << fault.message
	  end
	end
      end
    end
    result
  end
end


end
end
