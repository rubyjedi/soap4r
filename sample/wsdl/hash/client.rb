#!/usr/bin/env ruby

require 'soap/wsdlDriver'
wsdl = 'hash.wsdl'
driver = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
driver.generate_explicit_type = true

backup = driver.wsdl_mapping_registry
driver.wsdl_mapping_registry = SOAP::Mapping::DefaultRegistry
p driver.hash({1=>2, 3=>4})
driver.wsdl_mapping_registry = backup
