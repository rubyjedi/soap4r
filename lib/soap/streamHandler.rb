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
  %q$Id: streamHandler.rb,v 1.12 2001/07/26 01:58:18 nakahiro Exp $ =~ /: (\S+),v (\S+)/
  RCS_FILE, RCS_REVISION = $1, $2

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
  
  MediaType = 'text/xml'

  NofRetry = 10       # [times]
  CallTimeout = 300   # [sec]
  ReadTimeout = 300   # [sec]

  def initialize( endPointUri, proxy = nil, charset = $KCODE )
    super( endPointUri )
    @server = endPointUri
    @proxy = proxy
    @charset = charset
    @dumpDev = nil	# Set an IO to get wiredump.
    @dumpFileBase = nil
    @client = HTTPAccess2::Client.new( proxy, "SOAP4R/#{ Version }" )
  end

  def send( soapString, soapAction = nil, charset = @charset )
    begin
      sendPOST( soapString, soapAction, charset )
    rescue PostUnavailableError
      begin
        sendMPOST( soapString, soapAction, charset )
      rescue MPostUnavailableError
        raise HTTPStreamError.new( $! )
      end
    end
  end

  private

  def sendPOST( soapString, soapAction, charset )
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
    extra[ 'Content-Type' ] = "#{ MediaType }; charset=#{ Charset.getCharsetLabel( charset ) }"
    extra[ 'SOAPAction' ] = "\"#{ soapAction }\""

    dumpDev << "Wire dump:\n\n" if dumpDev
    res = @client.request( 'POST', @server, soapString, extra )
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

    unless /^#{ MediaType }(?:;\s*charset=(.*))?/i =~ res.header[ 'content-type' ][ 0 ]
      raise HTTPStreamError.new( "Illegal content-type: #{ res.header[ 'content-type' ][ 0 ] }" )
    end
    receiveCharset = $1

    return receiveString, receiveCharset
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
