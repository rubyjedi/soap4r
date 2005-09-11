require 'default.rb'

class EchoPortType
  def echo(parameters)
    response = EchoResponse.new
    response.sampleMultiValue << parameters.xmlattr_sampleAttr
    response.sampleMultiValue << parameters.sampleElement
    response
  end
end

