module ISubscribeService
  MSGInterfaceNS = 'urn:org.tempuri:subscribeMessage'
  RPCInterfaceNS = 'urn:org.tempuri:subscribeRPC'

  MSGInterface = [
    [ 'subscribe', 'address' ],
    [ 'bye', 'address' ],
    [ 'list' ],
  ]

  RPCInterface = [
    [ 'challenge', 'userId' ],
  ]

  def ISeminarService.addMSGMethod( drv )
    MSGInterface.each do | method, *param |
      drv.addMethod( method, *param )
    end
  end

  def ISeminarService.addRPCMethod( drv )
    RPCInterface.each do | method, *param |
      drv.addMethod( method, *param )
    end
  end
end
