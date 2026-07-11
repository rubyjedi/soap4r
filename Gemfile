source 'http://rubygems.org'

if RUBY_VERSION.to_f <= 1.8
  gem 'htmlentities', '4.3.1'       # Require this if OxParser's built-in "Special Character" conversion isn't sufficient for your needs.
  gem 'httpclient', '~> 2.7.0.1'
else
  gem 'httpclient'   # 2.1.5.2
  gem 'htmlentities', '~> 4.3.3'    # Require this if OxParser's built-in "Special Character" conversion isn't sufficient for your needs.
end

# ---------------------------------------------------------------------------
# Additional (opt-in) HTTP client backends -- see "HTTP Client Backends" in
# README.md and lib/soap/httpbackend.rb. Neither is installed by default:
# `bundle install` alone skips these groups entirely (Bundler's own
# `optional: true`), since curb needs a system libcurl-dev present at
# compile time (unlike the httpclient/net_http backends above, which need
# nothing beyond Ruby itself) and both are meant to be picked deliberately,
# not forced on every contributor who never touches them. Install with:
#   bundle install --with http_curb http_faraday
# curb has no JRuby port at all (same reason ox/libxml-ruby are excluded
# there -- no native-extension support on JRuby) and hasn't been validated
# against this project's full legacy-Ruby matrix (1.8.7-2.1.x); it's gated
# to a modern floor here rather than guessing at older compatibility.
group :http_curb, :optional => true do
  # Gated to >= 2.4, not >= 2.2: curb's C extension (curb.c) references
  # CURL_SSLVERSION_MAX_* constants that don't exist before libcurl 7.54.0,
  # and the official ruby:2.2.10/ruby:2.3.8 Docker Hub images' system
  # libcurl-dev predates that -- confirmed a hard compile failure there,
  # not a graceful skip. ruby:2.4.10's image has a new-enough libcurl-dev;
  # everything from there up compiles cleanly.
  gem 'curb' if RUBY_PLATFORM !~ /java/ && RUBY_VERSION.to_f >= 2.4
end
group :http_faraday, :optional => true do
  gem 'faraday'
  # faraday-net_http ships as faraday's own default-adapter dependency
  # already. faraday-typhoeus is this project's real second spot-check
  # adapter for the same bridge code (see lib/soap/faradayClient.rb,
  # SOAP4R_FARADAY_ADAPTER) -- chosen over faraday-patron because it's the
  # adapter people actually use in practice (28 reverse dependencies on
  # RubyGems vs. patron's 3 -- see Ruby Toolbox). typhoeus/ethon load
  # libcurl via FFI at runtime rather than compiling against it, so no
  # libcurl-dev is needed to install this one, just the runtime .so
  # (already present wherever curb's libcurl-dev is installed).
  # Gated to >= 2.6, not the >= 2.2 floor everything else in this group
  # uses: faraday-typhoeus's oldest release still on RubyGems (1.0.0) pulls
  # in a current, unconstrained `logger` needing Ruby >= 2.5, and its next
  # release (1.1.0) directly requires Ruby >= 2.6 itself -- there's no
  # version of faraday-typhoeus left that installs cleanly below that,
  # confirmed empirically. Same "modern floor" reasoning already used for
  # curb above, not a guess.
  gem 'faraday-typhoeus' if RUBY_PLATFORM !~ /java/ && RUBY_VERSION.to_f >= 2.6
  gem 'typhoeus' if RUBY_PLATFORM !~ /java/ && RUBY_VERSION.to_f >= 2.6
  # ethon (typhoeus's own dependency) pulls in ffi unconstrained; current
  # ffi releases need Ruby >= 3.0 (1.17+) -- Bundler's resolver has no way
  # to know that from the >= 2.6 gate above alone. Confirmed this hard-fails
  # `bundle install` (not a graceful per-gem skip) on 2.6.10 without an
  # explicit pin. 1.12.2 is the newest release confirmed installable there.
  gem 'ffi', '~> 1.12.2' if RUBY_PLATFORM !~ /java/ && RUBY_VERSION.to_f >= 2.6 && RUBY_VERSION.to_f < 3.0
  # faraday-patron is kept as a third, optional spot-check adapter --
  # libcurl-based like curb, but through a different, considerably less
  # popular gem (3 reverse dependencies) with its own quirks (see
  # SOAP4R_FARADAY_ADAPTER=patron and "Known Test Suite Exceptions" in
  # README.md). Gated to >= 2.4, not the >= 2.2 floor everything else in
  # this group uses: confirmed faraday-patron has no release compatible
  # with 2.2/2.3 at all (1.0.0, its oldest ever published version, already
  # requires Ruby >= 2.4) -- this hard-fails `bundle install` on 2.2.10/
  # 2.3.8 otherwise, not a graceful per-gem skip.
  gem 'faraday-patron' if RUBY_PLATFORM !~ /java/ && RUBY_VERSION.to_f >= 2.4
  gem 'patron' if RUBY_PLATFORM !~ /java/ && RUBY_VERSION.to_f >= 2.4
  # lib/soap/faradayClient.rb needs this for its own manual Basic-auth
  # header encoding -- same early-demotion behavior as logger/getoptlong
  # below (a plain `require 'base64'` starts warning, then fails outright
  # once Bundler enforces the Gemfile.lock, on Ruby >= 3.4).
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
elsif RUBY_VERSION.to_f >= 2.2
  gem 'ox'                          # oxparser ; Uses its own custom C-library
