=begin
SOAP4R - XML Schema Datatype implementation.
Copyright (C) 2000, 2001, 2002, 2003 NAKAMURA Hiroshi.

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

require 'soap/charset'
require 'soap/qname'
require 'uri'


###
## XMLSchamaDatatypes general definitions.
#
module XSD
  Namespace = 'http://www.w3.org/2001/XMLSchema'
  InstanceNamespace = 'http://www.w3.org/2001/XMLSchema-instance'

  AttrType = 'type'
  NilValue = 'true'

  AnyTypeLiteral = 'anyType'
  AnySimpleTypeLiteral = 'anySimpleType'
  NilLiteral = 'nil'
  StringLiteral = 'string'
  BooleanLiteral = 'boolean'
  DecimalLiteral = 'decimal'
  FloatLiteral = 'float'
  DoubleLiteral = 'double'
  DurationLiteral = 'duration'
  DateTimeLiteral = 'dateTime'
  TimeLiteral = 'time'
  DateLiteral = 'date'
  GYearMonthLiteral = 'gYearMonth'
  GYearLiteral = 'gYear'
  GMonthDayLiteral = 'gMonthDay'
  GDayLiteral = 'gDay'
  GMonthLiteral = 'gMonth'
  HexBinaryLiteral = 'hexBinary'
  Base64BinaryLiteral = 'base64Binary'
  AnyURILiteral = 'anyURI'
  QNameLiteral = 'QName'

  NormalizedStringLiteral = 'normalizedString'
  IntegerLiteral = 'integer'
  LongLiteral = 'long'
  IntLiteral = 'int'
  ShortLiteral = 'short'

  AttrTypeName = QName.new( InstanceNamespace, AttrType )
  AttrNilName = QName.new( InstanceNamespace, NilLiteral )

  AnyTypeName = QName.new( Namespace, AnyTypeLiteral )
  AnySimpleTypeName = QName.new( Namespace, AnySimpleTypeLiteral )

  class Error < StandardError; end
  class ValueSpaceError < Error; end
end


###
## The base class of all datatypes with Namespace.
#
class NSDBase
  @@types = []

public
  attr_accessor :type

  def self.inherited( klass )
    @@types << klass
  end

  def self.types
    @@types
  end

  def initialize
    @type = nil
  end
end


###
## The base class of XSD datatypes.
#
class XSDAnySimpleType < NSDBase
  include XSD
  Type = QName.new( Namespace, AnySimpleTypeLiteral )

public

  # @data represents canonical space (ex. Integer: 123).
  attr_reader :data
  # @isNil represents this data is nil or not.
  attr_accessor :isNil

  def initialize( initObj = nil )
    super()
    @type = Type
    @data = nil
    @isNil = true
    set( initObj ) if initObj
  end

  # set accepts a string which follows lexical space (ex. String: "+123"), or
  # an object which follows canonical space (ex. Integer: 123).
  def set( newData )
    if newData.nil?
      @isNil = true
      @data = nil
    else
      @isNil = false
      _set( newData )
    end
  end

  # to_s creates a string which follows lexical space (ex. String: "123").
  def to_s()
    if @isNil
      ""
    else
      _to_s
    end
  end

protected
  def trim( data )
    data.sub( /\A\s*(\S*)\s*\z/, '\1' )
  end

private
  def _set( newObj )
    @data = newObj
  end

  def _to_s
    @data.to_s
  end
end

class XSDNil < XSDAnySimpleType
  Type = QName.new( Namespace, NilLiteral )
  Value = 'true'

public
  def initialize( initNil = nil )
    super()
    @type = Type
    set( initNil )
  end

private
  def _set( newNil )
    @data = newNil
  end
end


###
## Primitive datatypes.
#
class XSDString < XSDAnySimpleType
  Type = QName.new( Namespace, StringLiteral )

public
  def initialize( initString = nil )
    super()
    @type = Type
    @encoding = nil
    set( initString ) if initString
  end

