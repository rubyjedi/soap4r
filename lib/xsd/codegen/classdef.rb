# XSD4R - Generation class definition code
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

  attr_reader :methoddef

  def initialize(name)
    @name = name
    @baseclass = @comment = nil
    @classvar_def = @classconst_def = nil
    @methoddef = []
  end

  def self.safename(name)
    safename = name.scan(/[a-zA-Z0-9_]+/).collect { |ele|
      GenSupport.capitalize(ele)
    }.join
    unless /^[A-Z]/ =~ safename
      safename = "C_#{safename}"
    end
    safename
  end

  def dump
    @buf = ""
    dump_comment
    dump_class_def
    spacer = false
    if @classvar_def
      spacer = true
      dump_class_static(@classvar_def)
    end
    if @classconst_def
      dump_emptyline if spacer
      spacer = true
      dump_class_static(@classconst_def)
    end
    unless @methoddef.empty?
      dump_emptyline if spacer
      spacer = true
      dump_methods
    end
    dump_class_def_end
    @buf
  end

private

  def dump_emptyline
    @buf << "\n"
  end

  def dump_comment
    if @comment
      @buf << format(@comment)
    end
  end

  def dump_class_def
    if @baseclass
      @buf << format("class #{@name} < #{@baseclass}")
    else
      @buf << format("class #{@name}")
    end
  end

  def dump_class_def_end
    @buf << format("end")
  end

  def dump_class_static(str)
    @buf << format(str, 2)
  end

  def dump_methods
    @buf << @methoddef.collect { |methoddef|
      format(methoddef.dump, 2)
    }.join("\n")
  end
end


end
end


if __FILE__ == $0
  require 'xsd/codegen/classdef'
  include XSD::CodeGen
  c = ClassDef.new("HobbitName")
  c.baseclass = String
  c.classconst_def = "                 FOO = 1"

  c.classvar_def = <<__EOD__
  \t@@foo = var
        @@baz = 1
__EOD__
  m = MethodDef.new("foo")
  m.definition = <<__EOD__
        foo.bar = 1
\tbaz.each do |ele|
\t  ele.1
        end
__EOD__
  c.methoddef << m
  c.methoddef << MethodDef.new("baz", "qux")
  puts c.dump
end
