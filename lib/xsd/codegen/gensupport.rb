# XSD4R - Code generation support
# Copyright (C) 2004  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


module XSD
module CodeGen


module GenSupport
  def capitalize(target)
    target.sub(/^([a-z])/) { $1.tr!('[a-z]', '[A-Z]') }
  end
  module_function :capitalize

  def format(str, indent = nil)
    str = trim_eol(str)
    str = trim_indent(str)
    if indent
      str.gsub(/^/, " " * indent)
    else
      str
    end
  end

private

  def trim_eol(str)
    str.collect { |line|
      line.sub(/\r?\n$/, "") + "\n"
    }.join
  end

  def trim_indent(str)
    indent = nil
    str.each do |line|
      head = untab(line).index(/\S/)
      if indent.nil? or head < indent
        indent = head
      end
    end
    return str unless indent
    str.collect { |line|
      untab(line).sub(/^ {0,#{indent}}/, "")
    }.join
  end

  def untab(line, ts = 8)
    while pos = line.index(/\t/)
      line = line.sub(/\t/, " " * (ts - (pos % ts)))
    end
    line
  end
end


end
end
