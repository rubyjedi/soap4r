# encoding: UTF-8
require 'helper'
require 'soap/soap'


module SOAP


class TestNestedException < Test::Unit::TestCase
  class MyError < SOAP::Error; end

  def foo
    begin
      bar
    rescue
      raise MyError.new("foo", $!)
    end
  end

  def bar
    begin
      baz
    rescue
      raise MyError.new("bar", $!)
    end
  end

  def baz
    raise MyError.new("baz", $!)
  end

  def test_nestedexception
    begin
      foo
    rescue MyError => e
      trace = e.backtrace.find_all { |line| /test\/unit/ !~ line && /\d\z/ !~ line }
      trace = trace.map { |line| line.sub(/\A[^:]*/, '') }
      assert_equal(TOBE, trace)
    end
  end

  if (RUBY_VERSION.to_f >= 1.9)
    TOBE = [
      ":16:in `rescue in foo'",
      ":#{RESCUE_LINE_NUMBERS_FIXED ? 12 : 13}:in `foo'",
      ":34:in `test_nestedexception'",
      ":24:in `rescue in bar': bar (SOAP::TestNestedException::MyError) [NESTED]",
      ":#{RESCUE_LINE_NUMBERS_FIXED ? 20 : 21}:in `bar'",
      ":14:in `foo'",
      ":34:in `test_nestedexception'",
      ":29:in `baz': baz (SOAP::TestNestedException::MyError) [NESTED]",
      ":22:in `bar'",
      ":14:in `foo'",
      ":34:in `test_nestedexception'"
    ]  
  else
    TOBE = [
      ":16:in `foo'",
      ":34:in `test_nestedexception'",
      ":24:in `bar': bar (SOAP::TestNestedException::MyError) [NESTED]",
      ":14:in `foo'",
      ":34:in `test_nestedexception'",
      ":29:in `baz': baz (SOAP::TestNestedException::MyError) [NESTED]",
      ":22:in `bar'",
      ":14:in `foo'",
      ":34:in `test_nestedexception'",
    ]
  end
end

end
