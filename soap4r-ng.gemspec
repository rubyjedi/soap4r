$:.unshift File.expand_path("../lib", __FILE__)
require 'soap/version'

Gem::Specification.new do |s|
  s.name = 'soap4r-ng'
  s.version = SOAP::VERSION::STRING

  s.authors = "Laurence A. Lee, Hiroshi NAKAMURA"
  s.email = "rubyjedi@gmail.com, nahi@ruby-lang.org"
  s.homepage = "http://rubyjedi.github.io/soap4r/"
  s.license = "Ruby"

  s.summary     = "Soap4R-ng - Soap4R (as maintained by RubyJedi) for Ruby 1.8.7 thru 4.0 and beyond"
  s.description = "Soap4R NextGen (as maintained by RubyJedi) for Ruby 1.8.7 thru 4.0 and beyond"

  s.requirements << 'none'
  s.require_path = 'lib'

  # Not `git ls-files` -- that silently returns empty (with only a stderr
  # warning) when built outside a git checkout (vendored copy, downloaded
  # tarball/zip, `bundle package`), which drops the entire lib/ directory
  # from the packaged gem with no build failure to notice it by.
  s.files = Dir.glob('{lib,bin}/**/*')
  s.executables = [ "wsdl2ruby.rb", "xsd2ruby.rb" ]

  # Required unconditionally by the shipped bin/ executables (both
  # httpclient and logger-application) -- without these declared, `gem
  # install soap4r-ng` (which never reads this project's own Gemfile)
  # installs a gem whose executables immediately LoadError. This was
  # reported and reproduced live against current master: GH #23.
  #
  # rexml/webrick/logger are deliberately NOT declared here even though
  # lib/soap/rpc/*.rb needs them on Ruby >= 3.0/4.0: this gemspec's
  # dependency list is static (baked in once at gem-build time), so it
  # can't replicate the Gemfile's `if RUBY_VERSION.to_f >= 3.0` gating.
  # Confirmed empirically that adding them unconditionally breaks Ruby
  # 1.9.3 -- Bundler merges this gemspec's deps into any Gemfile using
  # `gem 'soap4r-ng', :path=>'.'`, bypassing the Gemfile's own version
  # gate entirely and resolving current rexml/webrick/logger releases
  # (**kwargs syntax) that are a SyntaxError on that old a Ruby. Bundler
  # users on Ruby >= 3.0/4.0 must add rexml/webrick/logger to their own
  # Gemfile, exactly as documented in this project's README.
  s.add_runtime_dependency 'httpclient'
  s.add_runtime_dependency 'logger-application'
end
