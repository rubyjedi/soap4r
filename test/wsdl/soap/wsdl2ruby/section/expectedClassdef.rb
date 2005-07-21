require 'xsd/qname'

# {urn:mysample}question
class Question
  @@schema_type = "question"
  @@schema_ns = "urn:mysample"
  @@schema_element = [["something", ["SOAP::SOAPString", XSD::QName.new(nil, "something")]]]

  attr_accessor :something

  def initialize(something = nil)
    @something = something
  end
end

# {urn:mysample}section
class Section
  @@schema_type = "section"
  @@schema_ns = "urn:mysample"
  @@schema_element = [["sectionID", ["SOAP::SOAPInt", XSD::QName.new(nil, "sectionID")]], ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "name")]], ["description", ["SOAP::SOAPString", XSD::QName.new(nil, "description")]], ["index", ["SOAP::SOAPInt", XSD::QName.new(nil, "index")]], ["firstQuestion", ["Question", XSD::QName.new(nil, "firstQuestion")]]]

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
