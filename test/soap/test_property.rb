require 'test/unit'
require 'soap/property'


module SOAP


class TestProperty < Test::Unit::TestCase
  def setup
    @prop = ::SOAP::Property.new
  end

  def teardown
    # Nothing to do.
  end

  def test_initialize
    prop = ::SOAP::Property.new
    # store is empty
    assert_nil(prop["a"])
    # does hook work?
    assert_equal(1, prop["a"] = 1)
  end

  def test_aref
    # name_to_a
    assert_nil(@prop[:foo])
    assert_nil(@prop["foo"])
    assert_nil(@prop[[:foo]])
    assert_nil(@prop[["foo"]])
    assert_raises(ArgumentError) do
      @prop[1]
    end
    @prop[:foo] = :foo
    assert_equal(:foo, @prop[:foo])
    assert_equal(:foo, @prop["foo"])
    assert_equal(:foo, @prop[[:foo]])
    assert_equal(:foo, @prop[["foo"]])
  end

  def test_referent
    # referent(1)
    assert_nil(@prop["foo.foo"])
    assert_nil(@prop[["foo", "foo"]])
    assert_nil(@prop[["foo", :foo]])
    @prop["foo.foo"] = :foo
    assert_equal(:foo, @prop["foo.foo"])
    assert_equal(:foo, @prop[["foo", "foo"]])
    assert_equal(:foo, @prop[[:foo, "foo"]])
    # referent(2)
    @prop["bar.bar.bar"] = :bar
    assert_equal(:bar, @prop["bar.bar.bar"])
    assert_equal(:bar, @prop[["bar", "bar", "bar"]])
    assert_equal(:bar, @prop[[:bar, "bar", :bar]])
  end

  def test_to_key_and_deref
    @prop["foo.foo"] = :foo
    assert_equal(:foo, @prop["fOo.FoO"])
    assert_equal(:foo, @prop[[:fOO, :FOO]])
    assert_equal(:foo, @prop[["FoO", :Foo]])
    # deref_key negative test
    assert_raises(ArgumentError) do
      @prop["baz"] = 1
      @prop["baz.qux"] = 2
    end
  end

  def test_value_hook
    tag = Object.new
    tested = false
    @prop.add_hook("FOO.BAR.BAZ") do |key, value|
      assert_equal("foo.bar.baz", key)
      assert_equal(tag, value)
      tested = true
    end
    @prop["Foo.baR.baZ"] = tag
    assert_equal(tag, @prop["foo.bar.baz"])
    assert(tested)
    @prop["foo.bar"] = 1	# unhook the above block
    assert_equal(1, @prop["foo.bar"])
  end

  def test_key_hook
    tag = Object.new
    tested = 0
    @prop.add_hook("foo") do |key, value|
      assert_equal("foo.bar.baz.qux", key)
      assert_equal(tag, value)
      tested += 1
    end
    @prop.add_hook("foo.bar") do |key, value|
      assert_equal("foo.bar.baz.qux", key)
      assert_equal(tag, value)
      tested += 1
    end
    @prop.add_hook("foo.bar.baz") do |key, value|
      assert_equal("foo.bar.baz.qux", key)
      assert_equal(tag, value)
      tested += 1
    end
    @prop["foo.bar.baz.qux"] = tag
    assert_equal(tag, @prop["foo.bar.baz.qux"])
    assert_equal(3, tested)
  end

  def test_keys
    assert(@prop.keys.empty?)
    @prop["foo"] = 1
    @prop["bar"]
    @prop["BAz"] = 2
    assert_equal(2, @prop.keys.size)
    assert(@prop.keys.member?(:foo))
    assert(@prop.keys.member?(:baz))
    #
    assert_nil(@prop["a"])
    @prop["a.a"] = 1
    assert_instance_of(::SOAP::Property, @prop["a"])
    @prop["a.b"] = 1
    @prop["a.c"] = 1
    assert_equal(3, @prop["a"].keys.size)
    assert(@prop["a"].keys.member?(:a))
    assert(@prop["a"].keys.member?(:b))
    assert(@prop["a"].keys.member?(:c))
  end
end


end
