# soap/property.rb: SOAP4R - Property implementation.
# Copyright (C) 2003  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


module SOAP


class Property
  def initialize
    @store = Hash.new
    @hook = Hash.new
    @locked = false
  end

  # name: a Symbol, String or an Array
  def [](name)
    referent(name_to_a(name))
  end

  # name: a Symbol, String or an Array
  # value: an Object
  def []=(name, value)
    hooks = assign(name_to_a(name), value)
    normalized_name = normalize_name(name)
    hooks.each do |hook|
      hook.call(normalized_name, value)
    end
    value
  end

  # name: a Symbol, String or an Array
  # hook: block which will be called with 2 args, name and value
  def add_hook(name, &hook)
    assign_hook(name_to_a(name), &hook)
  end

  # returns: downcase symbol
  def keys
    @store.keys
  end

  def lock
    each_key do |key|
      key.lock
    end
    @locked = true
    self
  end

  def unlock
    @locked = false
    each_key do |key|
      key.unlock
    end
    self
  end

protected

  def referent(ary)
    key, rest = location_pair(ary)
    if rest.empty?
      check_lock(key)
      @store[key]
    else
      deref_key(key).referent(rest)
    end
  end

  def assign(ary, value)
    key, rest = location_pair(ary)
    if rest.empty?
      check_lock(key)
      @store[key] = value
      local_hook(key)
    else
      local_hook(key) + deref_key(key).assign(rest, value)
    end
  end

  def assign_hook(ary, &hook)
    key, rest = location_pair(ary)
    if rest.empty?
      check_lock(key)
      @store[key] ||= nil
      (@hook[key] ||= []) << hook
    else
      deref_key(key).assign_hook(rest, &hook)
    end
  end

private

  def each_key
    @store.each do |key, value|
      if value.is_a?(::SOAP::Property)
	yield(value)
      end
    end
  end

  def deref_key(key)
    check_lock(key)
    ref = @store[key] ||= self.class.new
    unless ref.is_a?(::SOAP::Property)
      raise ArgumentError.new("key `#{key}' already defined as a value")
    end
    ref
  end

  def check_lock(key)
    if @locked and !@store.key?(key)
      raise TypeError.new("cannot add any key to locked property")
    end
  end

  NO_HOOK = [].freeze
  def local_hook(key)
    @hook[key] || NO_HOOK
  end

  def name_to_a(name)
    case name
    when Symbol
      [name]
    when String
      name.split(/\./)
    when Array
      name
    else
      raise ArgumentError.new("Unknown name #{name}(#{name.class})")
    end
  end

  def location_pair(ary)
    name, *rest = *ary
    key = to_key(name)
    return key, rest
  end

  def normalize_name(name)
    name_to_a(name).collect { |key| to_key(key) }.join('.')
  end

  def to_key(name)
    name.to_s.downcase.intern
  end
end


end
