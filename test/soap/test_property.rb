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
    @prop.add_hook("foo.bar.baz.qux") do |key, value|
      assert_equal("foo.bar.baz.qux", key)
      assert_equal(tag, value)
      tested += 1
    end
    @prop["foo.bar.baz.qux"] = tag
    assert_equal(tag, @prop["foo.bar.baz.qux"])
    assert_equal(4, tested)
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

  def test_lock
    @prop["a.a"] = nil
    @prop["a.b.c"] = 1
    @prop["b"] = false
    @prop.lock
    assert_equal(nil, @prop["a.a"])
    assert_equal(1, @prop["a.b.c"])
    assert_equal(false, @prop["b"])
    assert_raises(TypeError) do
      assert_nil(@prop["c"])
    end
    assert_raises(TypeError) do
      @prop["c"] = 2
    end
    assert_raises(TypeError) do
      @prop["a.b.R"]
    end
    assert_raises(TypeError) do
      @prop.add_hook("a.c") do
	assert(false)
      end
    end
    assert_nil(@prop["a.a"])
    @prop["a.b"] = nil
    assert_nil(@prop["a.b"])
    @prop["a.a"] = 2
    #
    @prop.unlock
    assert_nil(@prop["c"])
    @prop["c"] = 2
    assert_equal(2, @prop["c"])
    @prop["a.d.a.a"] = :foo
    assert_equal(:foo, @prop["a.d.a.a"])
    tested = false
    @prop.add_hook("a.c") do |name, value|
      assert(true)
      tested = true
    end
    @prop["a.c"] = 3
    assert(tested)
  end

  def test_hook_then_lock
    tested = false
    @prop.add_hook("a.b.c") do |name, value|
      assert_equal("a.b.c", name)
      tested = true
    end
    @prop.lock
    assert(!tested)
    @prop["a.b.c"] = 5
    assert(tested)
    assert_equal(5, @prop["a.b.c"])
    assert_raises(TypeError) do
      @prop["a.b.d"] = 5
    end
  end

  def test_lock_unlock_return
    assert_equal(@prop, @prop.lock)
    assert_equal(@prop, @prop.unlock)
  end

  def test_lock_split
    @prop["a.b.c"] = 1
    assert_instance_of(::SOAP::Property, @prop["a.b"])
    @prop["a.b.d"] = branch = ::SOAP::Property.new
    @prop["a.b.d.e"] = 2
    assert_equal(branch, @prop["a.b.d"])
    assert_equal(branch, @prop[:a][:b][:d])
    @prop.lock
    assert_raises(TypeError) do
      @prop["a.b"]
    end
    assert_raises(TypeError) do
      @prop["a"]
    end
    @prop["a.b.c"] = 2
    assert_equal(2, @prop["a.b.c"])
    assert_raises(TypeError) do
      @prop["a.b.c"] = ::SOAP::Property.new
    end
  end
end


end
