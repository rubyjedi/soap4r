# XSD4R - Generating class definition code
# Copyright (C) 2004  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'xsd/codegen/gensupport'
require 'xsd/codegen/moduledef'
require 'xsd/codegen/methoddef'


module XSD
module CodeGen


class ClassDef < ModuleDef
  include GenSupport

  attr_accessor :comment

  def initialize(name, baseclass = nil)
    super(name)
    @baseclass = baseclass
    @comment = nil
    @classvar = []
    @attrdef = []
  end

  def defclassvar(var, value)
    var = var.sub(/\A@@/, "")
    raise ArgumentError, var unless safevarname?(var)
    @classvar << [var, value]
  end

  def defattr(attrname, writable = true, varname = nil)
    raise ArgumentError, varname || attrname unless safevarname?(varname || attrname)
    @attrdef << [attrname, writable, varname]
  end

  def dump
    buf = ""
    unless @requirepath.empty?
      buf << dump_requirepath 
    end
    buf << dump_emptyline unless buf.empty?
    buf << dump_package_def
    buf << dump_comment if @comment
    buf << dump_class_def
    spacer = false
    unless @classvar.empty?
      spacer = true
      buf << dump_classvar
    end
    unless @const.empty?
      buf << dump_emptyline if spacer
      spacer = true
      buf << dump_const
    end
    unless @attrdef.empty?
      buf << dump_emptyline if spacer
      spacer = true
      buf << dump_attributes
    end
    unless @methoddef.empty?
      buf << dump_emptyline if spacer
      spacer = true
      buf << dump_methods
    end
    buf << dump_class_def_end
    buf << dump_package_def_end
    buf
  end

private

  def dump_class_def
    name = @name.to_s.split(/::/)
    if @baseclass
      format("class #{name.last} < #{@baseclass}")
    else
      format("class #{name.last}")
    end
  end

  def dump_class_def_end
    str = format("end")
  end

  def dump_classvar
    dump_static(
      @classvar.sort.collect { |var, value|
        %Q(@@#{var.sub(/^@@/, "")} = #{dump_value(value)})
      }.join("\n")
    )
  end

  def dump_attributes
    str = ""
    @attrdef.each do |attrname, writable, varname|
      varname ||= attrname
      if attrname == varname
        str << format(dump_accessor(attrname, writable), 2)
      end
    end
    @attrdef.each do |attrname, writable, varname|
      varname ||= attrname
      if attrname != varname
        str << "\n" unless str.empty?
        str << format(dump_attribute(attrname, writable, varname), 2)
      end
    end
    str
  end

  def dump_accessor(attrname, writable)
    if writable
      "attr_accessor :#{attrname}"
    else
      "attr_reader :#{attrname}"
    end
  end

  def dump_attribute(attrname, writable, varname)
    str = nil
    mr = MethodDef.new(attrname)
    mr.definition = "@#{varname}"
    str = mr.dump
    if writable
      mw = MethodDef.new(attrname + "=", varname)
      mw.definition = "@#{varname} = #{varname}"
      str << "\n" + mw.dump
    end
    str
  end
end


end
end


if __FILE__ == $0
  require 'xsd/codegen/classdef'
  include XSD::CodeGen
  c = ClassDef.new("Foo::Bar::HobbitName", String)
  c.defrequire("foo/bar")
  c.comment = <<__EOD__
      foo
        bar
      baz
__EOD__
  c.defconst("FOO", 1)
  c.defclassvar("@@foo", "var")
  c.defclassvar("baz", "1")
  c.defattr("Foo", true, "foo")
  c.defattr("bar")
  c.defattr("baz", true)
  c.defattr("Foo2", true, "foo2")
  c.defattr("foo3", false, "foo3")
  c.defmethod("foo") do
    <<-EOD
        foo.bar = 1
\tbaz.each do |ele|
\t  ele
        end
    EOD
  end
  c.defmethod("baz", "qux") do
    <<-EOD
      [1, 2, 3].each do |i|
        p i
      end
    EOD
  end

  puts c.dump
end
