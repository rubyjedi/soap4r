#!/usr/bin/env ruby

require 'getoptlong'
require 'rbconfig'
require 'ftools'

OptSet = [
  ['--prefix','-p', GetoptLong::REQUIRED_ARGUMENT],
]
prefix = nil
GetoptLong.new(*OptSet).each do |name, arg|
  case name
  when "--prefix"
    prefix = arg
  else
    raise ArgumentError.new("Unknown type #{ arg }")
  end
end

include Config
RV = CONFIG["MAJOR"] + "." + CONFIG["MINOR"]
ORG_PREFIX = CONFIG["prefix"]
SRCPATH = File.join(File.dirname($0), 'lib')

RUBYLIBDIR = CONFIG["rubylibdir"]
SITELIBDIR = CONFIG["sitedir"] + "/" +  RV 

if prefix
  RUBYLIBDIR.sub!(/^#{Regexp.quote(ORG_PREFIX)}/, prefix)
  SITELIBDIR.sub!(/^#{Regexp.quote(ORG_PREFIX)}/, prefix)
end

def install(from, to)
  to_path = File.catname(from, to)
  unless FileTest.exist?(to_path) and File.compare(from, to_path)
    File.install(from, to_path, 0644, true)
  end
end

def install_dir(srcbase, *path)
  from_path = File.join(srcbase, *path)
  unless FileTest.directory?(from_path)
    raise RuntimeError.new("'#{ from_path }' not found.")
  end
  to_path_rubylib = File.join(RUBYLIBDIR, *path)
  to_path_sitelib = File.join(SITELIBDIR, *path)
  Dir[File.join(from_path, '*.rb')].each do |from_file|
    basename = File.basename(from_file)
    to_file_rubylib = File.join(to_path_rubylib, basename)
    to_file_sitelib = File.join(to_path_sitelib, basename)
    if File.exist?(to_file_rubylib)
      if File.exist?(to_file_sitelib)
        raise RuntimeError.new(
          "trying to install '#{ to_file_rubylib }' but '#{ to_file_sitelib }' exists.  please remove '#{ to_file_sitelib }' first to avoid versioning problem and run installer again.")
      end
      install(from_file, to_path_rubylib)
    else
      File.mkpath(to_path_sitelib, true)
      install(from_file, to_path_sitelib)
    end
  end
end

begin
  install_dir(SRCPATH, 'soap')
  install_dir(SRCPATH, 'soap', 'rpc')
  install_dir(SRCPATH, 'soap', 'mapping')
  install_dir(SRCPATH, 'soap', 'encodingstyle')
  install_dir(SRCPATH, 'soap', 'header')
  install_dir(SRCPATH, 'soap', 'filter')
  install_dir(SRCPATH, 'wsdl')
  install_dir(SRCPATH, 'wsdl', 'xmlSchema')
  install_dir(SRCPATH, 'wsdl', 'soap')
  install_dir(SRCPATH, 'xsd')
  install_dir(SRCPATH, 'xsd', 'codegen')
  install_dir(SRCPATH, 'xsd', 'xmlparser')

  # xmlscan
  xmlscansrcdir = File.join('redist', 'xmlscan', 'xmlscan-20050522', 'lib')
  if File.exist?(xmlscansrcdir)
    install_dir(xmlscansrcdir, 'xmlscan')
  end

  puts "install succeed!"

rescue 
  puts "install failed!"
  puts $!

end
