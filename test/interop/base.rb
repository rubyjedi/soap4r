require 'soap/rpcUtils'

InterfaceNS = 'http://soapinterop.org/'
TypeNS = 'http://soapinterop.org/xsd'


class SOAPStruct
  include SOAP::Marshallable

  attr_reader :varInt, :varFloat, :varString

  def initialize( varInt, varFloat, varString )
    @varInt = varInt
    @varFloat = varFloat
    @varString = varString
  end

  def ==( rhs )
    r = if rhs.is_a?( self.type )
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


class SOAPStructStruct
  include SOAP::Marshallable

  attr_reader :varInt, :varFloat, :varString, :varStruct

  def initialize( varInt, varFloat, varString, varStruct = nil )
    @varInt = varInt
    @varFloat = varFloat
    @varString = varString
    @varStruct = varStruct
  end

  def ==( rhs )
    r = if rhs.is_a?( self.type )
	( self.varInt == rhs.varInt &&
	self.varFloat == rhs.varFloat &&
	self.varString == rhs.varString &&
	self.varStruct == rhs.varStruct )
      else
	false
      end
    r
  end

  def to_s
    "#{ varInt }:#{ varFloat }:#{ varString }:#{ varStruct }"
  end
end


class SOAPArrayStruct
  include SOAP::Marshallable

  attr_reader :varInt, :varFloat, :varString, :varArray

  def initialize( varInt, varFloat, varString, varArray = nil )
    @varInt = varInt
    @varFloat = varFloat
    @varString = varString
    @varArray = varArray
  end

  def ==( rhs )
    r = if rhs.is_a?( self.type )
	( self.varInt == rhs.varInt &&
	self.varFloat == rhs.varFloat &&
	self.varString == rhs.varString &&
	self.varArray == rhs.varArray )
      else
	false
      end
    r
  end

  def to_s
    "#{ varInt }:#{ varFloat }:#{ varString }:#{ varArray }"
  end
end


class StringArray < Array
  @typeName = XSD::StringLiteral
  @typeNamespace = XSD::Namespace
end


class IntArray < Array
  @typeName = XSD::IntLiteral
  @typeNamespace = XSD::Namespace
end


class FloatArray < Array
  @typeName = XSD::FloatLiteral
  @typeNamespace = XSD::Namespace
end


class SOAPStructArray < Array
  @typeName = 'SOAPStruct'
  @typeNamespace = TypeNS
end


MappingRegistry = SOAP::RPCUtils::MappingRegistry.new
MappingRegistry.set( ::SOAPStruct, ::SOAP::SOAPStruct, SOAP::RPCUtils::MappingRegistry::TypedStructFactory, [ TypeNS, "SOAPStruct" ] )
MappingRegistry.set( ::SOAPStructStruct, ::SOAP::SOAPStruct, SOAP::RPCUtils::MappingRegistry::TypedStructFactory, [ TypeNS, "SOAPStructStruct" ] )
MappingRegistry.set( ::SOAPArrayStruct, ::SOAP::SOAPStruct, SOAP::RPCUtils::MappingRegistry::TypedStructFactory, [ TypeNS, "SOAPArrayStruct" ] )