private
  def _set( newString )
    unless SOAP::Charset.isCES( newString, SOAP::Charset.getEncoding )
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ newString }'." )
    end
    @data = newString
  end
end

class XSDBoolean < XSDAnySimpleType
  Type = QName.new( Namespace, BooleanLiteral )

public
  def initialize( initBoolean = nil )
    super()
    @type = Type
    set( initBoolean )
  end

private
  def _set( newBoolean )
    if newBoolean.is_a?( String )
      str = trim( newBoolean )
      if str == 'true' || str == '1'
	@data = true
      elsif str == 'false' || str == '0'
	@data = false
      else
	raise ValueSpaceError.new( "#{ type }: cannot accept '#{ str }'." )
      end
    else
      @data = newBoolean ? true : false
    end
  end
end

class XSDDecimal < XSDAnySimpleType
  Type = QName.new( Namespace, DecimalLiteral )

public
  def initialize( initDecimal = nil )
    super()
    @type = Type
    @sign = ''
    @number = ''
    @point = 0
    set( initDecimal ) if initDecimal
  end

  def nonzero?
    ( @number != '0' )
  end

private
  def _set( d )
    if d.is_a?( String )
      # Integer( "00012" ) => 10 in Ruby.
      d.sub!( /^([+\-]?)0*(?=\d)/, "\\1" )
    end
    set_str( d )
  end

  def set_str( str )
    /^([+\-]?)(\d*)(?:\.(\d*)?)?$/ =~ trim( str.to_s )
    unless Regexp.last_match
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ str }'." )
    end

    @sign = $1 || '+'
    integerPart = $2
    fractionPart = $3

    integerPart = '0' if integerPart.empty?
    fractionPart = fractionPart ? fractionPart.sub( /0+$/, '' ) : ''
    @point = - fractionPart.size
    @number = integerPart + fractionPart

    # normalize
    if @sign == '+'
      @sign = ''
    elsif @sign == '-'
      if @number == '0'
	@sign = ''
      end
    end

    @data = _to_s
  end

  # 0.0 -> 0; right?
  def _to_s
    str = @number.dup
    if @point.nonzero?
      str[ @number.size + @point, 0 ] = '.'
    end
    @sign + str
  end
end

class XSDFloat < XSDAnySimpleType
  Type = QName.new( Namespace, FloatLiteral )

public
  def initialize( initFloat = nil )
    super()
    @type = Type
    set( initFloat ) if initFloat
  end

private
  def _set( newFloat )
    # "NaN".to_f => 0 in some environment.  libc?
    if newFloat.is_a?( Float )
      @data = narrowTo32bit( newFloat )
      return
    end

    str = trim( newFloat.to_s )
    if str == 'NaN'
      @data = 0.0/0.0
    elsif str == 'INF'
      @data = 1.0/0.0
    elsif str == '-INF'
      @data = -1.0/0.0
    else
      if /^[+\-\.\deE]+$/ !~ str
	raise ValueSpaceError.new( "#{ type }: cannot accept '#{ str }'." )
      end
      # Float( "-1.4E" ) might fail on some system.
      str << '0' if /e$/i =~ str
      begin
  	@data = narrowTo32bit( Float( str ))
      rescue ArgumentError
  	raise ValueSpaceError.new( "#{ type }: cannot accept '#{ str }'." )
      end
    end
  end

  # Do I have to convert 0.0 -> 0 and -0.0 -> -0 ?
  def _to_s
    if @data.nan?
      'NaN'
    elsif @data.infinite? == 1
      'INF'
    elsif @data.infinite? == -1
      '-INF'
    else
      sprintf( "%.10g", @data )
    end
  end

  # Convert to single-precision 32-bit floating point value.
  def narrowTo32bit( f )
    if f.nan? || f.infinite?
      f
    else
      packed = [ f ].pack( "f" )
      ( /\A\0*\z/ =~ packed )? 0.0 : f
    end
  end
