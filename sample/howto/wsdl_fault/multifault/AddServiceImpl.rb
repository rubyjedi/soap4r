require 'AddMappingRegistry.rb'
require 'AddServant.rb'

class AddPortType
  def initialize()
    @sum = 0
  end

  def add(request)
    if (request.value > 100)
      fault = AddFault.new("Value #{request.value} is too large", "Critical")
      raise fault
    end

    if (request.value < 0)
      fault = NegativeValueFault.new("Value #{request.value} is negative", "Fatal")
      raise fault
    end

    @sum += request.value
    return AddResponse.new(@sum)
  end
end

