# WSDL4R - XMLSchema simpleType definition for WSDL.
# Copyright (C) 2004  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'xsd/namedelements'


module WSDL
module XMLSchema


class SimpleType < Info
  attr_accessor :name
  attr_reader :derivetype
  attr_reader :base

  def initialize(name = nil)
    super()
    @name = name
    @derivetype = nil
    @base = nil
  end

  def targetnamespace
    parent.targetnamespace
  end

  def parse_element(element)
    case element
    when RestrictionName
      unless @derivetype.nil?
	raise Parser::ElementConstraintError.new("illegal element: #{element}")
      end
      @derivetype = element.name
      self
    when EnumerationName
      if @derivetype.nil?
	raise Parser::ElementConstraintError.new("base attr not found.")
      end
      STDERR.puts("Restriction of basetype with simpleType definition is ignored for now.")
      nil
    end
  end

  def parse_attr(attr, value)
    case attr
    when NameAttrName
      return nil unless @derivetype.nil?
      @name = XSD::QName.new(targetnamespace, value)
    when BaseAttrName
      return nil if @derivetype.nil?
      @base = value
    else
      nil
    end
  end
end


end
end