end

# Ruby's Float is double-precision 64-bit floating point value.
class XSDDouble < XSDAnySimpleType
  Type = QName.new( Namespace, DoubleLiteral )

public
  def initialize( initDouble = nil )
    super()
    @type = Type
    set( initDouble ) if initDouble
  end

private
  def _set( newDouble )
    # "NaN".to_f => 0 in some environment.  libc?
    if newDouble.is_a?( Float )
      @data = newDouble
      return
    end

    str = trim( newDouble.to_s )
    if str == 'NaN'
      @data = 0.0/0.0
    elsif str == 'INF'
      @data = 1.0/0.0
    elsif str == '-INF'
      @data = -1.0/0.0
    else
      begin
	@data = Float( str )
      rescue ArgumentError
	# '1.4e' cannot be parsed on some architecture.
	if /e\z/i =~ str
	  begin
	    @data = Float( str + '0' )
	  rescue ArgumentError
	    raise ValueSpaceError.new( "#{ type }: cannot accept '#{ str }'." )
	  end
	else
	  raise ValueSpaceError.new( "#{ type }: cannot accept '#{ str }'." )
	end
      end
    end
  end

  # Do I have to convert 0.0 -> 0 and -0.0 -> -0 ?
  def _to_s
    if @data.nan?
      'NaN'
    elsif @data.infinite? == 1
      'INF'
    elsif @data.infinite? == -1
      '-INF'
    else
      sprintf( "%.16g", @data )
    end
  end
end

class XSDDuration < XSDAnySimpleType
  Type = QName.new( Namespace, DurationLiteral )

public
  attr_accessor :sign
  attr_accessor :year
  attr_accessor :month
  attr_accessor :day
  attr_accessor :hour
  attr_accessor :min
  attr_accessor :sec

  def initialize( initDuration = nil )
    super()
    @type = Type
    @sign = nil
    @year = nil
    @month = nil
    @day = nil
    @hour = nil
    @min = nil
    @sec = nil
    set( initDuration ) if initDuration
  end

private
  def _set( newDuration )
    /^([+\-]?)P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)D)?(T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?)?$/ =~ trim( newDuration.to_s )
    unless Regexp.last_match
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ newDuration }'." )
    end

    if ( $5 and (( !$2 and !$3 and !$4 ) or ( !$6 and !$7 and !$8 )))
      # Should we allow 'PT5S' here?
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ newDuration }'." )
    end

    @sign = $1
    @year = $2.to_i
    @month = $3.to_i
    @day = $4.to_i
    @hour = $6.to_i
    @min = $7.to_i
    @sec = $8 ? XSDDecimal.new( $8 ) : 0
    @data = _to_s
  end

  def _to_s
    str = ''
    str << @sign if @sign
    str << 'P'
    l = ''
    l << "#{ @year }Y" if @year.nonzero?
    l << "#{ @month }M" if @month.nonzero?
    l << "#{ @day }D" if @day.nonzero?
    r = ''
    r << "#{ @hour }H" if @hour.nonzero?
    r << "#{ @min }M" if @min.nonzero?
    r << "#{ @sec }S" if @sec.nonzero?
    str << l
    if l.empty?
      str << "0D"
    end
    unless r.empty?
      str << "T" << r
    end
    str
  end
end


require 'rational'
require 'date'
unless Object.const_defined?( 'DateTime' )
  raise LoadError.new( 'SOAP4R requires date2/3.2 or later to be installed.  You can download it from http://www.funaba.org/en/ruby.html#date2' )
end

