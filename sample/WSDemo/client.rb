#!/usr/bin/env ruby

require 'soap/driver'
require 'iSubscribeService'
require 'sha1'
require 'base64'
include SOAP


###
## Definitions.
#
proxy = ARGV.shift || nil
msgRouterURL = 'http://localhost:8081/soap/servlet/messagerouter'
rpcRouterURL = 'http://localhost:8081/soap/servlet/rpcrouter'
$privateKey = "private!"
$userId = 'SOAP4R user #1'
$subscribeAddress = 'nahi@keynauts.com'

# Create drivers for RPC interface and Messaging interface.
msgDrv = Driver.new( nil, $0, ISubscribeService::MSGInterfaceNS,
  msgRouterURL, proxy )
ISubscribeService::addMSGMethod( msgDrv )

rpcDrv = Driver.new( nil, $0, ISubscribeService::RPCInterfaceNS,
  rpcRouterURL, proxy )
ISubscribeService::addRPCMethod( rpcDrv )

def calcDigest( userId, token )
  encode64( SHA1.new( $privateKey + userId + token ).digest )
end


###
## Connect RPC server to get a ticket.
#
def getTicket( drv )
  token = drv.challenge( $userId )
  puts "Got token: #{ token }."
  encodedResponse = calcDigest( $userId, token )

  # Preparing header items in SOAP Header.
  authEle = SOAPElement.new( ISubscribeService::MSGInterfaceNS, 'auth' )
  authEle.add( SOAPElement.new( nil, 'token', token ))
  authEle.add( SOAPElement.new( nil, 'response', encodedResponse ))
  return authEle
end


###
## Send submit request to message server.
#
# Preparing headerItems in SOAP Header.
headerItems = [ getTicket(rpcDrv) ]

# Preparing message in SOAP Body.
msg = SOAPElement.new( ISubscribeService::MSGInterfaceNS, 'subscribe' )
address = SOAPElement.new( nil, 'address', $subscribeAddress )
address.attr[ 'type' ] = 'mailto'
msg.add( address )

# Invoke.
msgDrv.invoke( headerItems, msg )


###
## Send a request to message server and get list.
#
# Preparing headerItems in SOAP Header.
headerItems = [ getTicket(rpcDrv) ]

# Preparing message in SOAP Body.
msg = SOAPElement.new( ISubscribeService::MSGInterfaceNS, 'list' )

# Invoke.
data = msgDrv.invoke( headerItems, msg )
puts data.receiveString


sleep 10;
###
## Send delete request to message server.
#
# Preparing headerItems in SOAP Header.
headerItems = [ getTicket(rpcDrv) ]

# Preparing message in SOAP Body.
msg = SOAPElement.new( ISubscribeService::MSGInterfaceNS, 'bye' )
address = SOAPElement.new( nil, 'address', $subscribeAddress )
address.attr[ 'type' ] = 'mailto'
msg.add( address )

# Invoke.
msgDrv.invoke( headerItems, msg )


###
## Send listing request again.
#
# Preparing headerItems in SOAP Header.
headerItems = [ getTicket(rpcDrv) ]

# Preparing message in SOAP Body.
msg = SOAPElement.new( ISubscribeService::MSGInterfaceNS, 'list' )

# Invoke.
data = msgDrv.invoke( headerItems, msg )
puts data.receiveString
