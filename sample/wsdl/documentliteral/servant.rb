require 'default.rb'

class EchoPortType
  def echo(parameters)
    response = EchoResponse.new
    response.sampleMultiValue << parameters.attr_sampleAttr
    response.sampleMultiValue << parameters.sampleElement
    response
  end
end

