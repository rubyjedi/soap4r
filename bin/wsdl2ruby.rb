#!/usr/bin/env ruby

require 'getoptlong'
require 'soap/qname'
require 'wsdl/parser'
require 'wsdl/soap/classDefCreator'
require 'wsdl/soap/servantSkeltonCreator'
require 'wsdl/soap/driverCreator'
require 'wsdl/soap/clientSkeltonCreator'
require 'wsdl/soap/standaloneServerStubCreator'
require 'wsdl/soap/cgiStubCreator'
require 'wsdl/soap/webrickStubCreator'

require 'devel/logger'

class WSDL2RubyApp < Devel::Application
private

  OptSet = [
    ['--wsdl','-w', GetoptLong::REQUIRED_ARGUMENT],
    ['--type','-t', GetoptLong::REQUIRED_ARGUMENT],
    ['--classDef','-e', GetoptLong::NO_ARGUMENT],
    ['--clientSkelton','-c', GetoptLong::OPTIONAL_ARGUMENT],
    ['--servantSkelton','-s', GetoptLong::OPTIONAL_ARGUMENT],
    ['--cgiStub','-g', GetoptLong::OPTIONAL_ARGUMENT],
    ['--webrickStub','-b', GetoptLong::OPTIONAL_ARGUMENT],
    ['--standaloneServerStub','-a', GetoptLong::OPTIONAL_ARGUMENT],
    ['--driver','-d', GetoptLong::OPTIONAL_ARGUMENT],
    ['--force','-f', GetoptLong::NO_ARGUMENT],
  ]

  def initialize
    super( 'app' )
    @wsdlFile = nil
    @opt = {}
    @wsdl = nil
    @name = nil
  end

  def run
    @wsdlFile, @opt = parseOpt( GetoptLong.new( *OptSet ))
    usageExit unless @wsdlFile
    @wsdl = WSDL::WSDLParser.createParser.parse( File.open( @wsdlFile ))
    @name = @wsdl.name.name || 'default'
    createFile
    0
  end

  def createFile
    createClassDef if @opt.has_key?( 'classDef' )
    createServantSkelton( @opt[ 'servantSkelton' ] ) if @opt.has_key?( 'servantSkelton' )
    createCgiStub( @opt[ 'cgiStub' ] ) if @opt.has_key?( 'cgiStub' )
    createWebrickStub( @opt[ 'webrickStub' ] ) if @opt.has_key?( 'webrickStub' )
    createStandaloneServerStub( @opt[ 'standaloneServerStub' ] ) if @opt.has_key?( 'standaloneServerStub' )
    createDriver( @opt[ 'driver' ] ) if @opt.has_key?( 'driver' )
    createClientSkelton( @opt[ 'clientSkelton' ] ) if @opt.has_key?( 'clientSkelton' )
  end

  def usageExit
    puts <<__EOU__
Usage: #{ $0 } --wsdl wsdlFilename [options]

Example:
  For server side:
    #{ $0 } --wsdl myApp.wsdl --type server
  For client side:
    #{ $0 } --wsdl myApp.wsdl --type client

Options:
  --wsdl wsdlFilename
  --type server|client
    --type server implies;
  	--classDef
   	--servantSkelton
    	--standaloneServerStub
    --type client implies;
     	--classDef
      	--clientSkelton
       	--driver
  --classDef
  --clientSkelton [serviceName]
  --servantSkelton [portTypeName]
  --cgiStub [serviceName]
  --webrickStub [serviceName]
  --standaloneServerStub [serviceName]
  --driver [portTypeName]
  --force

Terminology:
  Client <-> Driver <-(SOAP)-> Stub <-> Servant

  Driver and Stub: Automatically generated
  Client and Servant: Skelton generated (you should change)
