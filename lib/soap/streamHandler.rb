# SOAP4R - Stream handler.
# Copyright (C) 2000, 2001, 2003  NAKAMURA, Hiroshi <nahi@ruby-lang.org>.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/soap'
require 'soap/property'


module SOAP


class StreamHandler
  Client = begin
      require 'http-access2'
      if HTTPAccess2::VERSION < "2.0"
	raise LoadError.new("http-access/2.0 or later is required.")
      end
      HTTPAccess2::Client
    rescue LoadError
      STDERR.puts "Loading http-access2 failed.  Net/http is used." if $DEBUG
      require 'soap/netHttpClient'
      SOAP::NetHttpClient
    end

  RUBY_VERSION_STRING = "ruby #{ RUBY_VERSION } (#{ RUBY_RELEASE_DATE }) [#{ RUBY_PLATFORM }]"

  class ConnectionData
    attr_accessor :send_string
    attr_accessor :send_contenttype
    attr_accessor :receive_string
    attr_accessor :receive_contenttype

    def initialize
      @send_string = nil
      @send_contenttype = nil
      @receive_string = nil
      @receive_contenttype = nil
      @bag = {}
    end

    def [](idx)
      @bag[idx]
    end

    def []=(idx, value)
      @bag[idx] = value
    end
  end

  attr_accessor :endpoint_url

  def initialize(endpoint_url)
    @endpoint_url = endpoint_url
  end

  def self.parse_media_type(str)
    if /^#{ MediaType }(?:\s*;\s*charset=([^"]+|"[^"]+"))?$/i !~ str
      raise StreamError.new("Illegal media type.");
    end
    charset = $1
    charset.gsub!(/"/, '') if charset
    charset || 'us-ascii'
  end

  def self.create_media_type(charset)
    "#{ MediaType }; charset=#{ charset }"
  end
end


class HTTPPostStreamHandler < StreamHandler
  include SOAP

public
  
  attr_reader :client
  attr_accessor :wiredump_file_base
  
  NofRetry = 10       	# [times]

  def initialize(endpoint_url, options)
    super(endpoint_url)
    @client = Client.new(@proxy, "SOAP4R/#{ Version }")
    @wiredump_file_base = nil
    @proxy = @charset = @wiredump_dev = nil
    @options = options
    set_options
    @client.debug_dev = @wiredump_dev
  end

  def inspect
    "#<#{self.class}:#{endpoint_url}>"
  end

  def send(soap_string, soapaction = nil, charset = @charset)
    send_post(soap_string, soapaction, charset)
  end

  def reset
    @client.reset(@endpoint_url)
  end

private

  def set_options
    @proxy = @options["proxy"]
    @options.add_hook("proxy") do |key, value|
      @proxy = value
    end
    @charset = @options["charset"] || XSD::Charset.charset_label($KCODE)
    @options.add_hook("charset") do |key, value|
      @charset = value
    end
    @wiredump_dev = @options["wiredump_dev"]
    @options.add_hook("wiredump_dev") do |key, value|
      @wiredump_dev = value
      @client.debug_dev = @wiredump_dev
    end
    @options.lock
  end

  def send_post(soap_string, soapaction, charset)
    data = ConnectionData.new
    data.send_string = soap_string
    data.send_contenttype = StreamHandler.create_media_type(charset)

    if @wiredump_file_base
      filename = @wiredump_file_base + '_request.xml'
      f = File.open(filename, "w")
      f << soap_string
      f.close
    end

    extra = {}
    extra['Content-Type'] = data.send_contenttype
    extra['SOAPAction'] = "\"#{ soapaction }\""

    @wiredump_dev << "Wire dump:\n\n" if @wiredump_dev
    begin
      res = @client.post(@endpoint_url, soap_string, extra)
    rescue
      @client.reset(@endpoint_url)
      raise
    end
    @wiredump_dev << "\n\n" if @wiredump_dev

    receive_string = res.content

    if @wiredump_file_base
      filename = @wiredump_file_base + '_response.xml'
      f = File.open(filename, "w")
      f << receive_string
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

    data.receive_string = receive_string
    data.receive_contenttype = res.contenttype

    return data
  end

  CRLF = "\r\n"
end


end
