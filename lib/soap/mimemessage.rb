# SOAP4R - MIME Message implementation.
# Copyright (C) 2002  Jamie Herre.

# This program is copyrighted free software by NAKAMURA, Hiroshi.  You can
# redistribute it and/or modify it under the same terms of Ruby's license;
# either the dual license version in 2003, or any later version.


require 'soap/attachment'


module SOAP


# Classes for MIME message handling.  Should be put somewhere else!
# Tried using the 'tmail' module but found that I needed something
# lighter in weight.


class MIMEMessage
  class MIMEMessageError < StandardError; end

  MultipartContentType = 'multipart/\w+'

  class Header
    attr_accessor :str, :key, :root

    def initialize
      @attrs = {}
    end

    def [](key)
      @attrs[key]
    end

    def []=(key, value)
      @attrs[key] = value
    end

    def to_s
      @key + ": " + @str
    end
  end

  class Headers < Hash
    def self.parse(str)
      new.parse(str)
    end

    def parse(str)
      str.each do |line|
	if line =~ /^\A([^\: \t]+):\s*(.+)$/
	  header = parse_rhs($2.strip)
	  header.key = $1.strip
	  self[header.key.downcase] = header
	end
      end
      self
    end

    def parse_rhs( str )
      a = str.split(/;+\s+/)
      header = Header.new
      header.str = str
      header.root = a.shift
      a.each do |pair|
	next unless (pair =~ /(\w+)\s*=\s*"(.+)"/)
	header[$1.downcase] = $2
      end
      header
    end

    def add(key, value)
      if key != nil and value != nil
	header = parse_rhs(value)
	header.key = key
	self[key.downcase] = header
      end
    end

    def to_s
      self.values.collect { |hdr|
	hdr.to_s
      }.join("\r\n")
    end
  end

  class Part
    attr_accessor :headers, :body

    def initialize
      @headers = Headers.new
      @headers.add("Content-Transfer-Encoding", "8bit")
      @body = nil
    end

    def self.parse(str)
      new.parse(str)
    end

    def parse(str)
      headers, body = str.split(/\r\n\r\n/s)
      if headers != nil and body != nil
	@headers = Headers.parse(headers)
	@body = body
      end
      self
    end

    def contentid
      if @contentid == nil
	@contentid = @headers[ 'content-id' ].str
	@contentid = $1 if @contentid =~ /^<(.+)>$/
      end
      @contentid
    end

    alias content body

    def to_s
      @headers.to_s + "\r\n\r\n" + @body
    end
  end

  def initialize
    @parts = []
    @headers = Headers.new
  end

  def self.parse(head, str)
    new.parse(head, str)
  end

  attr_reader :parts, :headers

  def close
    @headers.add(
      "Content-Type",
      "multipart/related; type=\"text/xml\"; boundary=\"#{ boundary }\"; start=\"#{ @parts[0].contentid }\""
    )
  end

  def parse(head, str)
    @headers = Headers.parse(head + "\r\n" + "From: jfh\r\n")
    boundary = @headers['content-type']['boundary']
    if boundary != nil
      a = str.split(/--#{ boundary }-{0,2}[\r\n]{0,1}/s)
      if a.length > 2
	@parts = a[1, a.length-2].collect { |s| Part.parse(s) }
      end
    else
      @parts = [Part.parse(str)]
    end
    if @parts.length < 1
      raise MIMEMessageError.new("This message contains no valid parts!")
    end
    self
  end

  def root
    if @root == nil
      start = @headers['content-type']['start']
      @root = (start && @parts.find { |prt| prt.contentid == start }) ||
	@parts[0]
    end
    @root
  end

  def boundary
    if @boundary == nil
      @boundary = "----=Part_" + __id__.to_s + rand.to_s
    end
    @boundary
  end

  def add_part(content)
    part = Part.new
    part.headers.add("Content-Type",
      "text/xml; charset=" + XSD::Charset.encoding_label)
    part.headers.add("Content-ID", Attachment.contentid(part))
    part.body = content
    @parts.unshift(part)
  end

  def add_attachment(attach)
    part = Part.new
    part.headers.add("Content-Type", attach.contenttype)
    part.headers.add("Content-ID", attach.mime_contentid)
    part.body = attach.content
    @parts.unshift(part)
  end

  def has_parts?
    (@parts.length > 0)
  end

  def headers_str
    @headers.to_s
  end

  def content_str
    str = ''
    @parts.each do |prt|
      str << "--" + boundary + "\r\n"
      str << prt.to_s
    end
    str << '--' + boundary + "--\r\n\r\n"
    str
  end

  def to_s
    str = headers_str + "\r\n\r\n" + conent_str
  end
end


end
