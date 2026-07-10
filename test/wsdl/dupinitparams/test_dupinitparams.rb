# encoding: UTF-8
require 'helper'
require 'testutil'
require 'wsdl/parser'
require 'wsdl/soap/wsdl2ruby'


module WSDL; module Dupinitparams


# Regression test for a fork-inspired fix: see dupinitparams.wsdl for the
# shape of the bug (duplicate initialize params generated when the same
# element name appears twice in one complexType's content). Before the
# fix, this crashed with a SyntaxError while requiring the generated class
# file, since `def initialize(shared = nil, shared = nil)` cannot be
# parsed by Ruby (see krebbl/soap4r commit 381b9f1, "fix duplicate
# initialize params issue"). Rather than adopting that fix as-is -- a
# plain `init_params.uniq`, which would silently wire both occurrences of
# "shared" onto a single @shared ivar, discarding one of the two values --
# the second occurrence is instead renamed "shared_2", the same way
# classDefCreator.rb already disambiguates colliding attribute constants
# in define_attribute (see its own `const[constname] += 1` suffixing).
# That keeps both values independently addressable instead of silently
# merging them.
class TestDupInitParams < Test::Unit::TestCase
  DIR = File.dirname(File.expand_path(__FILE__))

  def teardown
    unless $DEBUG
      File.unlink(pathname('dup.rb')) if File.file?(pathname('dup.rb'))
    end
  end

  def pathname(filename)
    File.join(DIR, filename)
  end

  def setup_classdef
    gen = WSDL::SOAP::WSDL2Ruby.new
    gen.location = pathname("dupinitparams.wsdl")
    gen.basedir = DIR
    gen.logger.level = Logger::FATAL
    gen.opt['classdef'] = nil
    gen.opt['module_path'] = self.class.to_s.sub(/::[^:]+$/, '')
    gen.opt['force'] = true
    gen.run
  end

  def test_generated_class_keeps_both_occurrences_independently_addressable
    setup_classdef
    TestUtil.require(DIR, 'dup.rb')
    obj = Dup_type.new("hello", "world")
    assert_equal("hello", obj.shared)
    assert_equal("world", obj.shared_2)
  end
end


end; end
