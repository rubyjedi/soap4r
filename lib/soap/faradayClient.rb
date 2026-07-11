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
require 'tempfile'
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
    ssl_opts = {
      :ca_file => cfg && cfg.ca_file,
      :verify => !(cfg && cfg.verify_mode == OpenSSL::SSL::VERIFY_NONE),
      # Faraday::SSLOptions documents client_cert/client_key as accepting
      # OpenSSL objects directly, but confirmed empirically that the
      # :typhoeus adapter rejects them ("Problem with the local SSL
      # certificate") and only accepts file paths -- same requirement as
      # curb's C binding (see curbClient.rb), so round-trip the same way
      # here for whichever adapter is actually active.
      :client_cert => cfg && cfg.client_cert && write_pem_tempfile(cfg.client_cert, 'cert'),
      :client_key => cfg && cfg.client_key && write_pem_tempfile(cfg.client_key, 'key'),
      :verify_depth => cfg && cfg.verify_depth,
      :cert_store => cfg && cfg.cert_store,
    }
    # Faraday::SSLOptions is a Struct, and Faraday's own connection setup
    # merges this hash into it via []= -- which raises NameError for any
    # key that isn't a struct member, rather than just ignoring it the way
    # a Hash would. :ciphers was dropped from that struct for a stretch of
    # faraday 2.x releases and later restored (confirmed: present on
    # 2.14.3, absent on 2.8.1 -- exactly what Ruby 3.3+ vs. 2.6/2.7
    # resolve to respectively) -- confirmed crashing every single request
    # on the versions missing it. Only include the key at all when this
    # faraday actually has it; it's passed through for adapters that honor
    # SSLOptions#ciphers, but confirmed empirically that :typhoeus silently
    # ignores it either way (Faraday's own typhoeus adapter doesn't
    # forward it to ethon's ssl_cipher_list at all) -- a real, external gap
    # in that adapter, not something this bridge can paper over.
    # verify_depth/cert_store have the same no-guarantee-every-adapter-
    # honors-them caveat.
    ssl_opts[:ciphers] = cfg && cfg.ciphers if Faraday::SSLOptions.members.include?(:ciphers)
    Faraday.new(
        :url => url,
        :proxy => no_proxy?(url.is_a?(URI) ? url : URI.parse(url)) ? nil : @proxy,
        :ssl => ssl_opts
      ) do |f|
      f.adapter ADAPTER
    end.tap do |conn|
      conn.options.open_timeout = @connect_timeout if @connect_timeout
      conn.options.timeout = @receive_timeout if @receive_timeout
    end
  end

  def write_pem_tempfile(openssl_obj, basename)
    f = Tempfile.new(["soap4r-faraday-#{basename}-", '.pem'])
    f.write(openssl_obj.to_pem)
    f.close
    # The finalizer proc must not be created in an instance-method context
    # closing over self -- see the identical comment in curbClient.rb's own
    # write_pem_tempfile for why (confirmed: Ruby warns "finalizer
    # references object to be finalized" and the tempfile never actually
    # got cleaned up otherwise).
    ObjectSpace.define_finalizer(self, self.class.tempfile_unlinker(f))
    f.path
  end

  def self.tempfile_unlinker(file)
    proc { file.unlink rescue nil }
  end

  def dump_wiredump(url, header, req_body, response)
    # Mirrors httpclient's wiredump block layout (marker line, blank line,
    # raw request-line + headers, blank line, body) -- callers that parse
    # wiredump_dev output by block position or by scanning for a "POST ..."
    # line (e.g. test/soap/test_streamhandler.rb's parse_req_header) depend
    # on that exact shape regardless of which backend produced it.
    uri = url.is_a?(URI) ? url : URI.parse(url)
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
    # client_cert/client_key/ciphers/verify_depth/cert_store are all applied
    # via Faraday::SSLOptions in build_connection -- Faraday's options
    # struct accepts the same OpenSSL::X509::Certificate/OpenSSL::PKey::RSA
    # objects HTTPConfigLoader already builds for httpclient's sake. Whether
    # each one is actually *honored* still depends on which concrete adapter
    # Faraday is riding on (SOAP4R_FARADAY_ADAPTER) -- confirmed working for
    # :net_http and :typhoeus, not verified against every adapter Faraday
    # supports.
    attr_accessor :client_cert
    attr_accessor :client_key
    attr_accessor :client_ca
    attr_accessor :verify_mode
    attr_accessor :verify_depth
    attr_accessor :options		# no unified Faraday equivalent across adapters (OpenSSL::SSL::SSLContext#options bitmask); stored only.
    attr_accessor :ciphers
    attr_accessor :verify_callback	# NOT supported -- no adapter Faraday supports exposes a per-certificate Ruby callback hook (same underlying limitation as libcurl-based backends generally).
    attr_accessor :cert_store
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
