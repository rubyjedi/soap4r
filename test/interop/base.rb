InterfaceNS = "http://soapinterop.org/"


class SOAPStruct
  include SOAP::Marshallable
  @@typeNamespace = 'http://soapinterop.org/xsd'

  attr_reader :varInt, :varFloat, :varString

  def initialize( varInt, varFloat, varString )
    @varInt = varInt
    @varFloat = varFloat
    @varString = varString
  end

  def ==( rhs )
    r = if rhs.is_a?( SOAPStruct )
	( self.varInt == rhs.varInt &&
	self.varFloat == rhs.varFloat &&
	self.varString == rhs.varString )
      else
	false
      end
    r
  end

  def to_s
    "#{ varInt }:#{ varFloat }:#{ varString }"
  end
end
