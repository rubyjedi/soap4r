InterfaceNS = 'http://soapinterop.org/'
TypeNS = 'http://soapinterop.org/xsd'


module SOAPBuildersInterop


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
end


class IntArray < Array
end


class FloatArray < Array
end


class SOAPStructArray < Array
end


MappingRegistry = SOAP::RPCUtils::MappingRegistry.new

MappingRegistry.set(
  ::SOAPBuildersInterop::SOAPStruct,
  ::SOAP::SOAPStruct,
  ::SOAP::RPCUtils::MappingRegistry::TypedStructFactory,
  [ TypeNS, "SOAPStruct" ]
)

MappingRegistry.set(
  ::SOAPBuildersInterop::SOAPStructStruct,
  ::SOAP::SOAPStruct,
  ::SOAP::RPCUtils::MappingRegistry::TypedStructFactory,
  [ TypeNS, "SOAPStructStruct" ]
)

MappingRegistry.set(
  ::SOAPBuildersInterop::SOAPArrayStruct,
  ::SOAP::SOAPStruct,
  ::SOAP::RPCUtils::MappingRegistry::TypedStructFactory,
  [ TypeNS, "SOAPArrayStruct" ]
)

MappingRegistry.set(
  ::SOAPBuildersInterop::StringArray,
  ::SOAP::SOAPArray,
  ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
  [ XSD::Namespace, XSD::StringLiteral ]
)

MappingRegistry.set(
  ::SOAPBuildersInterop::IntArray,
  ::SOAP::SOAPArray,
  ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
  [ XSD::Namespace, XSD::IntLiteral ]
)

MappingRegistry.set(
  ::SOAPBuildersInterop::FloatArray,
  ::SOAP::SOAPArray,
  ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
  [ XSD::Namespace, XSD::FloatLiteral ]
)

MappingRegistry.set(
  ::SOAPBuildersInterop::SOAPStructArray,
  ::SOAP::SOAPArray,
  ::SOAP::RPCUtils::MappingRegistry::TypedArrayFactory,
  [ TypeNS, 'SOAPStruct' ]
)


end
