=begin
SOAP4R - Stream handler.
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
require 'soap/charset'
require 'http-access2'


module SOAP


class StreamHandler
public

  RUBY_VERSION_STRING = "ruby #{ RUBY_VERSION } (#{ RUBY_RELEASE_DATE }) [#{ RUBY_PLATFORM }]"
  %q$Id: streamHandler.rb,v 1.18 2002/01/25 14:52:46 nakahiro Exp $ =~ /: (\S+),v (\S+)/
  RCS_FILE, RCS_REVISION = $1, $2

  class ConnectionData
    attr_accessor :sendString
    attr_accessor :sendContentType
    attr_accessor :receiveString
    attr_accessor :receiveContentType

    def initialize
      @sendData = nil
      @sendContentType = nil
      @receiveData = nil
      @receiveContentType = nil
      @bag = {}
    end

    def []( idx )
      @bag[ idx ]
    end

    def []=( idx, value )
      @bag[ idx ] = value
    end
  end

  attr_reader :endPoint

  def initialize( endPoint )
    @endPoint = endPoint
  end
end


class HTTPPostStreamHandler < StreamHandler
  include SOAP

public
  
  attr_accessor :dumpDev
  attr_accessor :dumpFileBase
  
  SendMediaType = 'text/xml'

  NofRetry = 10       	# [times]
  ConnectTimeout = 60   # [sec]
  SendTimeout = 60	# [sec]
  ReceiveTimeout = 60   # [sec]

  def initialize( endPointUri, proxy = nil, charset = nil )
    super( endPointUri )
    @server = endPointUri
    @proxy = proxy
    @charset = charset
    @dumpDev = nil	# Set an IO to get wiredump.
    @dumpFileBase = nil
    @client = HTTPAccess2::Client.new( proxy, "SOAP4R/#{ Version }" )
    @client.sessionManager.connectTimeout = ConnectTimeout
    @client.sessionManager.sendTimeout = SendTimeout
    @client.sessionManager.receiveTimeout = ReceiveTimeout
  end

  def send( soapString, soapAction = nil, charset = @charset )
    begin
      sendPOST( soapString, soapAction, charset )
    rescue PostUnavailableError
#      begin
#        sendMPOST( soapString, soapAction, charset )
#      rescue MPostUnavailableError
#        raise HTTPStreamError.new( $! )
#      end
      raise
    end
  end

private

  def sendPOST( soapString, soapAction, charset )
    data = ConnectionData.new
    data.sendString = soapString
    data.sendContentType = SendMediaType

    dumpDev = if @dumpDev && @dumpDev.respond_to?( "<<" )
	@dumpDev
      else
	nil
      end
    @client.debugDev = dumpDev

    if @dumpFileBase
      fileName = @dumpFileBase + '_request.xml'
      f = File.open( fileName, "w" )
      f << soapString
      f.close
    end

    extra = {}
    extra[ 'Content-Type' ] = "#{ SendMediaType }; charset=#{ Charset.getCharsetLabel( charset || Charset.getXMLInstanceEncoding ) }"
    extra[ 'SOAPAction' ] = "\"#{ soapAction }\""

    dumpDev << "Wire dump:\n\n" if dumpDev
    begin
      res = @client.request( 'POST', @server, soapString, extra )
    rescue
      @client.reset( @server )
      raise
    end
    dumpDev << "\n\n" if dumpDev

    receiveString = res.body.content

    if @dumpFileBase
      fileName = @dumpFileBase + '_response.xml'
      f = File.open( fileName, "w" )
      f << receiveString
      f.close
    end

    case res.status
    when 405
      raise PostUnavailableError.new( "#{ res.status }: #{ res.reason }" )
    when 200, 500
      # Nothing to do.
    else
      raise HTTPStreamError.new( "#{ res.status }: #{ res.reason }" )
    end

    data.receiveString = receiveString
    data.receiveContentType = res.header[ 'content-type' ][ 0 ]

    return data
  end

  def sendMPOST( soapString, soapAction, charset )
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


end
