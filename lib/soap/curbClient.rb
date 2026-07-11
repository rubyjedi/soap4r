# encoding: UTF-8
# SOAP4R - curb (libcurl) wrapper.

require 'curb'
require 'tempfile'
require 'soap/filter/filterchain'


module SOAP


class CurbClient
  attr_reader :proxy
  attr_accessor :no_proxy
  attr_accessor :debug_dev
  attr_reader :ssl_config
  attr_accessor :protocol_version	# ignored -- libcurl negotiates this itself.
  attr_accessor :connect_timeout
  attr_accessor :send_timeout		# ignored -- libcurl has one overall #timeout, not separate send/receive phases.
  attr_accessor :receive_timeout
  attr_reader :test_loopback_response
  attr_reader :request_filter		# ignored for now, same as SOAP::NetHttpClient.

  def initialize(proxy = nil, agent = nil)
    @proxy = proxy
    @no_proxy = nil
    @agent = agent
    @debug_dev = nil
    @ssl_config = SSLConfig.new
    @connect_timeout = @receive_timeout = @send_timeout = nil
    @basic_auth = nil	# [user, pass], set via #set_basic_auth
    @challenge_auth = nil	# [user, pass], set via #set_auth
    @cookie_store = nil
    @test_loopback_response = []
    @request_filter = Filter::FilterChain.new
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

  # soap4r's "auth" (as opposed to "basic_auth") is fed by a server
  # challenge (WWW-Authenticate: Basic or Digest) rather than sent
  # proactively -- :any lets libcurl negotiate whichever the server
  # actually asks for, covering both test/soap/auth/test_basic.rb and
  # test/soap/auth/test_digest.rb with the same code path.
  def set_auth(uri, user_id, passwd)
    @challenge_auth = [user_id, passwd]
  end

  def set_cookie_store(filename)
    @cookie_store = filename
  end

  def save_cookie_store
    # curb's cookiejar is written incrementally as requests complete;
    # nothing to flush here.
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
    curl = build_curl(url, header)
    curl.http_post(req_body)
    dump_wiredump(curl, req_body) if @debug_dev
    Response.from_curl(curl)
  end

