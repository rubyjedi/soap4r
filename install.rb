#!/usr/bin/env ruby

require 'rbconfig'
require 'ftools'

include Config

RUBYLIBDIR = CONFIG["rubylibdir"]
RV = CONFIG["MAJOR"] + "." + CONFIG["MINOR"]
SITELIBDIR = CONFIG["sitedir"] + "/" +  RV 
SRCPATH = File.join(File.dirname($0), 'lib')

def install(from, to)
  to_path = File.catname(from, to)
  unless FileTest.exist?(to_path) and File.compare(from, to_path)
    File.install(from, to_path, 0644, true)
  end
end

def install_dir(*path)
  from_path = File.join(SRCPATH, *path)
  unless FileTest.directory?(from_path)
    raise RuntimeError.new("'#{ from_path }' not found.")
  end
  to_path_rubylib = File.join(RUBYLIBDIR, *path)
  to_path_sitelib = File.join(SITELIBDIR, *path)
  Dir[File.join(from_path, '*.rb')].each do |name|
    basename = File.basename(name)
    if File.exist?(File.join(to_path_rubylib, basename))
      install(name, to_path_rubylib)
    else
      File.mkpath(to_path_sitelib, true)
      install(name, to_path_sitelib)
    end
  end
end

begin
  install_dir('soap')
  install_dir('soap', 'rpc')
  install_dir('soap', 'mapping')
  install_dir('soap', 'encodingstyle')
  install_dir('soap', 'header')
  install_dir('wsdl')
  install_dir('wsdl', 'xmlSchema')
  install_dir('wsdl', 'soap')
  install_dir('xsd')
  install_dir('xsd', 'xmlparser')

  puts "install succeed!"

rescue 
  puts "install failed!"
  puts $!

end
