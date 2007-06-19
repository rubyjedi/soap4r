require 'enumsample_mapper'

mapper = EnumsampleMapper.new

t = HobbitType.new(HobbitNameType::Frodo, 51)

xml = mapper.obj2xml(t)
puts xml
p mapper.xml2obj(xml)
