require 'xsd/qname'

# {urn:mysample}question
class Question
  @@schema_type = "question"
  @@schema_ns = "urn:mysample"
  @@schema_element = [["something", "SOAP::SOAPString"]]

  attr_accessor :something

  def initialize(something = nil)
    @something = something
  end
end

# {urn:mysample}section
class Section
  @@schema_type = "section"
  @@schema_ns = "urn:mysample"
  @@schema_element = [["sectionID", "SOAP::SOAPInt"], ["name", "SOAP::SOAPString"], ["description", "SOAP::SOAPString"], ["index", "SOAP::SOAPInt"], ["firstQuestion", "Question"]]

  attr_accessor :sectionID
  attr_accessor :name
  attr_accessor :description
  attr_accessor :index
  attr_accessor :firstQuestion

  def initialize(sectionID = nil, name = nil, description = nil, index = nil, firstQuestion = nil)
    @sectionID = sectionID
    @name = name
    @description = description
    @index = index
    @firstQuestion = firstQuestion
  end
end

# {urn:mysample}sectionArray
class SectionArray < ::Array
  @@schema_type = "section"
  @@schema_ns = "urn:mysample"
  @@schema_element = [["item", ["Section", XSD::QName.new(nil, "item")]]]
end
