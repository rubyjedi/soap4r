#!/usr/bin/env ruby

require 'getoptlong'
require 'logger'
require 'xsd/qname'
require 'wsdl/parser'
require 'wsdl/importer'
require 'wsdl/soap/classDefCreator'
require 'wsdl/soap/servantSkeltonCreator'
require 'wsdl/soap/driverCreator'
require 'wsdl/soap/clientSkeltonCreator'
require 'wsdl/soap/standaloneServerStubCreator'
require 'wsdl/soap/cgiStubCreator'

class WSDL2RubyApp < Logger::Application
private

  OptSet = [
    ['--wsdl','-w', GetoptLong::REQUIRED_ARGUMENT],
    ['--type','-t', GetoptLong::REQUIRED_ARGUMENT],
    ['--classdef','-e', GetoptLong::NO_ARGUMENT],
    ['--client_skelton','-c', GetoptLong::OPTIONAL_ARGUMENT],
    ['--servant_skelton','-s', GetoptLong::OPTIONAL_ARGUMENT],
    ['--cgi_stub','-g', GetoptLong::OPTIONAL_ARGUMENT],
    ['--standalone_server_stub','-a', GetoptLong::OPTIONAL_ARGUMENT],
    ['--driver','-d', GetoptLong::OPTIONAL_ARGUMENT],
    ['--force','-f', GetoptLong::NO_ARGUMENT],
    ['--quiet','-q', GetoptLong::NO_ARGUMENT],
  ]

  def initialize
    super('app')
    STDERR.sync = true
    @wsdl_location = nil
    @opt = nil
    @wsdl = nil
    @name = nil
    self.level = Logger::FATAL
  end

  def run
    @wsdl_location, @opt = parse_opt(GetoptLong.new(*OptSet))
    if @opt['quiet']
      self.level = Logger::FATAL
    else
      self.level = Logger::INFO
    end
    usage_exit unless @wsdl_location
    @wsdl = import(@wsdl_location)
    @name = @wsdl.name ? @wsdl.name.name : 'default'
    create_file
    0
  end

  def create_file
    create_classdef if @opt.key?('classdef')
    create_servant_skelton(@opt['servant_skelton']) if @opt.key?('servant_skelton')
    create_cgi_stub(@opt['cgi_stub']) if @opt.key?('cgi_stub')
    create_standalone_server_stub(@opt['standalone_server_stub']) if @opt.key?('standalone_server_stub')
    create_driver(@opt['driver']) if @opt.key?('driver')
    create_client_skelton(@opt['client_skelton']) if @opt.key?('client_skelton')
  end

  def usage_exit
    puts <<__EOU__
Usage: #{ $0 } --wsdl wsdl_location [options]
  wsdl_location: filename or URL

Example:
  For server side:
    #{ $0 } --wsdl myapp.wsdl --type server
  For client side:
    #{ $0 } --wsdl myapp.wsdl --type client

Options:
  --wsdl wsdl_location
  --type server|client
    --type server implies;
  	--classdef
   	--servant_skelton
    	--standalone_server_stub
    --type client implies;
     	--classdef
      	--client_skelton
       	--driver
  --classdef
  --client_skelton [servicename]
  --servant_skelton [porttypename]
  --cgi_stub [servicename]
  --standalone_server_stub [servicename]
  --driver [porttypename]
  --force
  --quiet

Terminology:
  Client <-> Driver <-(SOAP)-> Stub <-> Servant

  Driver and Stub: Automatically generated
  Client and Servant: Skelton generated (you should change)
__EOU__
    exit 1
  end

  def parse_opt(getoptlong)
    opt = {}
    wsdl = nil
    begin
      getoptlong.each do |name, arg|
       	case name
	when "--wsdl"
	  wsdl = arg
	when "--type"
  	  case arg
  	  when "server"
  	    opt['classdef'] = nil
  	    opt['servant_skelton'] = nil
  	    opt['standalone_server_stub'] = nil
  	  when "client"
  	    opt['classdef'] = nil
  	    opt['driver'] = nil
  	    opt['client_skelton'] = nil
  	  else
  	    raise ArgumentError.new("Unknown type #{ arg }")
  	  end
   	when "--classdef", "--client_skelton", "--servant_skelton",
	    "--cgi_stub", "--standalone_server_stub", "--driver"
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
    return wsdl, opt
  end

  def create_classdef
    log(INFO) { "Creating class definition." }
    @classdef_filename = @name + '.rb'
    check_file(@classdef_filename) or return
    File.open(@classdef_filename, "w") do |f|
      f << WSDL::SOAP::ClassDefCreator.new(@wsdl).dump
    end
  end

  def create_client_skelton(servicename)
    log(INFO) { "Creating client skelton." }
    servicename ||= @wsdl.services[0].name.name
    @client_skelton_filename = servicename + 'Client.rb'
    check_file(@client_skelton_filename) or return
    File.open(@client_skelton_filename, "w") do |f|
      f << shbang << "\n"
      f << "require '#{ @driver_filename }'\n\n" if @driver_filename
      f << WSDL::SOAP::ClientSkeltonCreator.new(@wsdl).dump(
	create_name(servicename))
    end
  end

  def create_servant_skelton(porttypename)
    log(INFO) { "Creating servant skelton." }
    @servant_skelton_filename = (porttypename || @name + 'Servant') + '.rb'
    check_file(@servant_skelton_filename) or return
    File.open(@servant_skelton_filename, "w") do |f|
      f << "require '#{ @classdef_filename }'\n\n" if @classdef_filename
      f << WSDL::SOAP::ServantSkeltonCreator.new(@wsdl).dump(
	create_name(porttypename))
    end
  end

  def create_cgi_stub(servicename)
    log(INFO) { "Creating CGI stub." }
    servicename ||= @wsdl.services[0].name.name
    @cgi_stubFilename = servicename + '.cgi'
    check_file(@cgi_stubFilename) or return
    File.open(@cgi_stubFilename, "w") do |f|
      f << shbang << "\n"
      if @servant_skelton_filename
	f << "require '#{ @servant_skelton_filename }'\n\n"
      end
      f << WSDL::SOAP::CGIStubCreator.new(@wsdl).dump(create_name(servicename))
    end
  end

  def create_standalone_server_stub(servicename)
    log(INFO) { "Creating standalone stub." }
    servicename ||= @wsdl.services[0].name.name
    @standalone_server_stub_filename = servicename + '.rb'
    check_file(@standalone_server_stub_filename) or return
    File.open(@standalone_server_stub_filename, "w") do |f|
      f << shbang << "\n"
      f << "require '#{ @servant_skelton_filename }'\n\n" if @servant_skelton_filename
      f << WSDL::SOAP::StandaloneServerStubCreator.new(@wsdl).dump(
	create_name(servicename))
    end
  end

  def create_driver(porttypename)
    log(INFO) { "Creating driver." }
    @driver_filename = (porttypename || @name) + 'Driver.rb'
    check_file(@driver_filename) or return
    File.open(@driver_filename, "w") do |f|
      f << "require '#{ @classdef_filename }'\n\n" if @classdef_filename
      f << WSDL::SOAP::DriverCreator.new(@wsdl).dump(
	create_name(porttypename))
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

  def shbang
    "#!/usr/bin/env ruby"
  end

  def create_name(name)
    name ? XSD::QName.new(@wsdl.targetnamespace, name) : nil
  end

  def import(location)
    WSDL::Importer.import(location)
  end
end

WSDL2RubyApp.new.start
