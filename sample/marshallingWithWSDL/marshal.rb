require 'wsdl/parser'
require 'soap/marshal'

class WSDLMarshaller
  include SOAP

  def initialize(wsdlFile)
    wsdl = WSDL::WSDLParser.createParser.parse(File.open(wsdlFile).read)
    types = wsdl.collectComplexTypes
    @opt = {
      :decodeComplexTypes => types,
      :generateEncodeType => false
    }
    @mappingRegistry = Mapping::WSDLMappingRegistry.new(types)
  end

  def dump(obj, io = nil)
    type = Mapping.createClassType(obj.class)
    ele =  Mapping.obj2soap(obj, @mappingRegistry, type)
    ele.elementName = ele.type
    Processor.marshal(nil, SOAPBody.new(ele), @opt, io)
  end

  def load(io)
    header, body = Processor.unmarshal(io, @opt)
    Mapping.soap2obj(body.rootNode)
  end
end

marshaller = WSDLMarshaller.new('Person.wsdl')

require 'Person'
obj = Person.new("NAKAMURA", "Hiroshi", 1, 1.0,  "1")
str = marshaller.dump(obj)
puts str
puts
require 'pp'
pp marshaller.load(str)
