require 'soap/soap'


InterfaceNS = 'http://soapinterop.org/'
TypeNS = 'http://soapinterop.org/xsd'


module SOAPBuildersInterop
extend SOAP


MethodsBase = [
  ['echoVoid'],
  ['echoString',
    ['in', 'inputString'], ['retval', 'return']],
  ['echoStringArray',
    ['in', 'inputStringArray'], ['retval', 'return']],
  ['echoInteger',
    ['in', 'inputInteger'], ['retval', 'return']],
  ['echoIntegerArray',
    ['in', 'inputIntegerArray'], ['retval', 'return']],
  ['echoFloat',
    ['in', 'inputFloat'], ['retval', 'return']],
  ['echoFloatArray',
    ['in', 'inputFloatArray'], ['retval', 'return']],
  ['echoStruct',
    ['in', 'inputStruct'], ['retval', 'return']],
  ['echoStructArray',
    ['in', 'inputStructArray'], ['retval', 'return']],
  ['echoDate',
    ['in', 'inputDate'], ['retval', 'return']],
  ['echoBase64',
    ['in', 'inputBase64'], ['retval', 'return']],
  ['echoHexBinary',
    ['in', 'inputHexBinary'], ['retval', 'return']],
  ['echoBoolean',
    ['in', 'inputBoolean'], ['retval', 'return']],
  ['echoDecimal',
    ['in', 'inputDecimal'], ['retval', 'return']],

  ['echoDouble',
    ['in', 'inputDouble'], ['retval', 'return']],
  ['echoXSDDateTime',
    ['in', 'inputXSDDateTime'], ['retval', 'return']],
  ['echoXSDDate',
    ['in', 'inputXSDDate'], ['retval', 'return']],
  ['echoXSDTime',
    ['in', 'inputXSDTime'], ['retval', 'return']],
]

MethodsGroupB = [
  ['echoStructAsSimpleTypes',
    ['in', 'inputStruct'], ['retval', 'outputString'], ['out', 'outputInteger'], ['out', 'outputFloat']],
  ['echoSimpleTypesAsStruct',
    ['in', 'inputString'], ['in', 'inputInteger'], ['in', 'inputFloat'], ['retval', 'return']],
  ['echo2DStringArray',
    ['in', 'input2DStringArray'], ['retval', 'return']],
  ['echoNestedStruct',
    ['in', 'inputStruct'], ['retval', 'return']],
  ['echoNestedArray',
    ['in', 'inputStruct'], ['retval', 'return']],
]


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
