# WSDL4R - Creating CGI stub code from WSDL.
# Copyright (C) 2002, 2003  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'wsdl/soap/mappingRegistryCreator'
require 'wsdl/soap/methodDefCreator'
require 'wsdl/soap/classDefCreatorSupport'
require 'wsdl/soap/methodDefCreatorSupport'


module WSDL
module SOAP


class CGIStubCreator
  include ClassDefCreatorSupport
  include MethodDefCreatorSupport

  attr_reader :definitions

  def initialize(definitions)
    @definitions = definitions
  end

  def dump(service_name)
    STDERR.puts "!!! IMPORTANT !!!"
    STDERR.puts "- CGI stub can only 1 port.  Creating stub for the first port...  Rests are ignored."
    STDERR.puts "!!! IMPORTANT !!!"
    port = @definitions.service(service_name).ports[0]
    dump_porttype(port.porttype.name)
  end

private

  def dump_porttype(name)
    class_name = create_class_name(name)
    method_def, types = MethodDefCreator.new(@definitions).dump(name)
    mr_creator = MappingRegistryCreator.new(@definitions)

    return <<__EOD__
require 'soap/rpc/cgistub'

class #{ class_name }
  require 'soap/rpcUtils'
  MappingRegistry = SOAP::Mapping::Registry.new

#{ mr_creator.dump(types).gsub(/^/, "  ").chomp }
  Methods = [
#{ method_def.gsub(/^/, "    ").chomp }
  ]
end

class #{name}App < SOAP::RPC::CGIStub
  def initialize(*arg)
    super(*arg)
    servant = #{ class_name }.new
    #{ class_name }::Methods.each do |name_as, name, params, soapaction, namespace|
      add_method_with_namespace_as(namespace, servant, name, name_as, params, soapaction)
    end

    self.mapping_registry = #{ class_name }::MappingRegistry
    self.level = Logger::Severity::ERROR
  end
end

# Change listen port.
#{name}App.new('app', nil).start
__EOD__
  end
end


end
end
