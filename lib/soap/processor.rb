=begin
SOAP4R - marshal/unmarshal interface.
Copyright (C) 2000, 2001 NAKAMURA Hiroshi.

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
  'soap/xmlparser',
  'soap/nqxmlparser',
  'soap/rexmlparser',
  'soap/xmlscanner',
].each do | lib |
  begin
    require lib
    loaded = true
    break
  rescue LoadError
  end
end
unless loaded
  raise RuntimeError.new( "XML processor module not found." )
end


module SOAP


module Processor
  @@defaultParserOption = {}

  class << self
  public

    def marshal( header, body, opt = {} )
      env = SOAPEnvelope.new( header, body )
      generator = createGenerator( opt )
      return xmlDecl << generator.generate( env )
    end

    def unmarshal( stream, opt = {} )
      parser = createParser( opt )
      env = parser.parse( stream )
      return env.header, env.body
    end

    def defaultParserOption=( rhs )
      @@defaultParserOption = rhs
    end

    def defaultParserOption
      @@defaultParserOption
    end

  private

    def createGenerator( opt )
      SOAPGenerator.new( opt )
    end

    def createParser( opt )
      if opt.empty?
	opt = @@defaultParserOption
      end
      SOAPParser.createParser( opt )
    end

    def xmlDecl
      if Charset.getXMLInstanceEncoding == 'NONE'
	"<?xml version=\"1.0\" ?>\n"
      else
	"<?xml version=\"1.0\" encoding=\"#{ Charset.getXMLInstanceEncodingLabel }\" ?>\n"
      end
    end
  end
end


end
