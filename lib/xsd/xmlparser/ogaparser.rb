# encoding: UTF-8
# OgaParser XML parser library.
# Copyright (C) 2015 Laurence A. Lee <rubyjedi@gmail.com>.

# This program is copyrighted free software by Laurence A. Lee.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.

require 'pp'
require 'oga'


module XSD
module XMLParser

class OgaParser < XSD::XMLParser::Parser

  def do_parse(string_or_readable)
    $stderr.puts "XSD::XMLParser::OgaParser.do_parse" if $DEBUG    
    # Oga::XML::SaxParser.new(self, string_or_readable)    
    Oga.sax_parse_xml(self, string_or_readable)
  end


  def on_element(namespace, name, attrs)
    start_element(node_name(namespace, name), attrs)
  end

  def after_element(namespace, name)
    end_element(node_name(namespace, name))
  end


  def on_cdata(t)
    characters(t)
  end
  
  def on_comment(t)
    characters(t)
  end

  def on_text(t)
    characters(t)
  end

  
  def on_xml_decl(attr_hash)
    # attr_hash['version'] = '1.0'; attr_hash['encoding'] = 'utf-8' (usually)
    # $stderr.puts "XML Document #{attr_hash['version']} in #{attr_hash['encoding']} encoding." 
  end


  private

  def node_name(namespace, name)
    namespace ? "#{namespace}:#{name}" : name.to_s
  end

  add_factory(self)

end

end
end
