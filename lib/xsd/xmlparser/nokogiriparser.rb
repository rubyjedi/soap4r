# encoding: UTF-8
# XSD4R - Nokogiri XML parser library.
# Copyright (C) 2015 Laurence A. Lee <rubyjedi@gmail.com>

# This program is copyrighted free software by Laurence A. Lee.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.

require 'nokogiri'

module XSD
module XMLParser

class NokogiriParser < XSD::XMLParser::Parser
  def do_parse(string_or_readable)
    $stderr.puts "XSD::XMLParser::NokogiriParser.do_parse" if $DEBUG    
    handler = NokoDocHandler.new(self)
    parser = Nokogiri::XML::SAX::Parser.new(handler)    
    parser.parse(string_or_readable)
  end

  add_factory(self)
  
  public :start_element
  public :end_element
  public :characters
  public :xmldecl_encoding=
end


class NokoDocHandler < Nokogiri::XML::SAX::Document
  def initialize(owner)
    @owner = (owner)
  end

  def xmldecl(version, encoding, standalone)
    @owner.xmldecl_encoding= encoding
  end

  def start_element(name,attrs)
    @owner.start_element(name,Hash[*attrs.flatten])
  end
  
  def end_element(name)
    @owner.end_element(name)
  end

  def cdata_block(t)
    @owner.characters(t)
  end
  
  def characters(t)
    @owner.characters(t)
  end
  
  def comment(t)
    @owner.characters(t)
  end
end


end
end
