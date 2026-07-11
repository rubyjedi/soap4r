# encoding: UTF-8
# SOAP4R - Faraday wrapper.
#
# Faraday is itself pluggable (it has its own adapter selection, on top of
# ours) -- default to its own default adapter (:net_http, bundled via the
# faraday-net_http gem that ships as a runtime dependency of faraday itself)
# and let SOAP4R_FARADAY_ADAPTER override it for anyone who wants Faraday to
# ride on a different underlying transport (e.g. :patron for a libcurl-based
# one). This is a second, independent config knob layered under our own
# SOAP4R_HTTP_CLIENTS -- see lib/soap/httpbackend.rb -- not a replacement
# for it.

require 'faraday'
require 'base64'
require 'soap/filter/filterchain'


module SOAP


class FaradayClient
  attr_reader :proxy
  attr_accessor :no_proxy
  attr_accessor :debug_dev
  attr_reader :ssl_config
  attr_accessor :protocol_version	# ignored -- the underlying Faraday adapter negotiates this itself.
  attr_accessor :connect_timeout
  attr_accessor :send_timeout		# ignored -- mapped onto Faraday's single #timeout option instead (see #receive_timeout).
  attr_accessor :receive_timeout
  attr_reader :test_loopback_response
  attr_reader :request_filter		# ignored for now, same as SOAP::NetHttpClient.

  ADAPTER = (ENV['SOAP4R_FARADAY_ADAPTER'] || 'net_http').to_sym

  def initialize(proxy = nil, agent = nil)
    @proxy = proxy
    @no_proxy = nil
    @agent = agent
    @debug_dev = nil
    @ssl_config = SSLConfig.new
    @connect_timeout = @receive_timeout = @send_timeout = nil
    @basic_auth = nil	# [user, pass]
    @cookie_store = nil
    @test_loopback_response = []
    @request_filter = Filter::FilterChain.new
    require_adapter!
  end

  def proxy=(value)
    if value
      uri = value.is_a?(URI) ? value : URI.parse(value)
      if uri.scheme.nil? or uri.scheme.downcase != 'http' or uri.host.nil? or uri.port.nil?
        raise ArgumentError.new("unsupported proxy `#{value}'")
      end
    end
    @proxy = value
  end

  def set_basic_auth(uri, user_id, passwd)
    @basic_auth = [user_id, passwd]
  end

  def set_auth(uri, user_id, passwd)
    # Faraday's core has no bundled challenge-response (WWW-Authenticate)
    # negotiation -- that lives in third-party middleware, not something
    # this bridge can assume is installed. Digest auth in particular has no
    # core equivalent at all.
    raise NotImplementedError.new("challenge-response auth is not supported under soap4r + faraday.")
  end

  def set_cookie_store(filename)
    raise NotImplementedError.new("cookie persistence is not supported under soap4r + faraday.")
  end

  def save_cookie_store
    raise NotImplementedError.new("cookie persistence is not supported under soap4r + faraday.")
  end

  def reset(url)
    # no persistent connection state kept between requests; ignored.
  end

  def reset_all
    # ditto.
  end

  def post(url, req_body, header = {})
    if str = @test_loopback_response.shift
      if @debug_dev
        @debug_dev << "= Request\n\n"
        @debug_dev << req_body
        @debug_dev << "\n\n= Response\n\n"
        @debug_dev << str
      end
      return Response.new(200, nil, 'text/xml', Hash.new { |h, k| h[k] = [] }, str)
    end
    response = build_connection(url).post do |req|
      header.each { |k, v| req.headers[k] = v }
      req.headers['User-Agent'] = @agent if @agent
      if @basic_auth
        req.headers['Authorization'] =
          "Basic #{Base64.strict_encode64(@basic_auth.join(':'))}"
      end
      req.body = req_body
    end
    dump_wiredump(url, header, req_body, response) if @debug_dev
    Response.from_faraday(response)
  end

