# XSD4R - Generating class definition code
# Copyright (C) 2004  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'xsd/codegen/gensupport'
require 'xsd/codegen/methoddef'


module XSD
module CodeGen


class ClassDef
  include GenSupport

  attr_accessor :name
  attr_accessor :baseclass
  attr_accessor :comment
  attr_accessor :classvar_def
  attr_accessor :classconst_def

  # Array of path
  attr_reader :requirepath
  # Array of [attrname, true/false for writable, varname(optional)]
  attr_reader :attrdef
  attr_reader :methoddef

  def initialize(name)
    @name = name
    @baseclass = @comment = @classvar_def = @classconst_def = nil
    @requirepath = []
    @attrdef = []
    @methoddef = []
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
    if @classvar_def
      spacer = true
      buf << dump_class_static(@classvar_def)
    end
    if @classconst_def
      buf << dump_emptyline if spacer
      spacer = true
      buf << dump_class_static(@classconst_def)
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

  def dump_emptyline
    "\n"
  end

  def dump_requirepath
    format(
      @requirepath.sort.collect { |path|
        %Q(require "#{path}")
      }.join("\n")
    )
  end

  def dump_comment
    format(@comment).gsub(/^/, "# ")
  end

  def dump_package_def
    name = @name.to_s.split(/::/)
    if name.size > 1
      format(name[0..-2].collect { |ele| "module #{ele}" }.join("; ")) + "\n\n"
    else
      ""
    end
  end

  def dump_package_def_end
    name = @name.to_s.split(/::/)
    if name.size > 1
      "\n\n" + format(name[0..-2].collect { |ele| "end" }.join("; "))
    else
      ""
    end
  end

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

  def dump_class_static(str)
    format(str, 2)
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

  def dump_methods
    @methoddef.collect { |m|
      format(m.dump, 2)
    }.join("\n")
  end
end


end
end


if __FILE__ == $0
  require 'xsd/codegen/classdef'
  include XSD::CodeGen
  c = ClassDef.new("Foo::Bar::HobbitName")
  c.comment = <<__EOD__
      foo
        bar
      baz
__EOD__
  c.baseclass = String
  c.classconst_def = "                 FOO = 1"
  c.classvar_def = <<__EOD__
  \t@@foo = "var"
        @@baz = 1
__EOD__
  c.attrdef << ["Foo", true, "foo"]
  c.attrdef << "bar"
  c.attrdef << ["baz", true]
  c.attrdef << ["Foo2", true, "foo2"]
  c.attrdef << ["foo3", false, "foo3"]
  m = MethodDef.new("foo")
  m.definition = <<__EOD__
        foo.bar = 1
\tbaz.each do |ele|
\t  ele
        end
__EOD__
  c.methoddef << m
  c.methoddef << MethodDef.new("baz", "qux")
  puts c.dump
end
