require 'soap/marshal'
include SOAP

class DummyStruct
  QName = XSD::QName.new(nil, 'DummyStruct')

  def initialize(hash)
    @hash = {}
    @hash.update(hash)
  end

  def [](key)
    @hash[key]
  end

  def []=(key, value)
    @hash[key] = value
  end

  def each
    @hash.each do |key, value|
      yield(key, value)
    end
  end
end

class DummyStructFactory
  def obj2soap(soap_class, obj, info, map)
    unless obj.is_a?(DummyStruct)
      return nil
    end
    soap_obj = SOAPStruct.new(DummyStruct::QName)
    obj.each do |key, value|
      soap_obj[key] = SOAPString.new(value.to_s)
    end
    soap_obj
  end

  def soap2obj(obj_class, node, info, map)
    unless node.type == DummyStruct::QName
      return false
    end
    obj = DummyStruct.new
    node.each do |key, value|
      obj[key] = value.data
    end
    return true, obj
  end
end

map = Mapping::Registry.new
map.set(DummyStruct, SOAPStruct, DummyStructFactory.new)

obj = DummyStruct.new('family' => 'Na', 'given' => 'Hi')
puts marshalledstring = SOAPMarshal.marshal(obj, map)

p SOAPMarshal.unmarshal(marshalledstring)
