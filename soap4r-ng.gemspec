$:.unshift File.expand_path("../lib", __FILE__)
require 'soap/version'

SPEC = Gem::Specification.new do |s|
  s.name = 'soap4r-ng'
  s.version = SOAP::VERSION::STRING
  s.summary = "Soap4R-ng - Soap4R (as maintained by RubyJedi) for Ruby 1.8 thru 2.1 and beyond"

  s.authors = "Laurence A. Lee, Hiroshi NAKAMURA"
  s.email = "rubyjedi@gmail.com, nahi@ruby-lang.org"
  s.homepage = "http://rubyjedi.github.io/soap4r/"

  s.add_dependency("httpclient", "~> 2.6")
  s.add_dependency("logger-application", "~> 0.0.2")

  s.has_rdoc = false # disable rdoc generation until we've got more
  s.requirements << 'none'
  s.require_path = 'lib'

  s.files = `git ls-files lib bin`.split("\n")
  s.executables = [ "wsdl2ruby.rb", "xsd2ruby.rb" ]
end
