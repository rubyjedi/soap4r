# SOAP4R - Mapping registry.
# Copyright (C) 2000-2003, 2006  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/baseData'
require 'soap/mapping/mapping'
require 'soap/mapping/encodedregistry.rb'


module SOAP


module Marshallable
  # @@type_ns = Mapping::RubyCustomTypeNamespace
end


module Mapping

  
module MappedException; end


RubyTypeName = XSD::QName.new(RubyTypeInstanceNamespace, 'rubyType')
RubyExtendName = XSD::QName.new(RubyTypeInstanceNamespace, 'extends')
RubyIVarName = XSD::QName.new(RubyTypeInstanceNamespace, 'ivars')


# For anyType object: SOAP::Mapping::Object not ::Object
class Object; include Marshallable
  def initialize
    @__xmlele_type = {}
    @__xmlele = []
    @__xmlattr = {}
  end

  def inspect
    sprintf("#<%s:0x%x%s>", self.class.name, __id__,
      @__xmlele.collect { |name, value| " #{name}=#{value.inspect}" }.join)
  end

  def __xmlattr
    @__xmlattr
  end

  def __xmlele
    @__xmlele
  end

  def [](qname)
    unless qname.is_a?(XSD::QName)
      qname = XSD::QName.new(nil, qname)
    end
    @__xmlele.each do |k, v|
      return v if k == qname
    end
    # fallback
    @__xmlele.each do |k, v|
      return v if k.name == qname.name
    end
    nil
  end

  def []=(qname, value)
    unless qname.is_a?(XSD::QName)
      qname = XSD::QName.new(nil, qname)
    end
    found = false
    @__xmlele.each do |pair|
      if pair[0] == qname
        found = true
        pair[1] = value
      end
    end
    unless found
      __define_attr_accessor(qname)
      @__xmlele << [qname, value]
    end
    @__xmlele_type[qname] = :single
  end

  def __add_xmlele_value(qname, value)
    found = false
    @__xmlele.map! do |k, v|
      if k == qname
        found = true
        [k, __set_xmlele_value(k, v, value)]
      else
        [k, v]
      end
    end
    unless found
      __define_attr_accessor(qname)
      @__xmlele << [qname, value]
      @__xmlele_type[qname] = :single
    end
    value
  end

private

  # Mapping.define_attr_accessor calls define_method with proc and it exhausts
  # much memory for each singleton Object.  just instance_eval instead of it.
  def __define_attr_accessor(qname)
    # untaint depends GenSupport.safemethodname
    name = XSD::CodeGen::GenSupport.safemethodname(qname.name).untaint
    # untaint depends QName#dump
    qnamedump = qname.dump.untaint
    unless self.respond_to?(name)
      instance_eval <<-EOS
        def #{name}
          self[#{qnamedump}]
        end
      EOS
    end
    unless self.respond_to?(name + "=")
      instance_eval <<-EOS
        def #{name}=(value)
          self[#{qnamedump}] = value
        end
      EOS
    end
  end

  def __set_xmlele_value(key, org, value)
    case @__xmlele_type[key]
    when :multi
      org << value
      org
    when :single
      @__xmlele_type[key] = :multi
      [org, value]
    else
      raise RuntimeError.new("unknown type")
    end
  end
end


class MappingError < Error; end


module RegistrySupport
  def initialize
    super()
  end
  
  def add_attributes2soap(obj, ele)
    definition = Mapping.schema_definition_classdef(obj.class)
    if definition && attributes = definition.attributes
      attributes.each do |qname, param|
        at = obj.__send__(
          XSD::CodeGen::GenSupport.safemethodname('xmlattr_' + qname.name))
        ele.extraattr[qname] = at
      end
    elsif obj.respond_to?(:__xmlattr)
      obj.__xmlattr.each do |key, value|
        ele.extraattr[key] = value
      end
    end
  end

  def base2soap(obj, type, qualified = nil)
    soap_obj = nil
    if type <= XSD::XSDString
      str = XSD::Charset.encoding_conv(obj.to_s,
        Thread.current[:SOAPMapping][:ExternalCES], XSD::Charset.encoding)
      soap_obj = type.new(str)
    else
      soap_obj = type.new(obj)
    end
    soap_obj.qualified = qualified
    soap_obj
  end
end


Registry = EncodedRegistry
DefaultRegistry = EncodedRegistry.new
RubyOriginalRegistry = EncodedRegistry.new(:allow_original_mapping => true)


end
end