private

  def build_curl(url, header)
    curl = Curl::Easy.new(url)
    curl.headers = header.dup
    curl.headers['User-Agent'] = @agent if @agent
    curl.follow_location = false	# streamHandler.rb's own send_post loop handles redirects.
    curl.connect_timeout = @connect_timeout if @connect_timeout
    curl.timeout = @receive_timeout if @receive_timeout
    unless no_proxy?(URI.parse(url))
      curl.proxy_url = @proxy
    end
    if @challenge_auth
      curl.http_auth_types = :any
      curl.username, curl.password = @challenge_auth
    elsif @basic_auth
      curl.http_auth_types = :basic
      curl.username, curl.password = @basic_auth
    end
    curl.cookiejar = @cookie_store if @cookie_store
    apply_ssl_config(curl)
    curl
  end

  def apply_ssl_config(curl)
    cfg = @ssl_config
    return unless cfg
    curl.ssl_verify_peer = (cfg.verify_mode != OpenSSL::SSL::VERIFY_NONE)
    curl.ssl_verify_host = (cfg.verify_mode == OpenSSL::SSL::VERIFY_NONE) ? 0 : 2
    curl.cacert = cfg.ca_file if cfg.ca_file
    # Curl::Easy has no dedicated ciphers=/cipher_list= method at all
    # (confirmed empirically -- NoMethodError) despite libcurl itself
    # supporting CURLOPT_SSL_CIPHER_LIST; #setopt with the raw constant is
    # curb's only way to reach it.
    curl.setopt(Curl::CURLOPT_SSL_CIPHER_LIST, cfg.ciphers) if cfg.ciphers
    # Curl::Easy#cert=/#cert_key= want file paths, but
    # HTTPConfigLoader#cert_from_file/#key_from_file (lib/soap/httpconfigloader.rb)
    # already parsed the configured files into OpenSSL::X509::Certificate/
    # OpenSSL::PKey::RSA objects (that's what httpclient's SSLConfig wants) --
    # round-trip them back out to PEM tempfiles for curb's sake.
    curl.cert = write_pem_tempfile(cfg.client_cert, 'cert') if cfg.client_cert
    curl.cert_key = write_pem_tempfile(cfg.client_key, 'key') if cfg.client_key
  end

  def write_pem_tempfile(openssl_obj, basename)
    f = Tempfile.new(["soap4r-curb-#{basename}-", '.pem'])
    f.write(openssl_obj.to_pem)
    f.close
    # The finalizer proc must not be created in an instance-method context
    # closing over self -- that makes self itself unreachable-but-not-quite
    # (reachable only via its own finalizer), so it never actually becomes
    # eligible for GC and the finalizer never runs (confirmed: Ruby warns
    # "finalizer references object to be finalized" and the tempfile never
    # got cleaned up). Building the proc in a class method keeps the
    # closure's only capture to f, not self.
    ObjectSpace.define_finalizer(self, self.class.tempfile_unlinker(f))
    f.path
  end

  def self.tempfile_unlinker(file)
    proc { file.unlink rescue nil }
  end

  def dump_wiredump(curl, req_body)
    # Mirrors httpclient's wiredump block layout (marker line, blank line,
    # raw request-line + headers, blank line, body) -- callers that parse
    # wiredump_dev output by block position or by scanning for a "POST ..."
    # line (e.g. test/soap/test_streamhandler.rb's parse_req_header) depend
    # on that exact shape regardless of which backend produced it.
    uri = URI.parse(curl.url)
    request_line = (curl.proxy_url ? curl.url : uri.request_uri)
    @debug_dev << "= Request\n\n"
    @debug_dev << "POST #{request_line} HTTP/1.1\n"
    curl.headers.each { |k, v| @debug_dev << "#{k}: #{v}\n" }
    @debug_dev << "\n"
    @debug_dev << req_body
    @debug_dev << "\n\n= Response\n\n"
    @debug_dev << "HTTP/1.1 #{curl.response_code} #{Response.reason_from_header_str(curl.header_str)}\n"
    @debug_dev << "Content-Type: #{curl.content_type}\n" if curl.content_type
    @debug_dev << "\n"
    @debug_dev << curl.body
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
    attr_accessor :client_cert
    attr_accessor :client_key
    attr_accessor :client_ca
    attr_accessor :verify_mode
    attr_accessor :verify_depth	# not directly settable via libcurl's simpler peer/host verify model; stored only.
    attr_accessor :options		# ditto -- no libcurl equivalent to OpenSSL::SSL::SSLContext#options.
    attr_accessor :ciphers
    attr_accessor :verify_callback	# not supported -- libcurl has no per-certificate Ruby callback hook.
    attr_accessor :cert_store		# not supported -- libcurl manages its own trust store internally.
    attr_reader :ca_file

    def set_trust_ca(value)
      @ca_file = value
    end

    def set_crl(value)
      @crl = value	# not applied -- libcurl has no direct CRL-file option exposed via curb.
    end

    # curb/libcurl never bundles its own CA snapshot the way httpclient
    # does (see lib/soap/httpconfigloader.rb) -- unless #set_trust_ca
    # overrides it, it always defers to whatever CA bundle libcurl itself
    # was built against (the system's, on every mainstream Linux
    # distribution), so there's nothing to override here.
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

    def self.from_curl(curl)
      header = parse_headers(curl.header_str)
      reason = reason_from_header_str(curl.header_str)
      new(curl.response_code, reason, curl.content_type, header, curl.body)
    end

    # curb has no accessor for the HTTP reason phrase (e.g. "OK", "Not
    # Found") separate from the numeric status -- pull it off the first
    # line of the raw header block ourselves ("HTTP/1.1 200 OK" -> "OK").
    # With redirects (multiple status lines in header_str, one per hop)
    # this reads the LAST one, matching #parse_headers below which also
    # only reflects the final response's headers.
    def self.reason_from_header_str(header_str)
      return nil unless header_str
      line = header_str.each_line.select { |l| l.start_with?('HTTP/') }.last
      return nil unless line
      line.strip.split(' ', 3)[2]
    end

    # curb only exposes the raw response header block (#header_str), not a
    # parsed hash -- build one ourselves, keyed lowercase like
    # streamHandler.rb expects (it reads header['content-encoding'][0] and
    # header['location'][0] directly), with an Array of values per key to
    # match the other backends' Hash-of-Arrays shape.
    def self.parse_headers(header_str)
      result = Hash.new { |h, k| h[k] = [] }
      return result unless header_str
      header_str.each_line do |line|
        line = line.strip
        next if line.empty? || line.start_with?('HTTP/')
        key, value = line.split(':', 2)
        next unless key && value
        result[key.strip.downcase] << value.strip
      end
      result
    end
  end
end


end
