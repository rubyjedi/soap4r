require 'soap/driver'
require 'devel/logger'
require 'iRAA'

module RAA; extend SOAP


class Driver
  attr_reader :endpointUrl
  attr_reader :proxy

  attr_reader :log

  AppName = 'RAAClient'

  def initialize( endpointUrl, proxy = nil )
    @endpointUrl = endpointUrl
    @proxy = proxy
    @logDev = STDERR
  end

  def setWireDumpDev( dev )
    @drv = createDriver unless @drv
    @drv.setWireDumpDev( dev )
  end

  def setHttpProxy( httpProxy )
    @drv = createDriver unless @drv
    @drv.setHttpProxy( httpProxy )
  end

  def setLogDev( logDev )
    @logDev = logDev
    @log = nil
  end

  def setLogLevel( level )
    createLog unless @log
    @log.level = level
  end

private

  def createLog
    @log = Devel::Logger.new( @logDev ) if @logDev
  end

  def createDriver
    createLog unless @log
    drv = SOAP::Driver.new( @log, AppName, RAA::InterfaceNS, @endpointUrl,
      @proxy )
    drv.mappingRegistry = RAA::MappingRegistry
    RAA::Methods.each do | methodName, *params |
      drv.addMethod( methodName, params )
    end
    drv
  end

  def method_missing( msg_id, *a, &b )
    @drv = createDriver unless @drv
    @drv.__send__( msg_id, *a, &b )
  end
end


end
