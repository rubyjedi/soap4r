=begin
SOAP4R
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

require 'SOAP'
require 'uri'
require 'socket'
require 'timeout'


class SOAPStreamHandler
  public

  attr_reader :endPoint

  def initialize( endPoint )
    @endPoint = endPoint
  end
end


class SOAPHTTPPostStreamHandler < SOAPStreamHandler
  public
  
  MediaType = 'text/xml'

  NofRetry = 10       # [times]
  CallTimeout = 300   # [sec]
  ReadTimeout = 300   # [sec]

  def initialize( endPointUri, proxy = nil )
    super( endPointUri )
    @server = endPointUri
    @proxy = proxy
  end

  def send( methodNamespace, methodName, soapString )
    begin
      s = sendPOST( methodNamespace, methodName, soapString )
    rescue PostUnavailableError
      begin
        s = sendMPOST( methodNamespace, methodName, soapString )
      rescue MPostUnavailableError
        raise HTTPStreamError.new( $! )
      end
    end
  end

  private

  def sendPOST( methodNamespace, methodName, soapString )
    server = URIModule::URI.create( @server )

    retryNo = NofRetry
    begin
      if @proxy
	proxy = URIModule::URI.create( @proxy )
	s = TCPSocket.new( proxy.host, proxy.port )
      else
	s = TCPSocket.new( server.host, server.port )
      end
    rescue
      retryNo -= 1
      if retryNo > 0
        puts 'Retrying connection ...' if $DEBUG
        retry
      end
      raise
    end

    if @proxy
      absPath = @server if @proxy
    else
      absPath = server.path.dup
      absPath << '?' << server.query if server.query
    end
    action = methodNamespace.dup << '#' << methodName

    puts soapString if $DEBUG

    header = {}
    begin
      timeout( CallTimeout ) do
          postData =<<EOS
POST #{ absPath } HTTP/1.0
Host: #{ server.host }
Connection: close
Content-Length: #{ soapString.size }
Content-Type: #{ MediaType }
SOAPAction: #{ action }

EOS
        postData.gsub!( "\n", CRLF )

        postData << soapString
        s.write postData
        puts postData if $DEBUG

        raise HTTPStreamError.new( 'Unexpected EOF...' ) if s.eof

        # Parse HTTP header
        version = nil
        status = nil
        reason = nil
        begin
          line = s.gets.chop
          puts line if $DEBUG
          Regexp.new( '^HTTP/(1.\d)\s+(\d+)\s+(.*)$' ) =~ line
          version = $1
          status = $2
          reason = $3

          lastKey = nil
          lastValue = nil
          while !s.eof
            line = s.gets.chop
            if ( /^$/ =~ line )
              header[ lastKey ] = lastValue if lastKey
              break
            elsif ( /^([^:]+)\s*:\s*(.*)$/ =~ line )
              header[ lastKey ] = lastValue if lastKey
              lastKey = $1.downcase
              lastValue = $2
            else
              lastValue << "\n" << line
            end
          end
        end while ( !s.eof and version == '1.1' and status == '100' )

        if ( status == '405' )
          # 405: Method Not Allowed
          raise PostUnavailableError.new( "#{ status }: #{ reason }" )
        elsif ( status != '200' )
          raise HTTPStreamError.new( "#{ status }: #{ reason }" )
        elsif ( !header.has_key?( 'content-type' ))
          raise HTTPStreamError.new( 'Content-type not found.' )
	elsif ( /^#{ MediaType }(?:;.*)?/ !~ header[ 'content-type' ] )
#          raise HTTPStreamError.new( 'Illegal content-type: ' << header[ 'content-type' ] )
        end
      end
    rescue TimeoutError
      raise HTTPStreamError.new( 'Call timeout' )
    end

    receiveString = ''
    begin
      timeout( ReadTimeout ) do
	while !s.eof
	  receiveString << s.gets
	end
      end
    rescue TimeoutError
      raise HTTPStreamError.new( 'Read timeout' )
    end

    puts receiveString if $DEBUG
    receiveString
  end

  def sendMPOST( methodNamespace, methodName, soapString )
    raise NotImplementError.new()

    s = nil
    if (( status == '501' ) or ( status == '510' ))
      # 501: Not Implemented
      # 510: Not Extended
      raise MPostUnavailableError.new( "Status: #{ status }, Reason-phrase: #{ reason }" )
    elsif ( status != '200' )
      raise HTTPStreamError.new( "#{ status }: #{ reason }" )
    end
  end

  private

  CRLF = "\r\n"
end
