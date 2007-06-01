# WSDL4R - XMLSchema simpleContent restriction definition for WSDL.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'
require 'xsd/namedelements'


module WSDL
module XMLSchema


class SimpleRestriction < Info
  attr_reader :base
  attr_reader :enumeration
  attr_accessor :length
  attr_accessor :maxlength
  attr_accessor :minlength
  attr_accessor :pattern

  def initialize
    super
    @base = nil
    @enumeration = []   # NamedElements?
    @length = nil
    @maxlength = nil
    @minlength = nil
    @pattern = nil
  end
  
  def valid?(value)
    return false unless check_restriction(value)
    return false unless check_length(value)
    return false unless check_maxlength(value)
    return false unless check_minlength(value)
    return false unless check_pattern(value)
    true
  end

  def parse_element(element)
    case element
    when EnumerationName
      Enumeration.new
    when LengthName
      Length.new
    when PatternName
      Pattern.new
    when MaxLengthName
      MaxLength.new
    when MinLengthName
      MinLength.new
    end
  end

  def parse_attr(attr, value)
    case attr
    when BaseAttrName
      @base = value
    end
  end

private

  def check_restriction(value)
    @enumeration.empty? or @enumeration.include?(value)
  end

  def check_length(value)
    @length.nil? or value.size == @length
  end

  def check_maxlength(value)
    @maxlength.nil? or value.size <= @maxlength
  end

  def check_minlength(value)
    @minlength.nil? or value.size >= @minlength
  end

  def check_pattern(value)
    @pattern.nil? or @pattern =~ value
  end
end


end
end
