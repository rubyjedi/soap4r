# WSDL4R - Creating class code support from WSDL.
# Copyright (C) 2004  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'soap/mapping'
require 'soap/mapping/typeMap'


module WSDL
module SOAP


module ClassDefCreatorSupport
  def create_class_name(qname)
    if klass = basetype_mapped_class(qname)
      ::SOAP::Mapping::DefaultRegistry.find_mapped_obj_class(klass.name)
    else
      classname = qname.name.scan(/[a-zA-Z0-9_]+/).collect { |ele|
        capitalize(ele)
      }.join
      #classname = capitalize(qname.name).gsub(/[^a-zA-Z0-9_]/, '_')
      if /^[A-Z]/ =~ classname
        classname
      else
	"C_#{ classname }"
      end
    end
  end

  def capitalize(target)
    target.sub(/^([a-z])/) { $1.tr!('[a-z]', '[A-Z]') }
  end

  def basetype_mapped_class(name)
    ::SOAP::TypeMap[name]
  end
end


end
end
