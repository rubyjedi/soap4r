=begin
SOAP4R - CGI stub library
Copyright (C) 2001 NAKAMURA Hiroshi.

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


require 'soap/server'
require 'http-access2/http'


module SOAP


###
# SYNOPSIS
#   CGIStub.new
#
# DESCRIPTION
#   To be written...
#
class CGIStub < Server
  include SOAP

  class CGIError < Error; end

  class SOAPRequest
    ALLOWED_LENGTH = 1024 * 1024

    def initialize( sourceStream = $stdin )
      @method = ENV[ 'REQUEST_METHOD' ]
      @size = ENV[ 'CONTENT_LENGTH' ].to_i || 0
      @soap_action = ENV[ 'HTTP_SOAPAction' ]
      @source = sourceStream
      @body = nil
    end

    def init
      validate
      @body = @source.read( @size )
      self
    end

    def dump
      @body.dup
    end

    def soap_action
      @soap_action
    end

    def to_s
      "method: #{ @method }, size: #{ @size }"
    end

  private

    def validate # raise CGIError
      if @method != 'POST'
	raise CGIError.new( "Method '#{ @method }' not allowed." )
      end

      if @size > ALLOWED_LENGTH
        raise CGIError.new( "Content-length too long." )
      end
    end
  end

  def initialize( appName, namespace )
    super( appName, namespace )
    @remote_user = ENV[ 'REMOTE_USER' ] || 'anonymous'
    @remote_host = ENV[ 'REMOTE_HOST' ] || ENV[ 'REMOTE_ADDR' ] || 'unknown'
    @request = nil
    @response = nil
  end
  
protected
  def methodDef
    # Override this method in derived class to call 'addMethod' to add methods.
  end

private
  
  def run
    @log.sevThreshold = SEV_INFO

    prologue

    begin
      log( SEV_INFO, "Received a request from '#{ @remote_user }@#{ @remote_host }'." )
    
      # SOAP request parsing.
      @request = SOAPRequest.new.init
      log( SEV_INFO, "SOAP CGI Request: #{@request}" )

      requestString = @request.dump
      log( SEV_DEBUG, "XML Request: #{requestString}" )

      responseString, isFault = route( requestString )
      log( SEV_DEBUG, "XML Response: #{responseString}" )

      @response = HTTP::Message.newResponse( responseString )
      @response.header.set( 'Cache-Control', 'private' )
      @response.header.bodyType = 'text/xml'
      unless isFault
	@response.status = 200
      else
	@response.status = 500
      end
      @response.body.type = 'text/xml'
      @response.body.charset = Charset.getXMLInstanceEncoding
      str = @response.dump
      log( SEV_DEBUG, "SOAP CGI Response:\n#{ str }" )
      print str

      epilogue

    rescue Exception
      responseString = createFaultResponseString( $! )
      @response = HTTP::Message.newResponse( responseString )
      @response.header.set( 'Cache-Control', 'private' )
      @response.header.bodyType = 'text/xml'
      @response.status = 500
      @response.body.type = 'text/xml'
      str = @response.dump
      log( SEV_DEBUG, "SOAP CGI Response:\n#{ str }" )
      print str
      raise

    end
  end

  def prologue; end
  def epilogue; end
end


end
