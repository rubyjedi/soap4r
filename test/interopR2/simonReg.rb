#!/usr/bin/env ruby

proxy = ARGV.shift || nil

require 'soap/driver'

require 'iSimonReg'

server = 'http://soap.4s4c.com/registration/soap.asp'

class SimonRegApp < Application
  include SimonReg

private

  AppName = 'SimonRegApp'

  def initialize( server, proxy )
    super( AppName )
    @server = server
    @proxy = proxy
    @logId = Time.now.gmtime.strftime( "%Y-%m-%dT%X+0000" )
    @drvServices = nil
    @drvClients = nil
    @drvServers = nil
    @drvSubscriber = nil
  end

  def run()
    @log.sevThreshold = SEV_WARN
    wireDump = getWireDumpLogFile

    # Services portType
    @drvServices = SOAP::Driver.new( @log, @logId, Services::InterfaceNS, @server, @proxy )
    @drvServices.setWireDumpDev( wireDump )

    Services::Methods.each do | method, params |
      @drvServices.addMethod( method, *( params[1..-1] ))
    end
    @drvServices.extend( Services )

    # Clients portType
    @drvClients = SOAP::Driver.new( @log, @logId, Clients::InterfaceNS, @server, @proxy )
    @drvClients.setWireDumpDev( wireDump )

    Clients::Methods.each do | method, params |
      @drvClients.addMethod( method, *( params[1..-1] ))
    end
    @drvClients.extend( Clients )

    # Servers portType
    @drvServers = SOAP::Driver.new( @log, @logId, Servers::InterfaceNS, @server, @proxy )
    @drvServers.setWireDumpDev( wireDump )

    Servers::Methods.each do | method, params |
      @drvServers.addMethod( method, *( params[1..-1] ))
    end
    @drvServers.extend( Services )

    # Services portType
    @drvSubscriber = SOAP::Driver.new( @log, @logId, Subscriber::InterfaceNS, @server, @proxy )
    @drvSubscriber.setWireDumpDev( wireDump )

    Subscriber::Methods.each do | method, params |
      @drvSubscriber.addMethod( method, *( params[1..-1] ))
    end
    @drvSubscriber.extend( Subscriber )

    # Service information
    services = @drvServices.ServiceList
    groupA = services.find { | service | service.name == 'SoapBuilders Interop Group A' }
    groupB = services.find { | service | service.name == 'SoapBuilders Interop Group B' }

    # SOAP4R information
    version = '1.3.4'
    soap4rClientInfo = Clients::ClientInfo.new( 'SOAP4R', version )
    soap4rServerInfo = Servers::ServerInfo.new( 'SOAP4R', version,
      'http://www.jin.gr.jp/~nahi/Ruby/SOAP4R/SOAPBuildersInterop/',
      'http://www.jin.gr.jp/~nahi/Ruby/SOAP4R/SOAPBuildersInterop/SOAP4R_SOAPBuildersInteropTest_R2base.wsdl' )
    soap4rGroupAClientID = ''
    soap4rGroupBClientID = ''
    soap4rGroupAServerID = '{3094F6C7-F6AA-4BE5-A4EB-194C82103728}'
    soap4rGroupBServerID = '{A16357C9-6C7F-45CD-AC3D-72F0FC5F4F99}'

    # Client registration
    # clientID = @drvClients.RegisterClient( groupA.id, soap4rClientInfo )
    # clientID = @drvClients.RegisterClient( groupB.id, soap4rClientInfo )

    # Client remove
    # @drvClients.RemoveClient( soap4rClientID )

    # Server registration
    # serverID = @drvServers.RegisterServer( groupA.id, soap4rServerInfo )
    # serverID = @drvServers.RegisterServer( groupB.id, soap4rServerInfo )
    # p serverID

    # Update
    #@drvClients.UpdateServer( soap4rGroupAClientID, soap4rClientInfo )
    #@drvClients.UpdateServer( soap4rGroupBClientID, soap4rClientInfo )
    @drvServers.UpdateServer( soap4rGroupAServerID, soap4rServerInfo )
    @drvServers.UpdateServer( soap4rGroupBServerID, soap4rServerInfo )
  end


  ###
  ## Other utility methods
  #
  def log( sev, message )
    @log.add( sev, "<#{ @logId }> #{ message }", @appName ) if @log
  end

  def getWireDumpLogFile
    logFilename = File.basename( $0 ) + '.log'
    f = File.open( logFilename, 'w' )
    f << "File: #{ logFilename } - Wiredumps for SOAP4R client.\n"
    f << "Date: #{ Time.now }\n\n"
  end
end

app = SimonRegApp.new( server, proxy ).start()
