require 'default.rb'

class EchoPortType
  def echo(parameters)
    response = EchoResponse.new
    response << parameters.xmlattr_sampleAttr
    response << parameters.sampleElement
    response
  end
end

