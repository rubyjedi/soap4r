require 'test/unit'
require 'wsdl/parser'
require 'soap/mapping/wsdlRegistry'
require 'soap/marshal'

class WSDLMarshaller
  include SOAP

  def initialize(wsdlfile)
    wsdl = WSDL::Parser.new.parse(File.open(wsdlfile).read)
    types = wsdl.collect_complextypes
    @opt = {
      :decode_typemap => types,
      :generate_explicit_type => false,
      :pretty => true
    }
    @mapping_registry = Mapping::WSDLRegistry.new(types)
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


require File.join(File.dirname(__FILE__), 'person_org')

class Person
  def ==(rhs)
    @familyname == rhs.familyname and @givenname == rhs.givenname and
      @var1 == rhs.var1 and @var2 == rhs.var2 and @var3 == rhs.var3
  end
end


class TestWSDLMarshal < Test::Unit::TestCase
  def pathname(filename)
    File.join(File.dirname(File.expand_path(__FILE__)), filename)
  end

  def test_marshal
    marshaller = WSDLMarshaller.new(pathname('person.wsdl'))
    obj = Person.new("NAKAMURA", "Hiroshi", 1, 1.0,  "1")
    str = marshaller.dump(obj)
    obj2 = marshaller.load(str)
    assert_equal(obj, obj2)
    assert_equal(str, marshaller.dump(obj2))
  end

  def test_classdef
    raise if File.exist?("Person.rb")
    system("ruby #{pathname("../../../bin/wsdl2ruby.rb")} --classdef --wsdl #{pathname("person.wsdl")} --force")
    person_org = File.open(pathname("person_org.rb")).read
    person_new = File.open("Person.rb").read
    assert_equal(person_org, person_new)
    File.unlink('Person.rb') if File.exist?('Person.rb')
  end
end
