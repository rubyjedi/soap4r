require 'soap/marshal'

class IntArray < Array; end

map = SOAP::Mapping::Registry.new
map.add(
  IntArray, SOAP::SOAPArray, SOAP::Mapping::Registry::TypedArrayFactory,
  {
    :type => XSD::QName.new(XSD::Namespace, XSD::IntLiteral)
  }
)

puts "== dumps anyType array =="
puts SOAP::Marshal.marshal(IntArray[1, 2, 3])
puts
puts "== dumps int array with custom registry =="
puts SOAP::Marshal.marshal(IntArray[1, 2, 3], map)