module XSDDateTimeImpl
  SecInDay = 86400	# 24 * 60 * 60

  def to_time
    begin
      if @data.of * SecInDay == Time.now.utc_offset
        d = @data
        usec = ( d.sec_fraction * SecInDay * 1000000 ).to_f
        Time.local( d.year, d.month, d.mday, d.hour, d.min, d.sec, usec )
      else
        d = @data.newof
        usec = ( d.sec_fraction * SecInDay * 1000000 ).to_f
        Time.gm( d.year, d.month, d.mday, d.hour, d.min, d.sec, usec )
      end
    rescue ArgumentError
      nil
    end
  end

  def ofFromTZ( zoneStr )
    /^(?:Z|(?:([+\-])(\d\d):(\d\d))?)$/ =~ zoneStr
    zoneSign = $1
    zoneHour = $2.to_i
    zoneMin = $3.to_i

    of = case zoneSign
      when '+'
	of = +( zoneHour.to_r * 60 + zoneMin ) / 1440	# 24 * 60
      when '-'
	of = -( zoneHour.to_r * 60 + zoneMin ) / 1440	# 24 * 60
      else
	0
      end
    of
  end

  def tzFromOf( offset )
    diffmin = offset * 24 * 60
    if diffmin.zero?
      'Z'
    else
      (( diffmin < 0 ) ? '-' : '+' ) << format( '%02d:%02d',
    	( diffmin.abs / 60.0 ).to_i, ( diffmin.abs % 60.0 ).to_i )
    end
  end

  def _set( t )
    if ( t.is_a?( Date ))
      @data = t
    elsif ( t.is_a?( Time ))
      sec, min, hour, mday, month, year = t.to_a[ 0..5 ]
      diffDay = t.usec.to_r / 1000000 / SecInDay
      of = t.utc_offset.to_r / SecInDay
      @data = DateTime.civil( year, month, mday, hour, min, sec, of )
      @data += diffDay
    else
      set_str( t )
    end
  end

  def addTz( s )
    s + tzFromOf( @data.offset )
  end
end

class XSDDateTime < XSDAnySimpleType
  include XSDDateTimeImpl
  Type = QName.new( Namespace, DateTimeLiteral )

public
  def initialize( initDateTime = nil )
    super()
    @type = Type
    set( initDateTime ) if initDateTime
  end

private
  def set_str( t )
    /^([+\-]?\d\d\d\d\d*)-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d(?:\.(\d*))?)(Z|(?:[+\-]\d\d:\d\d)?)?$/ =~ trim( t.to_s )
    unless Regexp.last_match
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ t }'." )
    end
    if $1 == '0000'
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ t }'." )
    end

    year = $1.to_i
    if year < 0
      year += 1
    end
    mon = $2.to_i
    mday = $3.to_i
    hour = $4.to_i
    min = $5.to_i
    sec = $6.to_i
    sec_frac = $7
    zoneStr = $8

    @data = DateTime.civil( year, mon, mday, hour, min, sec, ofFromTZ( zoneStr ))

    if sec_frac
      diffDay = sec_frac.to_i.to_r / ( 10 ** sec_frac.size ) / SecInDay
      # jd = @data.jd
      # day_fraction = @data.day_fraction + diffDay
      # @data = DateTime.new0( DateTime.jd_to_rjd( jd, day_fraction,
      #   @data.offset ), @data.offset )
      #
      # Thanks to Funaba-san, above code can be simply written as below.
      @data += diffDay
      # FYI: new0 and jd_to_rjd are not necessary to use if you don't have
      # exceptional reason.
    end
  end

  def _to_s
    year = ( @data.year > 0 ) ? @data.year : @data.year - 1
    s = format( '%.4d-%02d-%02dT%02d:%02d:%02d',
      year, @data.mon, @data.mday, @data.hour, @data.min, @data.sec )
    if @data.sec_fraction.nonzero?
      fr = @data.sec_fraction * SecInDay
      shiftSize = fr.denominator.to_s.size
      fr_s = ( fr * ( 10 ** shiftSize )).to_i.to_s
      s << '.' << '0' * ( shiftSize - fr_s.size ) << fr_s.sub( /0+$/, '' )
    end
    addTz( s )
  end
