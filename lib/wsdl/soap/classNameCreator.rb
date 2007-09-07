# WSDL4R - Class name creator.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/mapping/typeMap'
require 'xsd/codegen/gensupport'


module WSDL
module SOAP


class ClassNameCreator
  include XSD::CodeGen::GenSupport

  def initialize
    @classname = {}
  end

  def create_name(qname, modulepath = nil)
    if klass = ::SOAP::TypeMap[qname]
      return ::SOAP::Mapping::DefaultRegistry.find_mapped_obj_class(klass).name
    end
    if @classname.key?(qname)
      name = @classname[qname]
    else
      name = safeconstname(qname.name)
      while @classname.value?(name)
        name += '_'
      end
      @classname[qname] = name.freeze
    end
    if modulepath
      [modulepath, name].join('::')
    else
      name
    end
  end
end


end
end
