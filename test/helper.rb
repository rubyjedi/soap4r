# encoding: UTF-8
require 'test/unit'
require 'test/unit/xml' ## RubyJedi

if RUBY_VERSION.to_f >= 1.9
  require 'simplecov'
  SimpleCov.start
end

ENV['DEBUG_SOAP4R'] = 'true' ## Needed to force wsdl2ruby.rb and xsd2ruby.rb to use DEVELOPMENT soap4r libs instead of installed soap4r libs
$DEBUG = !!ENV['WIREDUMPS']

# see https://bugs.ruby-lang.org/issues/13181 & https://github.com/ruby/ruby/commit/86bfcc2da0
RUBY_GEM_VERSION = Gem::Version.new(RUBY_VERSION)
RESCUE_LINE_NUMBERS_FIXED = (RUBY_GEM_VERSION >= Gem::Version.new('2.4.3')) || (RUBY_GEM_VERSION >= Gem::Version.new('2.3.6') && RUBY_GEM_VERSION < Gem::Version.new('2.4.0'))