end

class XSDTime < XSDAnySimpleType
  include XSDDateTimeImpl
  Type = QName.new( Namespace, TimeLiteral )

public
  def initialize( initTime = nil )
    super()
    @type = Type
    set( initTime ) if initTime
  end

private
  def set_str( t )
    /^(\d\d):(\d\d):(\d\d(?:\.(\d*))?)(Z|(?:([+\-])(\d\d):(\d\d))?)?$/ =~ trim( t.to_s )
    unless Regexp.last_match
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ t }'." )
    end

    hour = $1.to_i
    min = $2.to_i
    sec = $3.to_i
    sec_frac = $4
    zoneStr = $5

    @data = DateTime.civil( 1, 1, 1, hour, min, sec, ofFromTZ( zoneStr ))

    if sec_frac
      @data += sec_frac.to_i.to_r / ( 10 ** sec_frac.size ) / SecInDay
    end
  end

  def _to_s
    s = format( '%02d:%02d:%02d', @data.hour, @data.min, @data.sec )
    if @data.sec_fraction.nonzero?
      fr = @data.sec_fraction * SecInDay
      shiftSize = fr.denominator.to_s.size
      fr_s = ( fr * ( 10 ** shiftSize )).to_i.to_s
      s << '.' << '0' * ( shiftSize - fr_s.size ) << fr_s.sub( /0+$/, '' )
    end
    addTz( s )
  end
end

class XSDDate < XSDAnySimpleType
  include XSDDateTimeImpl
  Type = QName.new( Namespace, DateLiteral )

public
  def initialize( initDate = nil )
    super()
    @type = Type
    set( initDate ) if initDate
  end

private
  def set_str( t )
    /^([+\-]?\d\d\d\d\d*)-(\d\d)-(\d\d)(Z|(?:([+\-])(\d\d):(\d\d))?)?$/ =~ trim( t.to_s )
    unless Regexp.last_match
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ t }'." )
    end

    year = $1.to_i
    if year < 0
      year += 1
    end
    mon = $2.to_i
    mday = $3.to_i
    zoneStr = $4

    @data = DateTime.civil( year, mon, mday, 0, 0, 0, ofFromTZ( zoneStr ))
  end

  def _to_s
    year = ( @data.year > 0 ) ? @data.year : @data.year - 1
    s = format( '%.4d-%02d-%02d', year, @data.mon, @data.mday )
    addTz( s )
  end
end

class XSDGYearMonth < XSDAnySimpleType
  include XSDDateTimeImpl
  Type = QName.new( Namespace, GYearMonthLiteral )

public
  def initialize( initGYearMonth = nil )
    super()
    @type = Type
    set( initGYearMonth ) if initGYearMonth
  end

private
  def set_str( t )
    /^([+\-]?\d\d\d\d\d*)-(\d\d)(Z|(?:([+\-])(\d\d):(\d\d))?)?$/ =~ trim( t.to_s )
    unless Regexp.last_match
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ t }'." )
    end

    year = $1.to_i
    if year < 0
      year += 1
    end
    mon = $2.to_i
    zoneStr = $3

    @data = DateTime.civil( year, mon, 1, 0, 0, 0, ofFromTZ( zoneStr ))
  end

  def _to_s
    year = ( @data.year > 0 ) ? @data.year : @data.year - 1
    s = format( '%.4d-%02d', year, @data.mon )
    addTz( s )
  end
end

class XSDGYear < XSDAnySimpleType
  include XSDDateTimeImpl
  Type = QName.new( Namespace, GYearLiteral )

public
  def initialize( initGYear = nil )
    super()
    @type = Type
    set( initGYear ) if initGYear
  end

