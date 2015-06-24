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
end


class NokoDocHandler < Nokogiri::XML::SAX::Document
  def initialize(owner)
    @owner = (owner)
  end

  def start_element(name,attrs)
    attr_hash = Hash.new
    attrs.each do |kv_array|
      attr_hash[kv_array[0]] = kv_array[1]
    end
    @owner.send(:start_element, name, attr_hash)
  end
  
  def end_element(name)
    @owner.send(:end_element, name)
  end


  def cdata_block(t)
    @owner.send(:characters, t)
  end
  
  def characters(t)
    @owner.send(:characters, t)
  end
  
  def comment(t)
    @owner.send(:characters,t)
  end
end


end
end
