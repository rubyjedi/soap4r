require 'xsd/qname'

module WSDL::Group


# {urn:grouptype}groupele_type
#   comment - SOAP::SOAPString
#   element - SOAP::SOAPString
#   eletype - SOAP::SOAPString
#   var - SOAP::SOAPString
class Groupele_type
  attr_accessor :comment
  attr_reader :__xmlele_any
  attr_accessor :element
  attr_accessor :eletype
  attr_accessor :var

  def set_any(elements)
    @__xmlele_any = elements
  end

  def initialize(comment = nil, element = nil, eletype = nil, var = nil)
    @comment = comment
    @__xmlele_any = nil
    @element = element
    @eletype = eletype
    @var = var
  end
end


end
