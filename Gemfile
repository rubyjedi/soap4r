source 'http://rubygems.org'

if RUBY_VERSION.to_f <= 1.8
  gem 'htmlentities', '4.3.1'       # Require this if OxParser's built-in "Special Character" conversion isn't sufficient for your needs.
  gem 'httpclient', '~> 2.7.0.1'
else
  gem 'httpclient'   # 2.1.5.2
  gem 'htmlentities', '~> 4.3.3'    # Require this if OxParser's built-in "Special Character" conversion isn't sufficient for your needs.
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
  gem 'ox', '~> 2.4.5'
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
