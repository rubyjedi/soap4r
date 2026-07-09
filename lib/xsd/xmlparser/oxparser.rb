# encoding: UTF-8
# XSD4R - OXParser XML parser library.
# Copyright (C) 2015 Laurence A. Lee <rubyjedi@gmail.com>.

# This program is copyrighted free software by Laurence A. Lee.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.

require 'ox'

module XSD
module XMLParser

class OxParser < XSD::XMLParser::Parser
  def do_parse(string_or_readable)
    $stderr.puts "XSD::XMLParser::OxParser.do_parse" if $DEBUG
    begin
      require 'htmlentities' # Used to unescape html-escaped chars, if available
      @decoder = ::HTMLEntities.new(:expanded)
    rescue LoadError
      @decoder = nil
    end
    handler = OxDocHandler.new(self, @decoder)

    string = string_or_readable.respond_to?(:read) ? string_or_readable.read : StringIO.new(string_or_readable)
    if @decoder.nil?
      # Use the built-in conversion with Ox.
      ::Ox.sax_parse(handler, string, {:symbolize=> false, :convert_special=> true, :skip=> :skip_return} )
    else
      # Use HTMLEntities Decoder.  Leave the special-character conversion alone and let HTMLEntities decode it for us.
      ::Ox.sax_parse(handler, string, {:skip=> :skip_none})
    end
  end
  
  public :start_element
  public :end_element
  public :characters
  public :xmldecl_encoding=

  add_factory(self)
end

class OxDocHandler
  
  def initialize(owner, decoder)
    @owner = owner
    @decoder = decoder
    reset_for_next_element
  end
  
  def attr(key, val)
    @attr_hash[key.to_s]=val
  end
  
  def attrs_done
    unless @element_name.nil?
      @owner.start_element(@element_name, @attr_hash) 
      reset_for_next_element
    end
  end
  
  def start_element(name)
    @element_name = name.to_s
  end
  
  def end_element(name)
    name = name.to_s
    @owner.end_element(name) unless @element_name.nil?
  end

  def text(t)
    @decoder.nil? ? @owner.characters(t) : @owner.characters(@decoder.decode(t))
  end
  
  alias_method :cdata, :text


  def instruct(n)
    # Set @element_name to nil so DocHandler does nothing with attrs or element name. This is the outer "XML" tag.
    @element_name = nil
  end

  def end_instruct(n)
    @owner.xmldecl_encoding= @attr_hash['encoding']
    reset_for_next_element
  end

  private
  
  def reset_for_next_element
    @attr_hash = {}
    @element_name = ""
  end  
end

end
end
