=begin
SOAP4R - marshal/unmarshal interface.
Copyright (C) 2000 NAKAMURA Hiroshi.

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

require 'nqxml/writer'


module SOAP


module Processor
  public

  ###
  ## Encoding handling for xmlparser ( With NQXML, it does not work )
  #
  Encoding = [ nil ]
  def setEncoding( encoding = $KCODE )
    case encoding
    when 'EUC', 'SJIS'
      begin
	require 'uconv'
      rescue LoadError
	encoding = 'NONE'
      end
    when 'UTF8'
      # nothing to do
    else
      encoding = 'NONE'
    end
    Encoding[ 0 ] = encoding
  end
  module_function :setEncoding
  self.setEncoding( 'NONE' )

  def getEncoding
    Encoding[ 0 ]
  end
  module_function :getEncoding

  ###
  ## SOAP marshalling
  #
  def marshal( ns, header, body )

    # Namespace preparing.
    ns.assign( SOAP::EnvelopeNamespace, SOAPNamespaceTag )
    ns.assign( XSD::Namespace, XSDNamespaceTag )
    ns.assign( XSD::InstanceNamespace, XSINamespaceTag )

    # Create SOAP envelope.
    env = SOAPEnvelope.new( header, body )

    # XML tree construction.
    doc = NQXML::Document.new
    doc.setRootNode( env.encode( ns ))
    marshalledString = ""
    NQXML::Writer.new( marshalledString ).writeDocument( doc )
    xmlDecl + marshalledString
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

    envelopeNode = parser.parse( stream )

    return envelopeNode.header, envelopeNode.body
  end
  module_function :unmarshal

  def setDefaultParser( opt )
    DefaultParser[ 0 ] = loadParser( opt )
  end
  module_function :setDefaultParser

  def clearDefaultParser
    DefaultParser[ 0 ] = nil
  end
  module_function :clearDefaultParser

  private

  def self.loadParser( opt )
    if SOAP.const_defined?( "SOAPXMLParser" )
      parser = SOAPXMLParser.new( opt )
    elsif SOAP.const_defined?( "SOAPSAXDriver" )
      parser = SOAPSAXDriver.new( opt )
    else
      # parser = SOAPNQXMLStreamingParser.new( opt )
      parser = SOAPNQXMLLightWeightParser.new( opt )
    end
    require 'soap/encodingStyleHandlerDynamic'
    parser
  end

  SOAPNamespaceTag = 'SOAP-ENV'
  XSDNamespaceTag = 'xsd'
  XSINamespaceTag = 'xsi'

  def xmlDecl
    if Processor.getEncoding == 'NONE'
      "<?xml version=\"1.0\" ?>\n"
    else
      "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n"
    end
  end
end


end
