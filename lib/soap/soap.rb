# SOAP4R - Base definitions.
# Copyright (C) 2000, 2001 NAKAMURA Hiroshi.
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PRATICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 675 Mass
# Ave, Cambridge, MA 02139, USA.


module SOAP


Version = '1.4.4'

EnvelopeNamespace = 'http://schemas.xmlsoap.org/soap/envelope/'
EncodingNamespace = 'http://schemas.xmlsoap.org/soap/encoding/'
LiteralNamespace = 'http://xml.apache.org/xml-soap/literalxml'

NextActor = 'http://schemas.xmlsoap.org/soap/actor/next'

AttrMustUnderstand = 'mustUnderstand'
AttrEncodingStyle = 'encodingStyle'
AttrActor = 'actor'

AttrRoot = 'root'
AttrArrayType = 'arrayType'
AttrOffset = 'offset'
AttrPosition = 'position'

Base64Literal = 'base64'

SOAPNamespaceTag = 'env'
XSDNamespaceTag = 'xsd'
XSINamespaceTag = 'xsi'

class Error < StandardError; end

class StreamError < Error; end
class HTTPStreamError < StreamError; end
class PostUnavailableError < HTTPStreamError; end
class MPostUnavailableError < HTTPStreamError; end

class ArrayIndexOutOfBoundsError < Error; end
class ArrayStoreError < Error; end

class FaultError < Error
  attr_reader :faultCode
  attr_reader :faultString
  attr_reader :faultActor
  attr_accessor :detail

  def initialize( fault )
    @faultCode = fault.faultcode
    @faultString = fault.faultstring
    @faultActor = fault.faultactor
    @detail = fault.detail
    super( self.to_s )
  end

  def to_s
    str = nil
    if @faultString && @faultString.respond_to?( 'data' )
      str = @faultString.data
    end
    str || '(No faultString)'
  end
end


end
