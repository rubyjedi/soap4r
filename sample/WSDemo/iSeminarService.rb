module ISeminarService
  MSGInterfaceNS = 'urn:sarion.com:WSDemo_v1:SeminarSubscriptionServiceMessage'
  RPCInterfaceNS = 'urn:sarion.com:WSDemo_v1:SeminarSubscriptionServiceRPC'

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
