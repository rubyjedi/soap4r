source 'http://rubygems.org'

if RUBY_VERSION.to_f > 1.8
  gem 'httpclient'   # 2.1.5.2
else
  gem 'httpclient', '~> 2.7.0.1'
end

# ---------------------------------------------------------------------------
# Additional (opt-in) HTTP client backends -- see "HTTP Client Backends" in
# README.md and lib/soap/httpbackend.rb. Not installed by default; requires
# curb needs a system libcurl-dev at compile time. Install with:
#   bundle install --with http_curb http_faraday
# Neither has a JRuby port (no native-extension support there).
group :http_curb, :optional => true do
  # >= 2.4: curb.c needs CURL_SSLVERSION_MAX_* (libcurl >= 7.54.0), which
  # predates the system libcurl-dev on ruby:2.2.10/2.3.8's Docker images.
  # See CHANGELOG.md.
  gem 'curb' if RUBY_PLATFORM !~ /java/ && RUBY_VERSION.to_f >= 2.4
end
group :http_faraday, :optional => true do
  # >= 2.6: an enhancement for modern Rubies, not a legacy capability --
  # older Faraday releases don't match lib/soap/faradayClient.rb's adapter
  # architecture. See CHANGELOG.md.
  gem 'faraday' if RUBY_VERSION.to_f >= 2.6
  # faraday-typhoeus is the real second adapter this project tests against
  # (see SOAP4R_FARADAY_ADAPTER in lib/soap/faradayClient.rb).
  gem 'faraday-typhoeus' if RUBY_PLATFORM !~ /java/ && RUBY_VERSION.to_f >= 2.6
  gem 'typhoeus' if RUBY_PLATFORM !~ /java/ && RUBY_VERSION.to_f >= 2.6
  # ethon (typhoeus's dep) pulls in an unconstrained ffi needing Ruby >= 3.0;
  # pin the newest release that still installs below that.
  gem 'ffi', '~> 1.12.2' if RUBY_PLATFORM !~ /java/ && RUBY_VERSION.to_f >= 2.6 && RUBY_VERSION.to_f < 3.0
  # faraday-patron: third, optional spot-check adapter (see
  # SOAP4R_FARADAY_ADAPTER=patron).
  gem 'faraday-patron' if RUBY_PLATFORM !~ /java/ && RUBY_VERSION.to_f >= 2.6
  gem 'patron' if RUBY_PLATFORM !~ /java/ && RUBY_VERSION.to_f >= 2.6
  # faradayClient.rb's manual Basic-auth header encoding needs this from
  # Ruby >= 3.4 (see logger/getoptlong below for the same demotion pattern).
  gem 'base64' if RUBY_VERSION.to_f >= 3.4
end

# ---------------------------------------------------------------------------
# XML parser backends, declared in the same precedence order xsd/xmlparser.rb
# tries them in (see its parser_list): oxparser, nokogiriparser,
# libxmlparser, ogaparser, rexmlparser.
# ---------------------------------------------------------------------------

if RUBY_PLATFORM =~ /java/
  # ox has no JRuby port at all -- nothing to require here; oxparser will
  # gracefully report unavailable via xsd/xmlparser.rb's parser cascade.
elsif RUBY_VERSION.to_f >= 2.7
  gem 'ox'                          # oxparser ; Uses its own custom C-library
elsif RUBY_VERSION.to_f >= 2.2
  # Ruby 2.2.x - 2.6.x: unconstrained resolves Ox 2.14.14, the newest release
  # before Ox's own gemspec required Ruby >= 2.7. 2.14.14 segfaults inside
  # Ox.sax_parse's :convert_special => true path on complex documents
  # (confirmed via test_mapping.rb on 2.2.10/2.3.8/2.4.10/2.6.10) --
  # htmlentities avoids that path entirely (see oxparser.rb), so it's a
  # required workaround here, not an optional speed boost.
  gem 'ox'
  gem 'htmlentities', '~> 4.3.3'
elsif RUBY_VERSION.to_f > 1.8
  # Ruby 1.9.3 - 2.1.x: newest Ox that loads without the rb_utf8_str_new
  # crash here and decodes named entities natively (htmlentities not
  # needed). Confirmed empirically -- 2.14.7 introduces the crash. Pin
  # exact: patch releases matter here.
  gem 'ox', '= 2.14.6'
else
  # Ruby 1.8.7: 2.14.6's extconf.rb fails to build here (unrelated build
  # tooling issue), so fall back to 2.4.5. Pin exact: 2.4.13 hits a
  # different crash (RSTRUCT_GET) elsewhere in this range.
  gem 'ox', '= 2.4.5'
  # Only needed here: 2.4.5 decodes just the 5 basic XML entities, not the
  # full named set. 4.3.1 pinned -- 4.3.3+ needs Encoding, absent on 1.8.7.
  gem 'htmlentities', '4.3.1'
end

if RUBY_VERSION.to_f > 2.2
  gem 'nokogiri'                    # let Bundler pick a version compatible with the running Ruby
