require 'soap/marshal'

Foo1 = Struct.new( "Foo1", :m )
Foo2 = Struct.new( :m )
class Foo3
  attr_accessor :m
end

puts SOAP::Marshal.marshal( Foo1.new )
puts SOAP::Marshal.marshal( Foo2.new )
puts SOAP::Marshal.marshal( Foo3.new )

p SOAP::Marshal.unmarshal( SOAP::Marshal.marshal( Foo1.new ))
  # => #<Struct::Foo1 m=nil>
p SOAP::Marshal.unmarshal( SOAP::Marshal.marshal( Foo2.new ))
  # => #<Foo2 m=nil>
p SOAP::Marshal.unmarshal( SOAP::Marshal.marshal( Foo3.new ))
  # => #<Foo3:0xa033fc0>
