#!/usr/bin/env ruby
require 'RAAServant.rb'

require 'soap/rpc/standaloneServer'
require 'soap/mapping/registry'

class RAABaseServicePortType
  MappingRegistry = ::SOAP::Mapping::Registry.new

  MappingRegistry.set(
    StringArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://www.w3.org/2001/XMLSchema", "string") }
  )
  MappingRegistry.set(
    Category,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "Category") }
  )
  MappingRegistry.set(
    InfoArray,
    ::SOAP::SOAPArray,
    ::SOAP::Mapping::Registry::TypedArrayFactory,
    { :type => XSD::QName.new("http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "Info") }
  )
  MappingRegistry.set(
    Info,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "Info") }
  )
  MappingRegistry.set(
    Product,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "Product") }
  )
  MappingRegistry.set(
    Owner,
    ::SOAP::SOAPStruct,
    ::SOAP::Mapping::Registry::TypedStructFactory,
    { :type => XSD::QName.new("http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "Owner") }
  )

  Methods = [
    [ XSD::QName.new("http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "getAllListings"),
      "",
      "getAllListings",
      [ ["retval", "return", ["String[]", "http://www.w3.org/2001/XMLSchema", "string"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded }
    ],
    [ XSD::QName.new("http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "getProductTree"),
      "",
      "getProductTree",
      [ ["retval", "return", ["Hash", "http://xml.apache.org/xml-soap", "Map"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded }
    ],
    [ XSD::QName.new("http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "getInfoFromCategory"),
      "",
      "getInfoFromCategory",
      [ ["in", "category", ["Category", "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "Category"]],
        ["retval", "return", ["Info[]", "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "Info"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded }
    ],
    [ XSD::QName.new("http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "getModifiedInfoSince"),
      "",
      "getModifiedInfoSince",
      [ ["in", "timeInstant", ["::SOAP::SOAPDateTime"]],
        ["retval", "return", ["Info[]", "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "Info"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded }
    ],
    [ XSD::QName.new("http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "getInfoFromName"),
      "",
      "getInfoFromName",
      [ ["in", "productName", ["::SOAP::SOAPString"]],
        ["retval", "return", ["Info", "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "Info"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded }
    ],
    [ XSD::QName.new("http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "getInfoFromOwnerId"),
      "",
      "getInfoFromOwnerId",
      [ ["in", "ownerId", ["::SOAP::SOAPInt"]],
        ["retval", "return", ["Info[]", "http://www.ruby-lang.org/xmlns/soap/interface/RAA/0.0.2/", "Info"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded }
    ]
  ]
end

class RAABaseServicePortTypeApp < ::SOAP::RPC::StandaloneServer
  def initialize(*arg)
    super(*arg)
    servant = RAABaseServicePortType.new
    RAABaseServicePortType::Methods.each do |definitions|
      opt = definitions.last
      if opt[:request_style] == :document
        @router.add_document_operation(servant, *definitions)
      else
        @router.add_rpc_operation(servant, *definitions)
      end
    end
    self.mapping_registry = RAABaseServicePortType::MappingRegistry
  end
end

if $0 == __FILE__
  # Change listen port.
  server = RAABaseServicePortTypeApp.new('app', nil, '0.0.0.0', 10080)
  trap(:INT) do
    server.shutdown
  end
  server.start
end
