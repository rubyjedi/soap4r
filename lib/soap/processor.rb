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


module SOAP


module Processor
  public

  ###
  ## SOAP marshalling
  #
  def marshal( header, body, opt = {} )
    env = SOAPEnvelope.new( header, body )
    generator = SOAPGenerator.new( opt )
    xmlDecl + generator.generate( env )
  end
  module_function :marshal


  ###
  ## SOAP unmarshalling
  #
  DefaultParser = [ nil ]
  def unmarshal( stream, opt = {} )
    if opt.empty?
      parser = DefaultParser[ 0 ] || loadParser( opt )
    else
      parser = loadParser( opt )
    end

    env = parser.parse( stream )

    return env.header, env.body
  end
  module_function :unmarshal

  def setDefaultParser( opt = {} )
    DefaultParser[ 0 ] = loadParser( opt )
  end
  module_function :setDefaultParser

  def clearDefaultParser
    DefaultParser[ 0 ] = nil
  end
  module_function :clearDefaultParser

  def loadParser( opt = {} )
    if SOAP.const_defined?( "SOAPXMLParser" )
      parser = SOAPXMLParser.new( opt )
    elsif SOAP.const_defined?( "SOAPSAXDriver" )
      parser = SOAPSAXDriver.new( opt )
    else
      begin
	require 'soap/xmlparser'
	# parser = SOAPXMLParser.new( opt )
	# From Ruby/1.7, ruby eventually cannot find this constant in above
	# style.  Following is a quick hack to avoid this trouble.  It should
	# be resolved at some time.
	parser = ::SOAP::SOAPXMLParser.new( opt )
      rescue LoadError
	require 'soap/nqxmlparser'
	# parser = SOAPNQXMLLightWeightParser.new( opt )
	# ditto.
	parser = ::SOAP::SOAPNQXMLLightWeightParser.new( opt )
      end
    end
    parser
  end
  module_function :loadParser

private

  def xmlDecl
    if Charset.getXMLInstanceEncoding == 'NONE'
      "<?xml version=\"1.0\" ?>\n"
    else
      "<?xml version=\"1.0\" encoding=\"#{ Charset.getXMLInstanceEncodingLabel }\" ?>\n"
    end
  end
  module_function :xmlDecl
end


end
