# Method definition.
def methodDef( drv )
  methodDefBase( drv )
  methodDefGroupB( drv )
end

def methodDefWithSOAPAction( drv, soapAction )
  methodDefWithSOAPActionBase( drv, soapAction )
  methodDefWithSOAPActionGroupB( drv, soapAction )
end


def methodDefBase( drv )
  drv.addMethod( 'echoVoid' )
  drv.addMethod( 'echoString', 'inputString' )
  drv.addMethod( 'echoStringArray', 'inputStringArray' )
  drv.addMethod( 'echoInteger', 'inputInteger' )
  drv.addMethod( 'echoIntegerArray', 'inputIntegerArray' )
  drv.addMethod( 'echoFloat', 'inputFloat' )
  drv.addMethod( 'echoFloatArray', 'inputFloatArray' )
  drv.addMethod( 'echoStruct', 'inputStruct' )
  drv.addMethod( 'echoStructArray', 'inputStructArray' )
  drv.addMethod( 'echoDate', 'inputDate' )
  drv.addMethod( 'echoBase64', 'inputBase64' )
end

def methodDefGroupB( drv )
  drv.addMethod( 'echoSimpleTypesAsStruct', 'inputString', 'inputInteger', 'inputFloat' )
  drv.addMethod( 'echo2DStringArray', 'input2DStringArray' )
  drv.addMethod( 'echoNestedStruct', 'inputStruct' )
  drv.addMethod( 'echoNestedArray', 'inputStruct' )
end

def methodDefWithSOAPActionBase( drv, soapAction )
  drv.addMethodWithSOAPAction( 'echoVoid', soapAction + 'echoVoid' )
  drv.addMethodWithSOAPAction( 'echoString', soapAction + 'echoString', 'inputString' )
  drv.addMethodWithSOAPAction( 'echoStringArray', soapAction + 'echoStringArray', 'inputStringArray' )
  drv.addMethodWithSOAPAction( 'echoInteger', soapAction + 'echoInteger', 'inputInteger' )
  drv.addMethodWithSOAPAction( 'echoIntegerArray', soapAction + 'echoIntegerArray', 'inputIntegerArray' )
  drv.addMethodWithSOAPAction( 'echoFloat', soapAction + 'echoFloat', 'inputFloat' )
  drv.addMethodWithSOAPAction( 'echoFloatArray', soapAction + 'echoFloatArray', 'inputFloatArray' )
  drv.addMethodWithSOAPAction( 'echoStruct', soapAction + 'echoStruct', 'inputStruct' )
  drv.addMethodWithSOAPAction( 'echoStructArray', soapAction + 'echoStructArray', 'inputStructArray' )
  drv.addMethodWithSOAPAction( 'echoDate', soapAction + 'echoDate', 'inputDate' )
  drv.addMethodWithSOAPAction( 'echoBase64', soapAction + 'echoBase64', 'inputBase64' )
end

def methodDefWithSOAPActionGroupB( drv, soapAction )
  drv.addMethodWithSOAPAction( 'echoSimpleTypesAsStruct', soapAction + 'echoSimpleTypesAsStruct', 'inputString', 'inputInteger', 'inputFloat' )
  drv.addMethodWithSOAPAction( 'echo2DStringArray', soapAction + 'echo2DStringArray', 'inputStringArray' )
  drv.addMethodWithSOAPAction( 'echoNestedStruct', soapAction + 'echoNestedStruct', 'inputStruct' )
  drv.addMethodWithSOAPAction( 'echoNestedArray', soapAction + 'echoArrayStruct', 'inputStruct' )
end
