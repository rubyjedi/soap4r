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
    @element_stack = []
    begin
      require 'htmlentities' # Used to unescape html-escaped chars, if available
      @decoder = ::HTMLEntities.new(:expanded)
    rescue LoadError
      @decoder = nil
    end

    string = string_or_readable.respond_to?(:read) ? string_or_readable.read : StringIO.new(string_or_readable)
    if @decoder.nil?
      # Use the built-in conversion with Ox.
      ::Ox.sax_parse(self, string, {:symbolize=> false, :convert_special=> true, :skip=> :skip_return} )
    else
      # Use HTMLEntities Decoder.  Leave the special-character conversion alone and let HTMLEntities decode it for us.
      ::Ox.sax_parse(self, string, {})
    end        
  end


  alias_method :base_start_element, :start_element
  def start_element(n)
    # $stderr.puts "OxParser.start_element INVOKED [#{n}]"
    @element_stack.push n.to_s # Push the Element Name
    @element_stack.push Hash.new
  end

  alias_method :base_end_element, :end_element
  def end_element(n)
    # $stderr.puts "OxParser.end_element INVOKED [#{n}]"
    if @element_stack[-2].to_s == n.to_s
      attr_hash = @element_stack.pop
      attr_key  = @element_stack.pop
    else
      $stderr.puts "!!!! OxParser.end_element FAILED TO FIND STACK PAIR [#{n}] IN STACK [#{PP.pp(@element_stack,'')}]"
    end
    base_end_element(n.to_s)
  end


  def text(t)
    @decoder.nil? ? characters(t) : characters(@decoder.decode(t))
  end

  def cdata(t)
    @decoder.nil? ? characters(t) : characters(@decoder.decode(t))
  end
  
  def comment(t)
    @decoder.nil? ? characters(t) : characters(@decoder.decode(t))
  end


  def instruct(n)
    # Do nothing. This is the outer "XML" tag.
  end

  def end_instruct(n)
    # Do nothing.
  end


  def attr(key,val)
    return if @element_stack[-1].nil?

    attr_hash = @element_stack[-1]
    attr_hash[key.to_s] = val
  end
  
  def attrs_done
    attr_hash = @element_stack[-1]
    name = @element_stack[-2]

    base_start_element(name, attr_hash) unless attr_hash.nil?
  end

  add_factory(self)
end

end
end
