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

module SOAPProcessor
  public

  ###
  ## SOAP marshaling
  #
  def marshal( ns, header, body )

    # Namespace preparing.
    ns.assign( SOAP::EnvelopeNamespace, SOAPNamespaceTag )
    ns.assign( XSD::Namespace, XSDNamespaceTag )
    ns.assign( XSD::InstanceNamespace, XSINamespaceTag )

    # Create SOAP envelope.
    env = SOAPEnvelope.new( header, body )

    # XML tree construction.
    XML::SimpleTree::Document.new( env.encode( ns ))
  end

  ###
  ## SOAP unmarshaling
  #
  def unmarshal( stream, opt = {} )

    # Namespace preparing.
    ns = SOAPNS.new()

    # XML tree parsing.
    builder = XML::SimpleTreeBuilder.new()
    elem = builder.parse( stream ).documentElement
    elem.normalize

    # Parse SOAP envelope.
    env = SOAPEnvelope.decode( ns, elem, opt.has_key?( 'allowUnqualifiedElement' ))

    return ns, env.header, env.body
  end

  private

  SOAPNamespaceTag = 'SOAP-ENV'
  XSDNamespaceTag = 'xsd'
  XSINamespaceTag = 'xsi'
end