else
  # current ox needs rb_utf8_str_new (Ruby >= 2.2); older Rubies fail with
  # an unresolvable-symbol crash at native-ext load time (not a catchable
  # LoadError). 2.4.5 predates that and is already the known-good pin used
  # for Ruby <= 1.8 above; it also covers 1.9.x - 2.1.x.
  #
  # Must be pinned exactly ("= 2.4.5", not "~> 2.4.5"): later 2.4.x patches
  # (confirmed with 2.4.13) hit a second, different unresolvable-symbol
  # crash of their own (RSTRUCT_GET) on these old Rubies, so a floating
  # patch-level constraint silently re-breaks this the same way.
  gem 'ox', '= 2.4.5'
end

if RUBY_VERSION.to_f <= 1.8
  gem 'nokogiri', '~> 1.5.11'       # nokogiriparser ; Uses libxml2, libxslt, and zlib
elsif RUBY_VERSION.to_f <= 2.2
  gem 'nokogiri', '~> 1.6.6'        # nokogiriparser ; Uses libxml2, libxslt, and zlib
else
  gem 'nokogiri'                    # let Bundler pick a version compatible with the running Ruby
end

if RUBY_PLATFORM =~ /java/
  # libxml-jruby's one and only release is from 2010 and calls
  # `include_class`, a JRuby API removed long ago -- it's a NoMethodError at
  # require time (not a catchable LoadError) on any current JRuby, and
  # there's no newer version or replacement gem to pin instead. Leaving
  # libxmlparser unavailable here is consistent with ox above, which simply
  # has no JRuby port either.
elsif RUBY_VERSION.to_f <= 1.9
  gem 'libxml-ruby', '~> 2.8.0'
else
  gem 'libxml-ruby', '~> 3.1.0'
end

if RUBY_VERSION.to_f > 1.8
  # oga itself supports Ruby >= 1.9.3, but its own `ruby-ll` dependency
  # constraint (~> 2.1) permits drifting all the way up to ruby-ll 2.2.0,
  # whose C ext needs RUBY_TYPED_FREE_IMMEDIATELY (Ruby >= 2.1) -- Bundler
  # has no way to know that from the declared constraint alone. Pin ruby-ll
  # directly to the last release that still declares Ruby >= 1.9.3 support.
  gem 'ruby-ll', '~> 2.1.2' if RUBY_VERSION.to_f < 2.1
  gem 'oga'                         # ogaparser ; Pure-Ruby Alternative
end

