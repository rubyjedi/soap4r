require 'wsdl/parser'
require 'soap/marshal'

class WSDLMarshaller
  include SOAP

  def initialize(wsdlfile)
    wsdl = WSDL::WSDLParser.create_parser.parse(File.open(wsdlfile).read)
    types = wsdl.collect_complextypes
    @opt = {
      :decode_typemap => types,
      :generate_explicit_type => false,
      :pretty => true
    }
    @mapping_registry = Mapping::WSDLMappingRegistry.new(types)
  end

  def dump(obj, io = nil)
    type = Mapping.class2element(obj.class)
    ele =  Mapping.obj2soap(obj, @mapping_registry, type)
    ele.elename = ele.type
    Processor.marshal(nil, SOAPBody.new(ele), @opt, io)
  end

  def load(io)
    header, body = Processor.unmarshal(io, @opt)
    Mapping.soap2obj(body.root_node)
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
