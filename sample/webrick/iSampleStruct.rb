require 'soap/rpcUtils'

SampleStructServiceNamespace = 'http://tempuri.org/sampleStructService'

class SampleStruct; include SOAP::Marshallable
  attr_accessor :sampleArray
  attr_accessor :date

  def initialize
    @sampleArray = SampleArray[ "cyclic", self ]
    @date = Time.now
  end

  def copy( rhs )
    @sampleArray = rhs.sampleArray.dup
    @date = rhs.date.dup
    self
  end
end

class SampleArray < Array; include SOAP::Marshallable
end
