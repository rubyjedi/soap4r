require 'soap/marshal'

class Node; include SOAP::Marshallable
  attr_reader :first, :second

  def initialize( *initNext )
    @first = initNext[0]
    @second = initNext[1]
  end
end

n9 = Node.new
n81 = Node.new( n9 )
n82 = Node.new( n9 )
n7 = Node.new( n81, n82 )
n61 = Node.new( n7 )
n62 = Node.new( n7 )
n5 = Node.new( n61, n62 )
n41 = Node.new( n5 )
n42 = Node.new( n5 )
n3 = Node.new( n41, n42 )
n21 = Node.new( n3 )
n22 = Node.new( n3 )
n1 = Node.new( n21, n22 )

marshalledString = SOAP::Marshal.marshal( n1 )

puts marshalledString

clonedNode = SOAP::Marshal.unmarshal( marshalledString )

puts clonedNode.inspect

p clonedNode.first.first.__id__
p clonedNode.second.first.__id__
