# XSD4R - Generating method definition code
# Copyright (C) 2004  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'xsd/codegen/gensupport'


module XSD
module CodeGen


class MethodDef
  include GenSupport

  attr_reader :name
  attr_reader :params
  attr_accessor :comment
  attr_accessor :definition

  def initialize(name, *params)
    @name = name
    @params = params
    @comment = nil
    @definition = nil
  end

  def dump
    @buf = ""
    dump_comment
    dump_method_def
    dump_definition
    dump_method_def_end
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

  def dump_method_def
    if @params.empty?
      @buf << format("def #{@name}")
    else
      @buf << format("def #{@name}(#{@params.join(", ")})")
    end
  end

  def dump_method_def_end
    @buf << format("end")
  end

  def dump_definition
    @buf << format(@definition, 2) if @definition
  end
end


end
end
