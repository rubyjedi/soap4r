=begin
SOAP4R - Stream handler.
Copyright (C) 2000, 2001, 2003 NAKAMURA Hiroshi.

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


module SOAP


class StreamHandler
  Client = begin
      require 'http-access2'
      HTTPAccess2::Client
    rescue LoadError
      puts "Loading http-access2 failed.  Net/http is used." if $DEBUG
      require 'soap/netHttpClient'
      SOAP::NetHttpClient
    end

  RUBY_VERSION_STRING = "ruby #{ RUBY_VERSION } (#{ RUBY_RELEASE_DATE }) [#{ RUBY_PLATFORM }]"
  %q$Id: streamHandler.rb,v 1.28 2003/05/30 14:35:21 nahi Exp $ =~ /: (\S+),v (\S+)/
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

    def [](idx)
      @bag[idx]
    end

    def []=(idx, value)
      @bag[idx] = value
    end
  end

  attr_accessor :endpointUrl

  def initialize(endpointUrl)
    @endpointUrl = endpointUrl
  end

  def self.parseMediaType(str)
    if /^#{ MediaType }(?:\s*;\s*charset=([^"]+|"[^"]+"))?$/i !~ str
      raise StreamError.new("Illegal media type.");
    end
    charset = $1
    charset.gsub!(/"/, '') if charset
    charset
  end

  def self.createMediaType(charsetLabel)
    "#{ MediaType }; charset=#{ charsetLabel }"
  end
end


class HTTPPostStreamHandler < StreamHandler
  include SOAP

public
  
  attr_accessor :dumpDev
  attr_accessor :dumpFileBase
  attr_accessor :charset
  
  NofRetry = 10       	# [times]
  ConnectTimeout = 60   # [sec]
  SendTimeout = 60	# [sec]
  ReceiveTimeout = 60   # [sec]

  def initialize(endpointUrl, proxy = nil, charset = nil)
    super(endpointUrl)
    @proxy = proxy || ENV['http_proxy'] || ENV['HTTP_PROXY']
    @charset = charset || Charset.getCharsetLabel($KCODE)
    @dumpDev = nil	# Set an IO to get wiredump.
    @dumpFileBase = nil
    @client = Client.new(@proxy, "SOAP4R/#{ Version }")
    @client.sessionManager.connectTimeout = ConnectTimeout
    @client.sessionManager.sendTimeout = SendTimeout
    @client.sessionManager.receiveTimeout = ReceiveTimeout
  end

  def proxy=(newProxy)
    @proxy = newProxy
    @client.proxy = @proxy
  end

  def send(soapString, soapAction = nil, charset = @charset)
    begin
      sendPOST(soapString, soapAction, charset)
    rescue PostUnavailableError
#      begin
#        sendMPOST(soapString, soapAction, charset)
#      rescue MPostUnavailableError
#        raise HTTPStreamError.new($!)
#      end
      raise
    end
  end

  def reset
    @client.reset(@endpointUrl)
  end

private

  def sendPOST(soapString, soapAction, charset)
    data = ConnectionData.new
    data.sendString = soapString
    data.sendContentType = StreamHandler.createMediaType(charset)

    dumpDev = if @dumpDev && @dumpDev.respond_to?("<<")
	@dumpDev
      else
	nil
      end
    @client.debugDev = dumpDev

    if @dumpFileBase
      fileName = @dumpFileBase + '_request.xml'
      f = File.open(fileName, "w")
      f << soapString
      f.close
    end

    extra = {}
    extra['Content-Type'] = data.sendContentType
    extra['SOAPAction'] = "\"#{ soapAction }\""

    dumpDev << "Wire dump:\n\n" if dumpDev
    begin
      res = @client.post(@endpointUrl, soapString, extra)
    rescue
      @client.reset(@endpointUrl)
      raise
    end
    dumpDev << "\n\n" if dumpDev

    receiveString = res.content

    if @dumpFileBase
      fileName = @dumpFileBase + '_response.xml'
      f = File.open(fileName, "w")
      f << receiveString
      f.close
    end

    case res.status
    when 405
      raise PostUnavailableError.new("#{ res.status }: #{ res.reason }")
    when 200, 500
      # Nothing to do.
    else
      raise HTTPStreamError.new("#{ res.status }: #{ res.reason }")
    end

    data.receiveString = receiveString
    data.receiveContentType = res.contentType

    return data
  end

  def sendMPOST(soapString, soapAction, charset)
    raise NotImplementError.new()

    s = nil
    if ((status == '501') or (status == '510'))
      # 501: Not Implemented
      # 510: Not Extended
      raise MPostUnavailableError.new("Status: #{ status }, Reason-phrase: #{ reason }")
    elsif (status != '200')
      raise HTTPStreamError.new("#{ status }: #{ reason }")
    end
  end

  private

  CRLF = "\r\n"
end


end