private
  def set_str( t )
    /^([+\-]?\d\d\d\d\d*)(Z|(?:([+\-])(\d\d):(\d\d))?)?$/ =~ trim( t.to_s )
    unless Regexp.last_match
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ t }'." )
    end

    year = $1.to_i
    if year < 0
      year += 1
    end
    zoneStr = $2

    @data = DateTime.civil( year, 1, 1, 0, 0, 0, ofFromTZ( zoneStr ))
  end

  def _to_s
    year = ( @data.year > 0 ) ? @data.year : @data.year - 1
    s = format( '%.4d', year )
    addTz( s )
  end
end

class XSDGMonthDay < XSDAnySimpleType
  include XSDDateTimeImpl
  Type = QName.new( Namespace, GMonthDayLiteral )

public
  def initialize( initGMonthDay = nil )
    super()
    @type = Type
    set( initGMonthDay ) if initGMonthDay
  end

private
  def set_str( t )
    /^(\d\d)-(\d\d)(Z|(?:[+\-]\d\d:\d\d)?)?$/ =~ trim( t.to_s )
    unless Regexp.last_match
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ t }'." )
    end

    mon = $1.to_i
    mday = $2.to_i
    zoneStr = $3

    @data = DateTime.civil( 1, mon, mday, 0, 0, 0, ofFromTZ( zoneStr ))
  end

  def _to_s
    s = format( '%02d-%02d', @data.mon, @data.mday )
    addTz( s )
  end
end

class XSDGDay < XSDAnySimpleType
  include XSDDateTimeImpl
  Type = QName.new( Namespace, GDayLiteral )

public
  def initialize( initGDay = nil )
    super()
    @type = Type
    set( initGDay ) if initGDay
  end

private
  def set_str( t )
    /^(\d\d)(Z|(?:[+\-]\d\d:\d\d)?)?$/ =~ trim( t.to_s )
    unless Regexp.last_match
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ t }'." )
    end

    mday = $1.to_i
    zoneStr = $2

    @data = DateTime.civil( 1, 1, mday, 0, 0, 0, ofFromTZ( zoneStr ))
  end

  def _to_s
    s = format( '%02d', @data.mday )
    addTz( s )
  end
end

class XSDGMonth < XSDAnySimpleType
  include XSDDateTimeImpl
  Type = QName.new( Namespace, GMonthLiteral )

public
  def initialize( initGMonth = nil )
    super()
    @type = Type
    set( initGMonth ) if initGMonth
  end

private
  def set_str( t )
    /^(\d\d)(Z|(?:[+\-]\d\d:\d\d)?)?$/ =~ trim( t.to_s )
    unless Regexp.last_match
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ t }'." )
    end

    mon = $1.to_i
    zoneStr = $2

    @data = DateTime.civil( 1, mon, 1, 0, 0, 0, ofFromTZ( zoneStr ))
  end

  def _to_s
    s = format( '%02d', @data.mon )
    addTz( s )
  end
end

class XSDHexBinary < XSDAnySimpleType
  Type = QName.new( Namespace, HexBinaryLiteral )

public
  # String in Ruby could be a binary.
  def initialize( initString = nil )
    super()
    @type = Type
    set( initString ) if initString
  end

  def setEncoded( newHexString )
    if /^[0-9a-fA-F]*$/ !~ newHexString
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ newHexString }'." )
    end
    @data = trim( String.new( newHexString ))
    @isNil = false
  end

  def toString
    [ @data ].pack( "H*" )
  end

private
  def _set( newString )
    @data = newString.unpack( "H*" )[ 0 ]
    @data.tr!( 'a-f', 'A-F' )
  end
end

class XSDBase64Binary < XSDAnySimpleType
  Type = QName.new( Namespace, Base64BinaryLiteral )

public
  # String in Ruby could be a binary.
  def initialize( initString = nil )
    super()
    @type = Type
    set( initString ) if initString
  end

  def setEncoded( newBase64String )
    if /^[A-Za-z0-9+\/=]*$/ !~ newBase64String
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ newBase64String }'." )
    end
    @data = trim( String.new( newBase64String ))
    @isNil = false
  end

  def toString
    @data.unpack( "m" )[ 0 ]
  end

