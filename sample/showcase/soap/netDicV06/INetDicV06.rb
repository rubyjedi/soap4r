module INetDicV06
  InterfaceNS = 'http://btonic.est.co.jp/NetDic/NetDicV06'

  Methods = [
    ['GetDicList',
      [:out, 'DicInfoList'], [:out, 'ErrorMessage'],
      [:retval, 'GetDicListResult']],
    ['SearchDicItem',
      [:in, 'DicID'], [:in, 'QueryString'], [:in, 'ScopeOption'],
      [:in, 'MatchOption'], [:in, 'FormatOption'], [:in, 'ResourceOption'],
      [:in, 'CharsetOption'], [:in, 'ReqItemIndex'],
      [:in, 'ReqItemTitleCount'], [:in, 'ReqItemContentCount']],
    ['GetDicItem',
      [:in, 'DicID'], [:in, 'ItemID'], [:in, 'FormatOption'],
      [:in, 'ResourceOption'], [:in, 'CharsetOption']],
  ]

  def INetDicV06.add_method( drv )
    Methods.each do |method, *param|
      drv.add_method_with_soapaction(method, InterfaceNS + "/#{ method }", param)
    end
  end

  class DicInfo
    attr_accessor :DicID
    attr_accessor :FullName
    attr_accessor :ShortName
    attr_accessor :Publisher
    attr_accessor :Abbrev
    attr_accessor :LogoURL
    attr_accessor :StartItemID
    attr_accessor :SearchOptionList
    attr_accessor :DefSearchOptionIndex
  end
end

