module IICD
  # All methods in a single namespace?!
  InterfaceNS = 'http://www.iwebmethod.net'

  Methods = [
    [ 'SearchWord', 'query', 'partial' ],
    [ 'GetItemById', 'id' ],
    [ 'EnumWords' ],
    [ 'FullTextSearch', 'query' ],
  ]

  def IICD.addMethod( drv )
    Methods.each do | method, *param |
      drv.addMethodWithSOAPAction( method, InterfaceNS + "/#{ method }", *param )
    end
  end
end
