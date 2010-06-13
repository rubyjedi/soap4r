require File.expand_path(File.dirname(__FILE__) + '/../helper.rb')
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
      ":15:in `rescue in foo'",
      ":12:in `foo'",
      ":33:in `test_nestedexception'",
      ":23:in `rescue in bar': bar (SOAP::TestNestedException::MyError) [NESTED]",
      ":20:in `bar'",
      ":13:in `foo'",
      ":33:in `test_nestedexception'",
      ":28:in `baz': baz (SOAP::TestNestedException::MyError) [NESTED]",
      ":21:in `bar'",
      ":13:in `foo'",
      ":33:in `test_nestedexception'"
    ]  
  else
    TOBE = [
      ":15:in `foo'",
      ":33:in `test_nestedexception'",
      ":23:in `bar': bar (SOAP::TestNestedException::MyError) [NESTED]",
      ":13:in `foo'",
      ":33:in `test_nestedexception'",
      ":28:in `baz': baz (SOAP::TestNestedException::MyError) [NESTED]",
      ":21:in `bar'",
      ":13:in `foo'",
      ":33:in `test_nestedexception'",
    ]
  end
end

end
