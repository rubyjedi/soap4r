require 'test/unit'
require 'rubygems'
require 'test/unit/xml' ## RubyJedi

# $:.unshift File.dirname(__FILE__) + '/../lib' # needed for TestMapper under Ruby 1.8

ENV['DEBUG_SOAP4R'] = 'true' ## Needed to force wsdl2ruby.rb and xsd2ruby.rb to use DEVELOPMENT soap4r libs instead of installed soap4r libs