# encoding: UTF-8
# XSD4R - Charset handling with iconv.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.

require 'iconv' unless ''.respond_to? :encode

module XSD


class IconvCharset
  def self.safe_iconv(to, from, str)
    return str.encode(to, from, :invalid => :replace, :undef => :replace, :replace => '?') if ''.respond_to? :encode
    iconv = Iconv.new(to, from)
    out = ""
    begin
      out << iconv.iconv(str)
    rescue Iconv::IllegalSequence => e
      out << e.success
      ch, str = e.failed.split(//, 2)
      out << '?'
      warn("Failed to convert #{ch}")
      retry
    end
    return out
  end
end


end