if RUBY_VERSION.to_f > 1.8
  # rexml/webrick/logger were all implicit default gems once, pulled in
  # automatically without a Gemfile entry -- but only up to the Ruby version
  # where each was demoted to a bundled gem (rexml/webrick: 3.0, logger: 4.0).
  # Below that floor they're still implicitly available and don't need (or
  # want) a Gemfile entry: rubygems.org only hosts *current* rexml/webrick/
  # logger releases, built with syntax (e.g. `**opts`, `&.`) that predates-Ruby
  # can't even parse, so pulling them in unconditionally shadows a perfectly
  # working built-in with a gem that hard-crashes at require time.
  gem 'rexml' if RUBY_VERSION.to_f >= 3.0   # no longer an implicit default gem under Bundler as of Ruby 3.0
  gem 'webrick' if RUBY_VERSION.to_f >= 3.0 # same; needed by lib/soap/rpc/{httpserver,cgistub,soaplet}.rb
  # dropped in Ruby 4.0, but the "will no longer be part of the default
  # gems" notice itself already starts firing a full version earlier, on a
  # plain `require 'logger'` with no Bundler pinning involved at all --
  # confirmed silent on 3.1.7/3.2.11/3.3.11, present starting 3.4.10. Gated
  # here from 3.4 (not 4.0) to actually silence it, matching getoptlong
  # below which has the same early-warning behavior.
  gem 'logger' if RUBY_VERSION.to_f >= 3.4
  gem 'getoptlong' if RUBY_VERSION.to_f >= 3.4 # same; bin/{xsd2ruby,wsdl2ruby}.rb both need it unconditionally
  gem 'logger-application', :require=>'logger-application'
end

## # Testing Support ###
group :test do
  if RUBY_VERSION.to_f <= 1.8
    gem 'test-unit', '~> 1.2.3'
    gem 'rake', '~> 10.4.2'
    # test-unit 1.2.3 lists hoe as a *runtime* dependency (a common
    # old-ecosystem quirk from that era); hoe's current release needs
    # Ruby >= 2.7, so pin the oldest version that still satisfies
    # test-unit's own floor (>= 1.5.1). hoe in turn pulls in rubyforge,
    # which pulls in json_pure -- same story, pin that too.
    gem 'hoe', '1.5.1'
    gem 'json_pure', '~> 1.7.6'
  elsif RUBY_VERSION.to_f <= 1.9
    # current test-unit (like rexml/webrick/logger above) is built with
    # Ruby >=2.0 keyword-argument syntax and is a SyntaxError on 1.9.3; pin an
    # old-enough release instead of relying on Bundler to steer around it.
    gem 'test-unit', '~> 3.0.5'
    gem 'rake'
  else
    gem 'test-unit'
    gem 'rake'
  end
  # test-unit pulls in power_assert, which pulls in ansi -- ansi 1.6.0 needs
  # Ruby >= 3.1, and Bundler's resolver picks it for some Ruby versions in
  # our supported range (2.3.8 confirmed) but not others (2.2.10, 1.9.3
  # both land on the older, compatible 1.5.0) depending on how the rest of
  # the bundle resolves. Pin it directly rather than rely on that.
  gem 'ansi', '~> 1.5.0' if RUBY_VERSION.to_f < 3.1
  # Not used directly anywhere in this codebase -- it's here only because
  # simplecov (below) depends on 'json' unconstrained, and current json
  # releases use **opts keyword-splat syntax that's a SyntaxError on Ruby
  # <= 1.9. Without this pin Bundler resolves json 2.3.0 even on 1.9.3 and
  # every test run fails at require time before a single test executes.
  gem 'json', '~> 1.8' if RUBY_VERSION.to_f <= 1.9
  gem 'rubyjedi-testunitxml', :git=>'https://github.com/rubyjedi/testunitxml.git', :branch=>'master'
  # test/helper.rb requires this directly (RUBY_VERSION.to_f >= 1.9); it used
  # to arrive only transitively via codeclimate-test-reporter, so removing
  # that gem means it needs its own declaration now. Pinned to the exact
  # version that dependency always resolved to, since that's what every
  # Ruby version in this project's test matrix has actually been verified
  # against.
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
