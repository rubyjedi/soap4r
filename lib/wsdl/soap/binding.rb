# encoding: UTF-8
# WSDL4R - WSDL SOAP binding definition.
# Copyright (C) 2000-2007  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/info'


module WSDL
module SOAP


class Binding < Info
  attr_reader :style
  attr_reader :transport
  # Set by WSDL::Binding#parse_element (lib/wsdl/binding.rb) based on
  # whether the <soap:binding> or <soap12:binding> element matched --
  # this class itself is identical either way, only the WSDL author's
  # chosen namespace differs, so that's the one place that actually knows
  # which one it was.
  attr_accessor :soap12

  def initialize
    super
    @style = nil
    @transport = nil
    @soap12 = false
  end

  def parse_element(element)
    nil
  end

  def parse_attr(attr, value)
    case attr
    when StyleAttrName
      if ["document", "rpc"].include?(value.source)
	@style = value.source.intern
      else
	raise Parser::AttributeConstraintError.new(
          "Unexpected value #{ value }.")
      end
    when TransportAttrName
      @transport = value.source
    else
      nil
    end
  end
end


end
end