elsif RUBY_VERSION.to_f > 1.8
  gem 'nokogiri', '~> 1.6.6'        # nokogiriparser ; Uses libxml2, libxslt, and zlib
else
  gem 'nokogiri', '~> 1.5.11'       # nokogiriparser ; Uses libxml2, libxslt, and zlib
end

if RUBY_PLATFORM =~ /java/
  # libxml-jruby's only release (2010) calls a since-removed JRuby API
  # (NoMethodError at require time) -- no replacement exists, so libxmlparser
  # is simply unavailable here, same as ox above.
elsif RUBY_VERSION.to_f > 1.9
  gem 'libxml-ruby', '~> 3.1.0'
else
  gem 'libxml-ruby', '~> 2.8.0'
end

if RUBY_VERSION.to_f > 1.8
  # oga's own ruby-ll dependency (~> 2.1) can drift to 2.2.0, whose C ext
  # needs RUBY_TYPED_FREE_IMMEDIATELY (Ruby >= 2.1). Pin the last ruby-ll
  # release that still supports Ruby >= 1.9.3.
  gem 'ruby-ll', '~> 2.1.2' if RUBY_VERSION.to_f < 2.1
  gem 'oga'                         # ogaparser ; Pure-Ruby Alternative
end

if RUBY_VERSION.to_f > 1.8
  # rexml/webrick/logger were implicit default gems until demoted to bundled
  # gems (rexml/webrick: Ruby 3.0, logger: 4.0). Below that floor they're
  # still built in and must NOT get a Gemfile entry: current releases on
  # rubygems.org use syntax predates-Ruby can't parse.
  gem 'rexml' if RUBY_VERSION.to_f >= 3.0
  gem 'webrick' if RUBY_VERSION.to_f >= 3.0 # needed by lib/soap/rpc/{httpserver,cgistub,soaplet}.rb
  # logger's deprecation warning starts firing a version early (3.4, not
  # 4.0) on a plain `require` with no pinning at all; gated here to silence
  # it, matching getoptlong below.
  gem 'logger' if RUBY_VERSION.to_f >= 3.4
  gem 'getoptlong' if RUBY_VERSION.to_f >= 3.4 # bin/{xsd2ruby,wsdl2ruby}.rb need it unconditionally
  gem 'logger-application', :require=>'logger-application'
end

## # Testing Support ###
group :test do
  if RUBY_VERSION.to_f > 1.9
    gem 'test-unit'
    gem 'rake'
  elsif RUBY_VERSION.to_f > 1.8
    # current test-unit uses Ruby >= 2.0 keyword-argument syntax (SyntaxError
    # on 1.9.3); pin an old-enough release.
    gem 'test-unit', '~> 3.0.5'
    gem 'rake'
  else
    gem 'test-unit', '~> 1.2.3'
    gem 'rake', '~> 10.4.2'
    # test-unit 1.2.3 lists hoe as a runtime dependency; current hoe needs
    # Ruby >= 2.7, so pin the oldest release satisfying test-unit's floor
    # (>= 1.5.1). hoe pulls in rubyforge -> json_pure; pin that too.
    gem 'hoe', '1.5.1'
    gem 'json_pure', '~> 1.7.6'
  end
  # test-unit -> power_assert -> ansi; ansi 1.6.0 needs Ruby >= 3.1 and
  # Bundler's resolver doesn't always avoid it below that. Pin directly.
  gem 'ansi', '~> 1.5.0' if RUBY_VERSION.to_f < 3.1
  # Not used directly -- simplecov (below) depends on unconstrained 'json',
  # whose current releases use **opts syntax (SyntaxError on Ruby <= 1.9).
  gem 'json', '~> 1.8' if RUBY_VERSION.to_f <= 1.9
  gem 'rubyjedi-testunitxml', :git=>'https://github.com/rubyjedi/testunitxml.git', :branch=>'master'
  # test/helper.rb requires this directly; pinned to the version this
  # project's test matrix has actually been verified against.
  gem 'simplecov', '0.13.0' if RUBY_VERSION.to_f >= 1.9

  ### Misc Debugging Aids ###
  # gem 'awesome_print'
  # gem 'rcov'                       # Coverage Test scoring, for more confidence. Do a 'rake rcov:rcov' to yield coverage results.
  # gem 'pry'                        ## see also: pry-debugger for Ruby 1.9 and lower; and pry-byebug for 2.0 and higher (requires byebug gem also)
  # gem 'ruby-termios'               # Unroller requires this . . .
  # gem 'unroller', :git=>'https://github.com/jayjlawrence/unroller.git', :branch=>'master'

  # byebug's C ext needs MRI's ruby.h, which doesn't exist on JRuby -- these
  # are just debugging conveniences, not required for tests to run.
  if RUBY_VERSION.to_f >= 2.0 && RUBY_PLATFORM !~ /java/
    gem 'pry-byebug'
    gem 'byebug'
  end
  gem 'soap4r-ng', :path=>'.'  # Make our development copy (this directory) available as a Gem via Bundler. Useful for running tests.
end
