# soap/property.rb: SOAP4R - Property definition.
# Copyright (C) 2000, 2001, 2002, 2003  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


module SOAP


class Property
  def initialize
    @store = Hash.new
  end

  # name: a Symbol, String or an Array
  def [](name)
    referent(name_to_a(name))
  end

  # name: a Symbol, String or an Array
  # value: an Object
  def []=(name, value)
    assign(name_to_a(name), value)
  end

private

  def referent(ary)
    if ary.size == 1
      @store[to_key(ary[0])] ||= self.class.new
    else
      name, rest = ary
      ref = (@store[to_key(name)] ||= self.class.new)
      ref[rest] ||= self.class.new
    end
  end

  def assign(ary, value)
    if ary.size == 1
      @store[to_key(ary[0])] = value
    else
      name = ary.pop
      referent(ary)[name.intern] = value
    end
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
