#!/usr/bin/env ruby

$KCODE = 'SJIS'

require 'soap/driver'
require 'soap/XMLSchemaDatatypes1999'
require 'iSeminarService'
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
$subscribeAddress = 'http://localhost:8083/'

# Create drivers for RPC interface and Messaging interface.
msgDrv = Driver.new( nil, $0, ISeminarService::MSGInterfaceNS,
  msgRouterURL, proxy )
ISeminarService::addMSGMethod( msgDrv )

rpcDrv = Driver.new( nil, $0, ISeminarService::RPCInterfaceNS,
  rpcRouterURL, proxy )
ISeminarService::addRPCMethod( rpcDrv )

def calcDigest( userId, token )
  encode64( SHA1.new( $privateKey + userId + token ).digest )
end


###
## サーバーに接続してチケットを取得するメソッド
#
def getTicket( drv )
  token = drv.challenge( $userId )
  puts "Got token: #{ token }."
  encodedResponse = calcDigest( $userId, token )

  # Preparing header items in SOAP Header.
  authEle = SOAPElement.new( ISeminarService::MSGInterfaceNS, 'auth' )
  authEle.add( SOAPElement.new( nil, 'token', token ))
  authEle.add( SOAPElement.new( nil, 'response', encodedResponse ))
  return authEle
end


###
## 登録
#
# Preparing headerItems in SOAP Header.
headerItems = [ getTicket(rpcDrv) ]

# Preparing message in SOAP Body.
msg = SOAPElement.new( ISeminarService::MSGInterfaceNS, 'subscribe' )
address = SOAPElement.new( nil, 'address', $subscribeAddress )
address.attr[ 'type' ] = 'soap'
msg.add( address )

# Invoke.
msgDrv.invoke( headerItems, msg )


###
## 一覧
#
# Preparing headerItems in SOAP Header.
headerItems = [ getTicket(rpcDrv) ]

# Preparing message in SOAP Body.
msg = SOAPElement.new( ISeminarService::MSGInterfaceNS, 'list' )

# Invoke.
data = msgDrv.invoke( headerItems, msg )
puts data.receiveString


sleep 10;
###
## 削除
#
# Preparing headerItems in SOAP Header.
headerItems = [ getTicket(rpcDrv) ]

# Preparing message in SOAP Body.
msg = SOAPElement.new( ISeminarService::MSGInterfaceNS, 'bye' )
address = SOAPElement.new( nil, 'address', $subscribeAddress )
address.attr[ 'type' ] = 'soap'
msg.add( address )

# Invoke.
msgDrv.invoke( headerItems, msg )


###
## 一覧
#
# Preparing headerItems in SOAP Header.
headerItems = [ getTicket(rpcDrv) ]

# Preparing message in SOAP Body.
msg = SOAPElement.new( ISeminarService::MSGInterfaceNS, 'list' )

# Invoke.
data = msgDrv.invoke( headerItems, msg )
puts data.receiveString
