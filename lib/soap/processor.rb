=begin
SOAP4R - marshal/unmarshal interface.
Copyright (C) 2000, 2001, 2003  NAKAMURA, Hiroshi.

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PRATICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 675 Mass
Ave, Cambridge, MA 02139, USA.
=end

require 'soap/soap'
require 'soap/element'
require 'soap/XMLSchemaDatatypes'
require 'soap/parser'
require 'soap/generator'
require 'soap/charset'

require 'soap/encodingStyleHandlerDynamic'
require 'soap/encodingStyleHandlerLiteral'
require 'soap/encodingStyleHandlerASPDotNet'


# Try to load XML processor.
loaded = false
[
  'soap/xmlscanner',
  'soap/xmlparser',
  'soap/rexmlparser',
  'soap/nqxmlparser',
].each do |lib|
  begin
    require lib
    loaded = true
    break
  rescue LoadError
  end
end
unless loaded
  raise RuntimeError.new("XML processor module not found.")
end


module SOAP


module Processor
  @@default_parser_option = {}

  class << self
  public

    def marshal(header, body, opt = {}, io = nil)
      env = SOAPEnvelope.new(header, body)
      generator = create_generator(opt)
      generator.generate(env, io)
    end

    def unmarshal(stream, opt = {})
      parser = create_parser(opt)
      env = parser.parse(stream)
      return env.header, env.body
    end

    def default_parser_option=(rhs)
      @@default_parser_option = rhs
    end

    def default_parser_option
      @@default_parser_option
    end

  private

    def create_generator(opt)
      SOAPGenerator.new(opt)
    end

    def create_parser(opt)
      if opt.empty?
	opt = @@default_parser_option
      end
      SOAPParser.create_parser(opt)
    end
  end
end


end
