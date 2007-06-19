require 'xsd/qname'

module XSD::XSD2Ruby


# {urn:mysample}question
class Question
  attr_accessor :something

  def initialize(something = nil)
    @something = something
  end
end

# {urn:mysample}section
class Section
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
end

# {urn:mysample}sectionElement
class SectionElement
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


end
