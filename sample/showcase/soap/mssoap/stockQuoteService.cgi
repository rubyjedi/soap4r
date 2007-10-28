#!/usr/bin/env ruby
require 'soap/rpc/cgistub'
require 'soap/mapping/registry'
require 'stockQuoteService.rb'

class StockQuoteServicePortType
  MappingRegistry = ::SOAP::Mapping::Registry.new

  Methods = [
    [ XSD::QName.new("urn:xmltoday-delayed-quotes", "getQuote"),
      "",
      "getQuote",
      [ [:in, "arg0", ["::SOAP::SOAPString"]],
        [:retval, "getQuoteResult", ["::SOAP::SOAPFloat"]] ],
      { :request_style =>  :rpc, :request_use =>  :encoded,
        :response_style => :rpc, :response_use => :encoded }
    ]
  ]
end

class StockQuoteServicePortTypeApp < ::SOAP::RPC::CGIStub
  def initialize(*arg)
    super(*arg)
    servant = StockQuoteServicePortType.new
    StockQuoteServicePortType::Methods.each do |definitions|
      opt = definitions.last
      if opt[:request_style] == :document
        @router.add_document_operation(servant, *definitions)
      else
        @router.add_rpc_operation(servant, *definitions)
      end
    end
    self.mapping_registry = StockQuoteServicePortType::MappingRegistry
    self.level = Logger::Severity::ERROR
  end
end


if ENV['QUERY_STRING'] == 'wsdl'
   puts "Content-Type: text/html\r\n\r\n"
   puts IO.readlines('~/web/cgi-bin/stockQuoteService.wsdl')
else
   StockQuoteServicePortTypeApp.new('app', nil).start
end
