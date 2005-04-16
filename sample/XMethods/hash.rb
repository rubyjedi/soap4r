wsdl = 'http://www.bs-byg.dk/hashclass.wsdl'

msg = ARGV.shift || 'hello world'
hashtype = ARGV.shift || 'SHA256'

# call service with Hash

require 'soap/wsdlDriver'
drv = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
drv.wiredump_dev = STDOUT if $DEBUG

hash = drv.HashString(:Str => msg, :HashType => hashtype).HashStringResult

p drv.CheckHash(
  :OriginalString => msg,
  :HashString => hash,
  :HashType => hashtype
).CheckHashResult

# with generated class

require 'wsdl/soap/wsdl2ruby'
gen = WSDL::SOAP::WSDL2Ruby.new
gen.location = wsdl
gen.logger.level = Logger::INFO
gen.opt['classdef'] = nil
gen.opt['driver'] = nil
gen.run

require 'defaultDriver'
drv = HashClassSoap.new
drv.wiredump_dev = STDOUT if $DEBUG
hash = drv.HashString(HashString.new(msg, hashtype)).HashStringResult

p drv.CheckHash(CheckHash.new(msg, hash, hashtype)).CheckHashResult
