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

require 'soap/soap'
require 'soap/rpcRouter'

# Ruby bundled library

# Redist library
require 'application'


module SOAP


###
# SYNOPSIS
#   CGIStub.new
#
# DESCRIPTION
#   To be written...
#
class CGIStub < Application
  include SOAP
  include Processor
  include RPCUtils

  class CGIError < Error; end

  class CGIRequest
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

  class CGIResponse
    class Header
      attr_accessor :status, :bodyType, :bodyCharset, :bodySize, :bodyDate

      CRLF = "\r\n"

      StatusMap = {
	200 => 'OK',
	302 => 'Object moved',
	400 => 'Bad Request',
	500 => 'Internal Server Error',
      }

      CharsetMap = {
	'NONE' => 'us-ascii',
	'EUC' => 'euc-jp',
	'SJIS' => 'shift_jis',
	'UTF8' => 'utf-8',
      }

      def initialize( status = 200 )
	@status = status
	@bodyType = nil
	@bodyCharset = nil
	@bodySize = nil
	@bodyDate = nil
	@extra = []
      end

      def add( key, value )
	@extra.push( [ key, value ] )
      end

      def dump
	str = ''
	if defined?( Apache )
	  if !StatusMap.include?( @status )
	    @status = 400
	  end
	  str << dumpItem( "HTTP/1.0 #{ @status } #{ StatusMap[ @status ] }" )
	  str << dumpItem( "Date: #{ httpDate( Time.now ) }" )
	else
	  str << dumpItem( "Status: #{ @status } #{ StatusMap[ @status ] }" )
	end

	if @bodySize
	  str << dumpItem( "Content-Length: #{ @bodySize }" )
	else
	  str << dumpItem( "Connection: close" )
	end
	str << dumpItem( "Last-Modified: #{ httpDate( @bodyDate ) }" ) if @bodyDate
	str << dumpItem( "Content-Type: #{ @bodyType || 'text/html' }; charset=#{ CharsetMap[ @bodyCharset || $KCODE ]}" )
	@extra.each do | key, value |
	  str << dumpItem( "#{ key }: #{ value }" )
	end
	str << CRLF
	str
      end

    private

      def dumpItem( str )
	str + CRLF
      end

      def httpDate( aTime )
	aTime.gmtime.strftime( "%a, %d %b %Y %H:%M:%S GMT" )
      end
    end

    class Body
      attr_accessor :type, :charset, :date

      def initialize( body = nil, date = nil, type = nil, charset = nil )
	@body = body
	@type = type
	@charset = charset
	@date = date
      end

      def size
	if @body
	  @body.size
	else
	  nil
	end
      end

      def dump
	@body
      end
    end

    def initialize( response )
      self.header = Header.new
      header.add( 'Cache-Control', 'private' )
      self.body = Body.new( response )
    end

    def dump
      unless header
	raise RuntimeError.new( "Response header not set." )
      end
      sync
      str = header.dump
      str << body.dump if body and body.dump
      str
    end

    def header
      @header
    end

    def header=( header )
      @header = header
      sync
    end

    def body
      @body
    end

    def body=( body )
      @body = body
      sync
    end

  private

    def sync
      if @header and @body
	@header.bodyType = @body.type
	@header.bodyCharset = @body.charset
	@header.bodySize = @body.size
	@header.bodyDate = @body.date
      end
    end
  end

  def initialize( appName, namespace )
    super( appName )
    @namespace = namespace
    @remote_user = ENV[ 'REMOTE_USER' ] || 'anonymous'
    @remote_host = ENV[ 'REMOTE_HOST' ] || ENV[ 'REMOTE_ADDR' ] || 'unknown'
    @request = nil
    @response = nil
    @router = RPCRouter.new( appName )
  end
  
protected
  def methodDef
    # Override this method in derived class to call 'addMethod' to add methods.
  end

private
  
  def run
    begin
      log( SEV_INFO, "Received a request from '#{ @remote_user }@#{ @remote_host }'." )
    
      # SOAP request parsing.
      @request = CGIRequest.new.init
      log( SEV_INFO, "CGI Request: #{@request}" )

      # Method definition
      methodDef

      requestString = @request.dump
      log( SEV_DEBUG, "XML Request: #{requestString}" )

      responseString, isFault = @router.route( requestString )
      log( SEV_DEBUG, "XML Response: #{responseString}" )

      @response = CGIResponse.new( responseString )
      unless isFault
	@response.header.status = 200
      else
	@response.header.status = 500
      end
      @response.body.type = 'text/xml'
      str = @response.dump
      log( SEV_DEBUG, "CGI Response:\n#{ str }" )
      print str

    rescue Exception
      responseString = @router.faultResponseString( $! )
      @response = CGIResponse.new( responseString )
      @response.header.status = 500
      @response.body.type = 'text/xml'
      str = @response.dump
      log( SEV_DEBUG, "CGI Response:\n#{ str }" )
      print str
      raise

    end
  end

  # namespace cannot be defined here.
  def addMethod( receiver, methodName, paramDef = nil )
    @router.addMethod( @namespace, receiver, methodName, paramDef )
  end
end


end
