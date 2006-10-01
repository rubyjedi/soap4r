require 'xsd/qname'

# {urn:jp.gr.jin.rrr.example.itemListType}Item
class Item
  attr_accessor :name

  def initialize(name = nil)
    @name = name
  end
end

# {urn:jp.gr.jin.rrr.example.itemListType}ItemList
class ItemList < ::Array
end
