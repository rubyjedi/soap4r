# encoding: UTF-8
# XSD4R - REXMLParser XML parser library.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'rexml/streamlistener'
require 'rexml/document'


module XSD
module XMLParser


class REXMLParser < XSD::XMLParser::Parser
  include REXML::StreamListener

  def do_parse(string_or_readable)
    $stderr.puts "XSD::XMLParser::REXMLParser.do_parse" if $DEBUG    
    REXML::Document.parse_stream(string_or_readable, self)
  end

  def epilogue
  end

  def tag_start(name, attrs)
    start_element(name, attrs)
  end

  def tag_end(name)
    end_element(name)
  end

  def text(text)
    characters(text)
  end

  def cdata(content)
    characters(content)
  end

  def xmldecl(version, encoding, standalone)
    send :xmldecl_encoding=, encoding
  end

  add_factory(self)
end


end
end
