=begin
SOAP4R - Charset encoding handler.
Copyright (C) 2001 NAKAMURA Hiroshi.

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PRATICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 675 Mass
Ave, Cambridge, MA 02139, USA.
=end

module SOAP


module Charset
  @xmlInstanceEncoding = $KCODE
  @dataModelEncoding = $KCODE

public

  ###
  ## Maps
  #
  EncodingConvertMap = {}
  def Charset.setEncodingConvertMap
    begin
      require 'nkf'
      EncodingConvertMap[ [ 'EUC' , 'SJIS' ] ] =
	Proc.new { |str| NKF.nkf( '-sXm0', str ) }
      EncodingConvertMap[ [ 'SJIS', 'EUC'  ] ] =
	Proc.new { |str| NKF.nkf( '-eXm0', str ) }
    rescue LoadError
    end
  
    begin
      require 'uconv'
      EncodingConvertMap[ [ 'UTF8', 'EUC'  ] ] = Uconv.method( :u8toeuc )
      EncodingConvertMap[ [ 'UTF8', 'SJIS' ] ] = Uconv.method( :u8tosjis )
      EncodingConvertMap[ [ 'EUC' , 'UTF8' ] ] = Uconv.method( :euctou8 )
      EncodingConvertMap[ [ 'SJIS', 'UTF8' ] ] = Uconv.method( :sjistou8 )

      @xmlInstanceEncoding = 'UTF8'
      @dataModelEncoding = 'UTF8'
    rescue LoadError
    end

    # ToDo: Iconv support
  end
  self.setEncodingConvertMap

  CharsetMap = {
    'NONE' => 'us-ascii',
    'EUC' => 'euc-jp',
    'SJIS' => 'shift_jis',
    'UTF8' => 'utf-8',
  }


  ###
  ## handlers
  #
  def Charset.getEncoding
    @dataModelEncoding
  end

  def Charset.setXMLInstanceEncoding( streamEncoding )
    @xmlInstanceEncoding = streamEncoding
  end

  def Charset.getXMLInstanceEncoding
    @xmlInstanceEncoding
  end

  def Charset.encodingToXML( str )
    codeConv( str, getEncoding, getXMLInstanceEncoding )
  end

  def Charset.encodingFromXML( str )
    codeConv( str, getXMLInstanceEncoding, getEncoding )
  end

  def Charset.codeConv( str, encFrom, encTo )
    retStr = str
    if encFrom == 'NONE' or encTo == 'NONE'
      return retStr
    end
    if converter = EncodingConvertMap[ [ encFrom, encTo ] ]
      retStr = converter.call( str )
    end
    retStr
  end

  def Charset.getXMLInstanceEncodingLabel
    getCharsetLabel( getXMLInstanceEncoding )
  end

  def Charset.getCharsetLabel( encoding )
    CharsetMap[ encoding.upcase ]
  end

  def Charset.getCharsetStr( label )
    if label
      return CharsetMap.index( label.downcase )
    end
    return 'NONE'
  end

  # Original regexps: http://www.din.or.jp/~ohzaki/perl.htm
  # ascii_euc = '[\x00-\x7F]'
  ascii_euc = '[\x9\xa\xd\x20-\x7F]'	# XML 1.0 restricted.
  twoBytes_euc = '(?:[\x8E\xA1-\xFE][\xA1-\xFE])'
  threeBytes_euc = '(?:\x8F[\xA1-\xFE][\xA1-\xFE])'
  character_euc = "(?:#{ ascii_euc }|#{ twoBytes_euc }|#{ threeBytes_euc })"
  EUCRegexp = Regexp.new( "\\A#{ character_euc }*\\z", nil, "NONE" )

  # oneByte_sjis = '[\x00-\x7F\xA1-\xDF]'
  oneByte_sjis = '[\x9\xa\xd\x20-\x7F\xA1-\xDF]'	# XML 1.0 restricted.
  twoBytes_sjis = '(?:[\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC])'
  character_sjis = "(?:#{ oneByte_sjis }|#{ twoBytes_sjis })"
  SJISRegexp = Regexp.new( "\\A#{ character_sjis }*\\z", nil, "NONE" )

  # 0xxxxxxx
  #ascii_utf8 = '[\0-\x7F]'
  ascii_utf8 = '[\x9\xA\xD\x20-\x7F]'	# XML 1.0 restricted.
  # 110yyyyy 10xxxxxx
  twoBytes_utf8 = '(?:[\xC0-\xDF][\x80-\xBF])'
  # 1110zzzz 10yyyyyy 10xxxxxx
  threeBytes_utf8 = '(?:[\xE0-\xEF][\x80-\xBF][\x80-\xBF])'
  # 11110uuu 10uuuzzz 10yyyyyy 10xxxxxx
  fourBytes_utf8 = '(?:[\xF0-\xF7][\x80-\xBF][\x80-\xBF][\x80-\xBF])'
  character_utf8 = "(?:#{ ascii_utf8 }|#{ twoBytes_utf8 }|#{ threeBytes_utf8 }|#{ fourBytes_utf8 })"
  UTF8Regexp = Regexp.new( "\\A#{ character_utf8 }*\\z", nil, "NONE" )

  def Charset.isUTF8( str )
    UTF8Regexp =~ str
  end

  def Charset.isEUC( str )
    EUCRegexp =~ str
  end

  def Charset.isSJIS( str )
    SJISRegexp =~ str
  end

  def Charset.isCES( str, code = $KCODE )
    case code
    when 'NONE'
      true
    when 'UTF8'
      isUTF8( str )
    when 'EUC'
      isEUC( str )
    when 'SJIS'
      isSJIS( str )
    else
      raise RuntimeError.new( "Unknown encoding: #{ code }" )
    end
  end
end


end
