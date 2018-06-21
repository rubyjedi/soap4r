$:.unshift File.expand_path("../lib", __FILE__)
require 'soap/version'

Gem::Specification.new do |s|
  s.name = 'soap4r-ng'
  s.version = SOAP::VERSION::STRING

  s.authors = "Laurence A. Lee, Hiroshi NAKAMURA"
  s.email = "rubyjedi@gmail.com, nahi@ruby-lang.org"
  s.homepage = "http://rubyjedi.github.io/soap4r/"
  s.license = "Ruby"

  s.summary     = "Soap4R-ng - Soap4R (as maintained by RubyJedi) for Ruby 1.8 thru 2.1 and beyond"
  s.description = "Soap4R NextGen (as maintained by RubyJedi) for Ruby 1.8 thru 2.1 and beyond"

  s.requirements << 'none'
  s.require_path = 'lib'

  s.files = `git ls-files lib bin`.split("\n")
  s.executables = [ "wsdl2ruby.rb", "xsd2ruby.rb" ]
end
