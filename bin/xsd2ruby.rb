#!/usr/bin/env ruby

require 'getoptlong'
require 'logger'
require 'xsd/qname'
require 'xsd/codegen/gensupport'
require 'wsdl/xmlSchema/parser'
require 'wsdl/importer'
require 'wsdl/soap/classDefCreator'

class XSD2RubyApp < Logger::Application
private

  OptSet = [
    ['--xsd','-x', GetoptLong::REQUIRED_ARGUMENT],
    ['--classname','-n', GetoptLong::NO_ARGUMENT],
    ['--force','-f', GetoptLong::NO_ARGUMENT],
    ['--quiet','-q', GetoptLong::NO_ARGUMENT],
  ]

  def initialize
    super('app')
    @xsd_location = nil
    @opt = nil
    @xsd = nil
    @name = nil
    self.level = Logger::FATAL
  end

  def run
    @xsd_location, @opt = parse_opt(GetoptLong.new(*OptSet))
    if @opt['quiet']
      self.level = Logger::FATAL
    else
      self.level = Logger::INFO
    end
    usage_exit unless @xsd_location
    @xsd = import(@xsd_location)
    @name = create_classname(@xsd)
    create_file
    0
  end

  def create_file
    create_classdef
  end

  def usage_exit
    puts <<__EOU__
Usage: #{ $0 } --xsd xsd_location [options]
  xsd_location: filename or URL

Example:
  #{ $0 } --xsd myapp.xsd --classname Foo

Options:
  --xsd xsd_location
  --classname classname
  --force
  --quiet
__EOU__
    exit 1
  end

  def parse_opt(getoptlong)
    opt = {}
    xsd = nil
    begin
      getoptlong.each do |name, arg|
       	case name
	when "--xsd"
	  xsd = arg
	when "--classname"
  	  opt[name.sub(/^--/, '')] = arg.empty? ? nil : arg
	when "--force"
	  opt['force'] = true
        when "--quiet"
          opt['quiet'] = true
   	else
  	  raise ArgumentError.new("Unknown type #{ arg }")
   	end
      end
    rescue
      usage_exit
    end
    return xsd, opt
  end

  def create_classdef
    log(INFO) { "Creating class definition." }
    @classdef_filename = @name + '.rb'
    check_file(@classdef_filename) or return
    File.open(@classdef_filename, "w") do |f|
      f << WSDL::SOAP::ClassDefCreator.new(@xsd).dump
    end
  end

  def check_file(filename)
    if FileTest.exist?(filename)
      if @opt.key?('force')
	log(WARN) {
	  "File '#{ filename }' exists but overrides it."
	}
	true
      else
	log(WARN) {
	  "File '#{ filename }' exists.  #{ $0 } did not override it."
	}
	false
      end
    else
      log(INFO) { "Creates file '#{ filename }'." }
      true
    end
  end

  def create_classname(xsd)
    name = xsd.targetnamespace.scan(/[a-zA-Z0-9]+$/)[0]
    if name.nil?
      'default'
    else
      XSD::CodeGen::GenSupport.safevarname(name)
    end
  end

  def import(location)
    WSDL::Importer.import(location)
  end
end

XSD2RubyApp.new.start
