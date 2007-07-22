# WSDL4R - XMLSchema simpleType extension definition for WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'xsd/namedelements'


module WSDL
module XMLSchema


class SimpleExtension < Info
  attr_reader :base
  attr_reader :attributes
  attr_accessor :anyattribute

  def initialize
    super
    @base = nil
    @attributes = XSD::NamedElements.new
    @anyattribute = nil
  end

  def targetnamespace
    parent.targetnamespace
  end
  
  def valid?(value)
    true
  end

  def parse_element(element)
    case element
    when AttributeName
      o = Attribute.new
      @attributes << o
      o
    when AnyAttributeName
      @anyattribute = AnyAttribute.new
    end
  end

  def parse_attr(attr, value)
    case attr
    when BaseAttrName
      @base = value
    end
  end
end


end
end
