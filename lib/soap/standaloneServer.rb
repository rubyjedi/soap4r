=begin
SOAP4R - Standalone Server
Copyright (c) 2001 by Michael Neumann and NAKAMURA, Hiroshi

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
require 'soap/streamHandler'
require "soap/httpserver"


module SOAP


###
# SYNOPSIS
#   StandaloneServer.new( appName, namespace, listening_i/f, listening_port )
#
# DESCRIPTION
#   To be written...
#
class StandaloneServer < Server
  include SOAP

  class SAError < Error; end
  
  ALLOWED_LENGTH = 1024 * 1024
    
  def initialize( appName, namespace, host = "127.0.0.1", port = 8080 )
    super( appName, namespace )
    @host, @port = host, port

    handler = self.method( :request_handler ).to_proc
    @server = ::HttpServer.new(handler, @port, @host)
  end
  
protected
  
  def methodDef
    # Override this method in derived class to call 'addMethod' to add methods.
  end

private

  def request_handler(request, response)
    log( SEV_INFO ) { "Received a request." }
    
    if request.method != 'POST'
      raise SAError.new( "Method '#{ request.method }' not allowed." )
    end
    
    length = request.content_length || 0
    if length > ALLOWED_LENGTH
      raise SAError.new( "Content-length too long." )
    end

    log( SEV_INFO ) { "Request: method: #{ request.method }, size: #{ length }" }

    contentType = request.header['Content-Type']
    requestCharset = StreamHandler.parseMediaType( contentType )
    requestString = request.data.read( length )        
    log( SEV_DEBUG ) { "XML Request: #{requestString}" }

    kcodeAdjusted = false
    charsetStrBackup = nil
    if requestCharset
      #requestString.sub!( /^([^>]*)\s+encoding=(['"])[^'"]*\2/ ) { $1 }
      charsetStr = Charset.getCharsetStr( requestCharset )
      Charset.setXMLInstanceEncoding( charsetStr )

      if SOAPParser.factory.adjustKCode
     	charsetStrBackup = $KCODE.to_s.dup
  	$KCODE = charsetStr
     	kcodeAdjusted = true
      end
    end

    responseString = isFault = nil
    begin
      responseString, isFault = route( requestString )
      log( SEV_DEBUG ) { "XML Response: #{responseString}" }
    ensure
      if kcodeAdjusted
	$KCODE = charsetStrBackup
      end
    end
    
    unless isFault
      response.status = 200
    else
      response.status = 500
    end
    response.body = responseString
    response.header['Content-Type']   = StreamHandler.createMediaType(
      requestCharset || Charset.getXMLInstanceEncodingLabel )
    response.header['Content-Length'] = responseString.length
    response.header['Cache-Control']  = 'private'  

  rescue Exception
    responseString  = createFaultResponseString( $! )
    response.body   = responseString
    response.status = 500
    response.header['Content-Type']   = StreamHandler.createMediaType(
      Charset.getXMLInstanceEncodingLabel )

  end
  
  def run
    class <<@log
      def puts( msg )
	add( SEV_INFO, msg, "SOAP::StandaloneServer" )
      end
      def flush; end
    end
    @server.stdlog = @log

    begin
      trap( 'INT' ) { @server.shutdown }
      trap( 'HUP' ) { @server.shutdown }
    rescue ArgumentError
      # mswin32 ruby cannot handle SIGHUP because of Windows' restriction.
    end
    @server.start.join
  end
end


end