private

  def require_adapter!
    require "faraday/#{ADAPTER}"
  rescue LoadError
    raise LoadError.new(
      "Faraday adapter #{ADAPTER.inspect} could not be loaded -- is its " \
      "gem (e.g. \"faraday-#{ADAPTER}\" and whatever it wraps) installed?")
  end

  def build_connection(url)
    cfg = @ssl_config
    Faraday.new(
        url: url,
        proxy: no_proxy?(URI.parse(url)) ? nil : @proxy,
        ssl: {
          ca_file: cfg && cfg.ca_file,
          verify: !(cfg && cfg.verify_mode == OpenSSL::SSL::VERIFY_NONE),
        }
      ) do |f|
      f.adapter ADAPTER
    end.tap do |conn|
      conn.options.open_timeout = @connect_timeout if @connect_timeout
      conn.options.timeout = @receive_timeout if @receive_timeout
    end
  end

  def dump_wiredump(url, header, req_body, response)
    # Mirrors httpclient's wiredump block layout (marker line, blank line,
    # raw request-line + headers, blank line, body) -- callers that parse
    # wiredump_dev output by block position or by scanning for a "POST ..."
    # line (e.g. test/soap/test_streamhandler.rb's parse_req_header) depend
    # on that exact shape regardless of which backend produced it.
    uri = URI.parse(url)
    request_line = (@proxy && !no_proxy?(uri)) ? url : uri.request_uri
    @debug_dev << "= Request\n\n"
    @debug_dev << "POST #{request_line} HTTP/1.1\n"
    header.each { |k, v| @debug_dev << "#{k}: #{v}\n" }
    @debug_dev << "\n"
    @debug_dev << req_body
    @debug_dev << "\n\n= Response\n\n"
    @debug_dev << "HTTP/1.1 #{response.status} #{response.reason_phrase}\n"
    contenttype = response.headers['content-type']
    @debug_dev << "Content-Type: #{contenttype}\n" if contenttype
    @debug_dev << "\n"
    @debug_dev << response.body
  end

  NO_PROXY_HOSTS = ['localhost']

  def no_proxy?(uri)
    if !@proxy or NO_PROXY_HOSTS.include?(uri.host)
      return true
    end
    unless @no_proxy
      return false
    end
    @no_proxy.scan(/([^:,]+)(?::(\d+))?/) do |host, port|
      if /(\A|\.)#{Regexp.quote(host)}\z/i =~ uri.host &&
          (!port || uri.port == port.to_i)
        return true
      end
    end
    false
  end

  class SSLConfig
    attr_accessor :client_cert	# not applied -- see build_connection; client-cert auth would need per-adapter wiring Faraday doesn't unify.
    attr_accessor :client_key
    attr_accessor :client_ca
    attr_accessor :verify_mode
    attr_accessor :verify_depth	# no unified Faraday equivalent across adapters; stored only.
    attr_accessor :options
    attr_accessor :ciphers		# ditto.
    attr_accessor :verify_callback	# ditto.
    attr_accessor :cert_store		# ditto.
    attr_reader :ca_file

    def set_trust_ca(value)
      @ca_file = value
    end

    def set_crl(value)
      @crl = value	# not applied -- no unified Faraday equivalent.
    end

    # Whichever concrete adapter Faraday is riding on (net_http, patron,
    # etc.) determines the real default CA trust behavior; none of them
    # bundle their own snapshot the way httpclient does, so there's nothing
    # to override here.
    def set_default_paths
    end
  end

  class Response
    attr_reader :status
    attr_reader :reason
    attr_reader :contenttype
    attr_reader :header
    attr_reader :content

    def initialize(status, reason, contenttype, header, content)
      @status = status
      @reason = reason
      @contenttype = contenttype
      @header = header
      @content = content
    end

    def self.from_faraday(response)
      # Faraday::Utils::Headers keeps one value per key (last write wins for
      # anything the adapter received more than once, e.g. repeated
      # Set-Cookie lines) -- wrap each in a single-element Array so callers
      # get the same Hash-of-Arrays shape the other backends provide
      # (streamHandler.rb reads header['content-encoding'][0] and
      # header['location'][0]). A known, accepted limitation: multi-valued
      # response headers only reflect the last occurrence under this
      # backend.
      header = Hash.new { |h, k| h[k] = [] }
      response.headers.each { |k, v| header[k.downcase] = [v] }
      new(response.status, response.reason_phrase, response.headers['content-type'],
        header, response.body)
    end
  end
end


end
