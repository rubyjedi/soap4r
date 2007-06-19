require 'xsd/qname'

# {urn:org.example.enumsample}hobbit.type
class HobbitType
  attr_accessor :name
  attr_accessor :age

  def initialize(name = nil, age = nil)
    @name = name
    @age = age
  end
end

# {urn:org.example.enumsample}hobbit.name.type
class HobbitNameType < ::String
  Frodo = HobbitNameType.new("frodo")
  Meriadoc = HobbitNameType.new("meriadoc")
  Peregrin = HobbitNameType.new("peregrin")
  Sam = HobbitNameType.new("sam")
end
