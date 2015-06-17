require 'rubygems'
require File.join(File.dirname(__FILE__), 'lib', 'soap', 'version')

PKG_NAME      = 'soap4r-ng'
PKG_BUILD     = ENV['PKG_BUILD'] ? ".#{ENV['PKG_BUILD']}" : ".#{Time.now.strftime('%Y%m%d%H%M%S')}"
PKG_VERSION   = '2.0.1'

SPEC = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name = PKG_NAME
  s.summary = "Soap4R-ng is Soap4R (As maintained by Rubyjedi) for Ruby 1.8.7 thru 2.1 and Beyond"
  s.version = PKG_VERSION

  s.author = "Laurence A. Lee, Hiroshi NAKAMURA"
  s.email = "rubyjedi@gmail.com, nahi@ruby-lang.org"
  s.homepage = "http://rubyjedi.github.io/soap4r/"

  s.add_dependency("httpclient", "~> 2.6.0.1")

  s.has_rdoc = false # disable rdoc generation until we've got more
  s.requirements << 'none'
  s.require_path = 'lib'

  s.executables = [ "wsdl2ruby.rb", "xsd2ruby.rb" ]
  s.files = Dir.glob("{bin,lib,test}/**/*").delete_if { |item| item.match( /\.(svn|git)/ ) }

  # don't reference the test until we see it execute fully and successfully
  # s.test_file = "test/runner.rb"
end
