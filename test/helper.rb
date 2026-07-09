# encoding: UTF-8

# On Ruby < 2.3, Thread::Mutex is not a real, cached constant -- every
# reference to it re-runs an internal deprecated-constant bridge (resolving
# via the real toplevel ::Mutex) and prints a warning, every single time,
# not just once. httpclient depends on the standalone 'mutex_m' gem (unlike
# Ruby's own bundled mutex_m.rb, which uses bare Mutex and never hits this),
# and that gem's Mutex_m#mu_initialize references Thread::Mutex on every
# single object construction (e.g. every Logger.new) -- confirmed this was
# responsible for ~2900 warning lines in one CI run across just these 4
# Ruby versions. Defining it for real, once, before anything else runs,
# makes every later reference an ordinary constant lookup with no bridge
# and no warning.
if RUBY_VERSION.to_f > 1.8 && defined?(::Mutex) && !Thread.const_defined?(:Mutex, false)
  Thread.const_set(:Mutex, ::Mutex)
end

require 'test/unit'
require 'test/unit/xml' ## RubyJedi

if RUBY_VERSION.to_f >= 1.9
  require 'simplecov'
  SimpleCov.start
end

ENV['DEBUG_SOAP4R'] = 'true' ## Needed to force wsdl2ruby.rb and xsd2ruby.rb to use DEVELOPMENT soap4r libs instead of installed soap4r libs
$DEBUG = !!ENV['WIREDUMPS']

# see https://bugs.ruby-lang.org/issues/13181 & https://github.com/ruby/ruby/commit/86bfcc2da0
RUBY_GEM_VERSION = Gem::Version.new(RUBY_VERSION.dup) # .dup: RUBY_VERSION is frozen, and old RubyGems' Version#initialize mutates its argument in place
RESCUE_LINE_NUMBERS_FIXED = (RUBY_GEM_VERSION >= Gem::Version.new('2.4.3')) || (RUBY_GEM_VERSION >= Gem::Version.new('2.3.6') && RUBY_GEM_VERSION < Gem::Version.new('2.4.0'))