private
  def _set( newString )
    @data = trim( [ newString ].pack( "m" ))
  end
end

class XSDAnyURI < XSDAnySimpleType
  Type = QName.new( Namespace, AnyURILiteral )

public
  def initialize( initAnyURI = nil )
    super()
    @type = Type
    set( initAnyURI ) if initAnyURI
  end

private
  def _set( newAnyURI )
    begin
      @data = URI.parse( trim( newAnyURI.to_s ))
    rescue URI::InvalidURIError
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ newAnyURI }'." )
    end
  end
end

class XSDQName < XSDAnySimpleType
  Type = QName.new( Namespace, QNameLiteral )

public
  def initialize( initQName = nil )
    super()
    @type = Type
    set( initQName ) if initQName
  end

private
  def _set( newQName )
    /^(?:([^:]+):)?([^:]+)$/ =~ trim( newQName.to_s )
    unless Regexp.last_match
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ newQName }'." )
    end

    @prefix = $1
    @localPart = $2
    @data = _to_s
  end

  def _to_s
    if @prefix
      "#{ @prefix }:#{ @localPart }"
    else
      "#{ @localPart }"
    end
  end
end


###
## Derived types
#
class XSDNormalizedString < XSDString
  Type = QName.new( Namespace, NormalizedStringLiteral )

public
  def initialize( initNormalizedString = nil )
    super()
    @type = Type
    set( initNormalizedString ) if initNormalizedString
  end

private
  def _set( newNormalizedString )
    if /[\t\r\n]/ =~ newNormalizedString
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ newNormalizedString }'." )
    end
    super
  end
end

class XSDInteger < XSDDecimal
  Type = QName.new( Namespace, IntegerLiteral )

public
  def initialize( initInteger = nil )
    super()
    @type = Type
    set( initInteger ) if initInteger
  end

private
  def set_str( str )
    begin
      @data = Integer( str )
    rescue ArgumentError
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ str }'." )
    end
  end

  def _to_s()
    @data.to_s
  end
end

class XSDLong < XSDInteger
  Type = QName.new( Namespace, LongLiteral )

public
  def initialize( initLong = nil )
    super()
    @type = Type
    set( initLong ) if initLong
  end

private
  def set_str( str )
    begin
      @data = Integer( str )
    rescue ArgumentError
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ str }'." )
    end
    unless validate( @data )
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ str }'." )
    end
  end

  MaxInclusive = +9223372036854775807
  MinInclusive = -9223372036854775808
  def validate( v )
    (( MinInclusive <= v ) && ( v <= MaxInclusive ))
  end
end

class XSDInt < XSDLong
  Type = QName.new( Namespace, IntLiteral )

public
  def initialize( initInt = nil )
    super()
    @type = Type
    set( initInt ) if initInt
  end

private
  def set_str( str )
    begin
      @data = Integer( str )
    rescue ArgumentError
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ str }'." )
    end
    unless validate( @data )
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ str }'." )
    end
  end

  MaxInclusive = +2147483647
  MinInclusive = -2147483648
  def validate( v )
    (( MinInclusive <= v ) && ( v <= MaxInclusive ))
  end
end

class XSDShort < XSDInt
  Type = QName.new( Namespace, ShortLiteral )

public
  def initialize( initShort = nil )
    super()
    @type = Type
    set( initShort ) if initShort
  end

private
  def set_str( str )
    begin
      @data = Integer( str )
    rescue ArgumentError
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ str }'." )
    end
    unless validate( @data )
      raise ValueSpaceError.new( "#{ type }: cannot accept '#{ str }'." )
    end
  end

  MaxInclusive = +32767
  MinInclusive = -32768
  def validate( v )
    (( MinInclusive <= v ) && ( v <= MaxInclusive ))
  end
end
