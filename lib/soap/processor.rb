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
    marshalledString
  end

  ###
  ## SOAP unmarshalling
  #
  def unmarshal( stream, opt = {} )
    # parser = SOAPNQXMLStreamingParser.new( opt )
    parser = SOAPNQXMLLightWeightParser.new( opt )
    require 'soap/encodingStyleHandlerDynamic'

    envelopeNode = parser.parse( stream )

    return envelopeNode.header, envelopeNode.body
  end

  private

  SOAPNamespaceTag = 'SOAP-ENV'
  XSDNamespaceTag = 'xsd'
  XSINamespaceTag = 'xsi'
end


end
