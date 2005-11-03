require 'xsd/qname'

# {urn:jp.gr.jin.rrr.example.itemListType}Item
class Item
  @@schema_type = "Item"
  @@schema_ns = "urn:jp.gr.jin.rrr.example.itemListType"
  @@schema_element = [
    ["name", ["SOAP::SOAPString", XSD::QName.new(nil, "name")]]]

  attr_accessor :name

  def initialize(name = nil)
    @name = name
  end
end

# {urn:jp.gr.jin.rrr.example.itemListType}ItemList
class ItemList < ::Array
  @@schema_type = "Item"
  @@schema_ns = "urn:jp.gr.jin.rrr.example.itemListType"
  @@schema_element = [["Item", ["Item[]", XSD::QName.new(nil, "Item")]]]
end