__EOU__
    exit 1
  end

  def parseOpt( getOpt )
    opt = {}
    wsdlFile = nil
    begin
      getOpt.each do | name, arg |
       	case name
	when "--wsdl"
	  wsdlFile = arg
	when "--type"
  	  case arg
  	  when "server"
  	    opt[ 'classDef' ] = nil
  	    opt[ 'servantSkelton' ] = nil
  	    opt[ 'standaloneServerStub' ] = nil
  	  when "client"
  	    opt[ 'classDef' ] = nil
  	    opt[ 'driver' ] = nil
  	    opt[ 'clientSkelton' ] = nil
  	  else
  	    raise ArgumentError.new( "Unknown type #{ arg }" )
  	  end
   	when "--classDef", "--clientSkelton", "--servantSkelton", "--cgiStub",
    	    "--webrickStub", "--standaloneServerStub", "--driver"
  	  opt[ name.sub( /^--/, '' ) ] = arg.empty? ? nil : arg
	when "--force"
	  opt[ 'force' ] = true
   	else
  	  raise ArgumentError.new( "Unknown type #{ arg }" )
   	end
      end
    rescue
      usageExit
    end
    return wsdlFile, opt
  end

  def createClassDef
    log( SEV_INFO ) { "Creating class definition." }
    @classDefFilename = @name + '.rb'
    checkFile( @classDefFilename ) or return
    File.open( @classDefFilename, "w" ) do | f |
      f << WSDL::SOAP::ClassDefCreator.new( @wsdl ).dump
    end
  end

  def createClientSkelton( serviceName )
    log( SEV_INFO ) { "Creating client skelton." }
    serviceName ||= @wsdl.services[ 0 ].name.name
    @clientSkeltonFilename = serviceName + 'Client.rb'
    checkFile( @clientSkeltonFilename ) or return
    File.open( @clientSkeltonFilename, "w" ) do | f |
      f << shbang << "\n"
      f << "require '#{ @driverFilename }'\n\n" if @driverFilename
      f << WSDL::SOAP::ClientSkeltonCreator.new( @wsdl ).dump(
	createName( serviceName ))
    end
  end

  def createServantSkelton( portTypeName )
    log( SEV_INFO ) { "Creating servant skelton." }
    @servantSkeltonFilename = ( portTypeName || @name + 'Servant' ) + '.rb'
    checkFile( @servantSkeltonFilename ) or return
    File.open( @servantSkeltonFilename, "w" ) do | f |
      f << "require '#{ @classDefFilename }'\n\n" if @classDefFilename
      f << WSDL::SOAP::ServantSkeltonCreator.new( @wsdl ).dump(
	createName( portTypeName ))
    end
  end

  def createCgiStub( serviceName )
    log( SEV_INFO ) { "Creating CGI stub." }
    serviceName ||= @wsdl.services[ 0 ].name.name
    @cgiStubFilename = serviceName + '.cgi'
    checkFile( @cgiStubFilename ) or return
    File.open( @cgiStubFilename, "w" ) do | f |
      f << shbang << "\n"
      f << "require '#{ @servantSkeltonFilename }'\n\n" if @servantSkeltonFilename
      f << WSDL::SOAP::CGIStubCreator.new( @wsdl ).dump(
	createName( serviceName ))
    end
  end

  def createWebrickStub( serviceName )
    log( SEV_INFO ) { "Creating WEBrick SOAPlet stub." }
    serviceName ||= @wsdl.services[ 0 ].name.name
    @webrickStubFilename = 'httpd.rb'
    checkFile( @webrickStubFilename ) or return
    File.open( @webrickStubFilename, "w" ) do | f |
      f << shbang << "\n"
      f << "require '#{ @servantSkeltonFilename }'\n\n" if @servantSkeltonFilename
      f << WSDL::SOAP::WEBrickStubCreator.new( @wsdl ).dump(
	createName( serviceName ))
    end
  end

  def createStandaloneServerStub( serviceName )
    log( SEV_INFO ) { "Creating standalone stub." }
    serviceName ||= @wsdl.services[ 0 ].name.name
    @standaloneServerStubFilename = serviceName + '.rb'
    checkFile( @standaloneServerStubFilename ) or return
    File.open( @standaloneServerStubFilename, "w" ) do | f |
      f << shbang << "\n"
      f << "require '#{ @servantSkeltonFilename }'\n\n" if @servantSkeltonFilename
      f << WSDL::SOAP::StandaloneServerStubCreator.new( @wsdl ).dump(
	createName( serviceName ))
    end
  end

  def createDriver( portTypeName )
    log( SEV_INFO ) { "Creating driver." }
    @driverFilename = ( portTypeName || @name ) + 'Driver.rb'
    checkFile( @driverFilename ) or return
    File.open( @driverFilename, "w" ) do | f |
      f << "require '#{ @classDefFilename }'\n\n" if @classDefFilename
      f << WSDL::SOAP::DriverCreator.new( @wsdl ).dump(
	createName( portTypeName ))
    end
  end

  def checkFile( filename )
    if FileTest.exist?( filename )
      if @opt.has_key?( 'force' )
	log( SEV_WARN ) {
	  "File '#{ filename }' exists but overrides it."
	}
	true
      else
	log( SEV_WARN ) {
	  "File '#{ filename }' exists.  #{ $0 } did not override it."
	}
	false
      end
    else
      log( SEV_INFO ) { "Creates file '#{ filename }'." }
      true
    end
  end

  def shbang
    "#!/usr/bin/env ruby"
  end

  def createName( name )
    name ? XSD::QName.new( @wsdl.targetNamespace, name ) : nil
  end
end

WSDL2RubyApp.new.start
