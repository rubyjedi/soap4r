# soap/property.rb: SOAP4R - Property definition.
# Copyright (C) 2000, 2001, 2002, 2003  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


module SOAP


class Property
  def initialize
    @store = Hash.new
    @hook = Hash.new
  end

  # name: a Symbol, String or an Array
  def [](name)
    referent(name_to_a(name))
  end

  # name: a Symbol, String or an Array
  # value: an Object
  def []=(name, value)
    hooks = assign(name_to_a(name), value)
    hooks.each do |hook|
      hook.call(name, value)
    end
    value
  end

  def add_hook(name, &hook)
    assign_hook(name_to_a(name), &hook)
  end

protected

  def referent(ary)
    key = to_key(ary[0])
    if ary.size == 1
      @store[key]
    else
      deref_key(key).referent(ary[1..-1])
    end
  end

  def assign(ary, value)
    key = to_key(ary[0])
    if ary.size == 1
      @store[key] = value
      local_hook(key)
    else
      local_hook(key) + deref_key(key).assign(ary[1..-1], value)
    end
  end

  def assign_hook(ary, &hook)
    key = to_key(ary[0])
    if ary.size == 1
      (@hook[key] ||= []) << hook
    else
      deref_key(key).assign_hook(ary[1..-1], &hook)
    end
  end

private

  def deref_key(key)
    @store[key] ||= self.class.new
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

  def to_key(name)
    name.to_s.downcase.intern
  end
end


end
