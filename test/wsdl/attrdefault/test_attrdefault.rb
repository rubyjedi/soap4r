# encoding: UTF-8
require 'helper'
require 'testutil'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'


module WSDL; module Attrdefault


# Regression test for a fork-sourced fix, not yet merged upstream: see
# attrdefault.wsdl for the schema this exercises. Today, `fixed` and
# `default` XSD attribute constraints are parsed but silently discarded
# by classDefCreator.rb's define_attribute, so every assertion below that
# depends on them will FAIL (the class itself loads fine, unlike the
# dupinitparams case -- this is a missing feature, not a crash). It will
# pass once define_attribute honors attribute.fixed/attribute.default
# (nedap/soap4r commit 0739995).
class TestAttrDefault < Test::Unit::TestCase
  DIR = File.dirname(File.expand_path(__FILE__))

  def teardown
    unless $DEBUG
      File.unlink(pathname('attrdefault.rb')) if File.file?(pathname('attrdefault.rb'))
    end
  end

  def pathname(filename)
    File.join(DIR, filename)
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("attrdefault.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
    gen.opt['force'] = true
    gen.run
  end

  def test_fixed_attribute_always_returns_fixed_value
    setup_classdef
    TestUtil.require(DIR, 'attrdefault.rb')
    obj = Attrdefault_type.new
    assert_equal("1.0", obj.xmlattr_version)
  end

  def test_fixed_attribute_has_no_setter
    setup_classdef
    TestUtil.require(DIR, 'attrdefault.rb')
    obj = Attrdefault_type.new
    assert_equal(false, obj.respond_to?(:xmlattr_version=))
  end

  def test_default_attribute_falls_back_when_unset
    setup_classdef
    TestUtil.require(DIR, 'attrdefault.rb')
    obj = Attrdefault_type.new
    assert_equal("en", obj.xmlattr_lang)
  end

  def test_default_attribute_setter_still_overrides
    setup_classdef
    TestUtil.require(DIR, 'attrdefault.rb')
    obj = Attrdefault_type.new
    obj.xmlattr_lang = "fr"
    assert_equal("fr", obj.xmlattr_lang)
  end

  def test_plain_attribute_unaffected
    setup_classdef
    TestUtil.require(DIR, 'attrdefault.rb')
    obj = Attrdefault_type.new
    assert_nil(obj.xmlattr_plain)
    obj.xmlattr_plain = "x"
    assert_equal("x", obj.xmlattr_plain)
  end
end


end; end
