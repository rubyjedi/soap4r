#!/usr/bin/env ruby

$KCODE = 'SJIS'

require 'soap/rpc/driver'
require 'INetDicV06'; include INetDicV06

server = 'http://btonic.est.co.jp/NetDic/NetDicv06.asmx'
wiredump_dev = STDERR       # STDERR

dic = SOAP::RPC::Driver.new(server, INetDicV06::InterfaceNS)
dic.wiredump_dev = wiredump_dev
dic.default_encodingstyle = ::SOAP::EncodingStyle::ASPDotNetHandler::Namespace
INetDicV06::add_method(dic)

p dic.GetDicList()
