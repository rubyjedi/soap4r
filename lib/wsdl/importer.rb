# WSDL4R - WSDL importer library.
# Copyright (C) 2003, 2005  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'wsdl/xmlSchema/importer'
require 'wsdl/parser'


module WSDL


class Importer < WSDL::XMLSchema::Importer
  def self.import(location)
    new.import(location)
  end

private

  def parse(content)
    begin
      WSDL::Parser.new({}).parse(content)
    rescue WSDL::Parser::ParseError
      super(content)
    end
  end

end


end
