# WSDL4R - Creating servant skelton code from WSDL.
# Copyright (C) 2002, 2003  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


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
