=begin
SOAP4R - XML Schema Datatype implementation.
Copyright (C) 2000, 2001 NAKAMURA Hiroshi.

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


###
## XMLSchamaDatatypes general definitions.
#
module XSD
  Namespace = 'http://www.w3.org/2001/XMLSchema'
  InstanceNamespace = 'http://www.w3.org/2001/XMLSchema-instance'

  AttrType = 'type'

  AnyTypeLiteral = 'anyType'
  NilLiteral = 'nil'
  NilValue = 'true'
  BooleanLiteral = 'boolean'
  StringLiteral = 'string'
  FloatLiteral = 'float'
  DoubleLiteral = 'double'
  DateTimeLiteral = 'dateTime'
  TimeLiteral = 'time'
  DateLiteral = 'date'
  HexBinaryLiteral = 'hexBinary'
  Base64BinaryLiteral = 'base64Binary'
  DecimalLiteral = 'decimal'
  IntegerLiteral = 'integer'
  LongLiteral = 'long'
  IntLiteral = 'int'

  class Error < StandardError; end
  class ValueSpaceError < Error; end
end


###
## The base class of all datatypes with Namespace.
#
class NSDBase
public

  attr_accessor :typeName
  attr_accessor :typeNamespace

  def initialize( typeName, typeNamespace )
    @typeName = typeName
    @typeNamespace = typeNamespace
  end

  def typeEqual( typeNamespace, typeName )
    ( @typeNamespace == typeNamespace and @typeName == typeName )
  end
end


###
## The base class of XSD datatypes.
#
class XSDBase < NSDBase
  include XSD

public

  attr_reader :data
  attr_accessor :isNil

  def initialize( typeName )
    super( typeName, Namespace )
    @data = nil
    @isNil = true
  end

  def set( newData )
    if newData.nil?
      @isNil = true
      @data = nil
    else
      @isNil = false
      _set( newData )
    end
  end

  def to_s()
    if @isNil
      ""
    else
      _to_s
    end
  end

  def method_missing( msg_id, *params )
    if @data
      @data.send( msg_id, *params )
    else
      nil
    end
  end

protected
  def trim( data )
    data.sub( /\A\s*(\S*)\s*\z/, '\1' )
  end

private
  def _set( newData )
    raise NotImplementedError.new
  end

  def _to_s
    @data.to_s
  end
end


###
## Basic datatypes.
#
class XSDNil < XSDBase
public
  def initialize( initNil = nil )
    super( XSD::NilLiteral )
    set( initNil )
  end

private
  def _set( newNil )
    @data = newNil
  end
end

class XSDBoolean < XSDBase
public
  def initialize( initBoolean = nil )
    super( BooleanLiteral )
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
	raise ValueSpaceError.new( "Boolean: #{ str } is not acceptable." )
      end
    else
      @data = newBoolean ? true : false
    end
  end
end

class XSDString < XSDBase
public
  def initialize( initString = nil )
    super( StringLiteral )
    @encoding = nil
    set( initString ) if initString
  end

private
  def _set( newString )
    unless SOAP::Charset.isUTF8( newString )
      raise ValueSpaceError.new( "String: #{ newString } is not acceptable." )
    end
    @data = newString
  end
end

class XSDDecimal < XSDBase
public
  def initialize( initDecimal = nil )
    super( DecimalLiteral )
    @sign = ''
    @number = ''
    @point = 0
    set( initDecimal ) if initDecimal
  end

  # override original definition.
  def data
    _to_s
  end

private
  def _set( newDecimal )
    /^([+-]?)(\d*)(?:\.(\d*)?)?$/ =~ trim( newDecimal.to_s )
    unless Regexp.last_match
      raise ValueSpaceError.new( "Decimal: #{ newDecimal } is not acceptable." )
    end

    @sign = $1 || '+'
    integerPart = $2
    fractionPart = $3

    integerPart = integerPart.empty? ? '0' : integerPart.sub( '^0+', '0' )
    fractionPart = fractionPart ? fractionPart.sub( '0+$', '' ) : ''
    @point = - fractionPart.size
    @number = integerPart + fractionPart

    # normalize
    @sign = '' if @sign == '+'
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

class XSDFloat < XSDBase
public
  def initialize( initFloat = nil )
    super( FloatLiteral )
    set( initFloat ) if initFloat
  end

private
  def _set( newFloat )
    # "NaN".to_f => 0 in some environment.  libc?
    @data = if newFloat.is_a?( Float )
	narrowTo32bit( newFloat )
      else
	str = trim( newFloat.to_s )
	if str == 'NaN'
	  0.0/0.0
	elsif str == 'INF'
	  1.0/0.0
	elsif str == '-INF'
	  -1.0/0.0
	else
	  narrowTo32bit( Float( str ))
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
      @data.to_s
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
class XSDDouble < XSDBase
public
  def initialize( initDouble = nil )
    super( DoubleLiteral )
    set( initDouble ) if initDouble
  end

private
  def _set( newDouble )
    # "NaN".to_f => 0 in some environment.  libc?
    @data = if newDouble.is_a?( Float )
	newDouble
      else
	str = trim( newDouble.to_s )
	if str == 'NaN'
	  0.0/0.0
	elsif str == 'INF'
	  1.0/0.0
	elsif str == '-INF'
	  -1.0/0.0
	else
	  Float( str )
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
      @data.to_s
    end
  end
end

require 'rational'
# This is a workaround untill date2.rb will be included in standard library as
# date.rb.
if Object.const_defined?( :Date )
  Object.module_eval { remove_const( :Date ) }
end
$" << 'date.rb' << 'date2.rb'
load 'date2.rb'

module XSDDateTimeImpl
  def to_time
    begin
      Time.gm( @data.year, @data.month, @data.mday, @data.hour, @data.min,
       	@data.sec )
    rescue ArgumentError
      nil
    end
  end

  def ofFromTZ( zoneStr )
    /^(?:Z|(?:([+-])(\d\d):(\d\d))?)$/ =~ zoneStr
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
end

class XSDDateTime < XSDBase
  include XSDDateTimeImpl

public
  def initialize( initDateTime = nil )
    super( DateTimeLiteral )
    set( initDateTime ) if initDateTime
  end

private
  SecInDay = 86400	# 24 * 60 * 60

  def _set( t )
    if ( t.is_a?( DateTime ))
      @data = t
    elsif ( t.is_a?( Time ))
      # Should TZ be saved?
      gt = t.dup.gmtime
      @data = DateTime.civil( gt.year, gt.mon, gt.mday, gt.hour, gt.min, gt.sec )
    else
      /^([+-]?\d\d\d\d)-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d(?:\.(\d*))?)(Z|(?:[+-]\d\d:\d\d)?)?$/ =~ trim( t.to_s )
      unless Regexp.last_match
	raise ValueSpaceError.new( "DateTime: #{ t } is not acceptable." )
      end

      year = $1.to_i
      mon = $2.to_i
      mday = $3.to_i
      hour = $4.to_i
      min = $5.to_i
      sec = $6.to_i
      sec_frac = $7
      zoneStr = $8

      @data = DateTime.civil( year, mon, mday, hour, min, sec,
	ofFromTZ( zoneStr ))

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
  end

  def _to_s
    # Adjust to UTC.
    d = @data.new_offset
    # This format string is from date.rb of newdate-0.2.
    s = format('%.4d-%02d-%02dT%02d:%02d:%02d',
      d.year, d.mon, d.mday, d.hour, d.min, d.sec )
    if d.sec_fraction.nonzero?
      fr = d.sec_fraction * SecInDay
      shiftSize = fr.denominator.to_s.size
      fr_s = ( fr * ( 10 ** shiftSize )).to_i.to_s
      s << '.' << '0' * ( shiftSize - fr_s.size ) << fr_s.sub( '0+$', '' )
    end
    s + 'Z'
  end
end

class XSDTime < XSDBase
  include XSDDateTimeImpl

public
  def initialize( initTime = nil )
    super( TimeLiteral )
    set( initTime ) if initTime
  end

private
  def _set( t )
    if ( t.is_a?( Time ))
      @data = t
    else
      /^(\d\d):(\d\d):(\d\d(?:\.(\d*))?)(?:Z|(?:([+-])(\d\d):(\d\d))?)?$/ =~ trim( t.to_s )
      unless Regexp.last_match
	raise ValueSpaceError.new( "Time: #{ t } is not acceptable." )
      end

      hour = $1.to_i
      min = $2.to_i
      sec = $3.to_i
      sec_frac = $4
      zoneSign = $5
      zoneHour = $6.to_i
      zoneMin = $7.to_i

      usec = 0
      if sec_frac
	# Truncate fraction part at usec.
	# 0.9 [sec] => 0 [sec]
	# 1.1 [sec] => 1 [sec]
	usec = ( sec_frac + "00000" )[ 0, 6 ].to_i
      end

      @data = Time.mktime( 2000, 1, 1, hour, min, sec, usec )

      if zoneSign
	if !zoneHour.zero? || !zoneMin.zero?
	  diffSec = 0
	  case zoneSign
	  when '+'
	    diffSec = +( zoneHour * 3600 + zoneMin * 60 )
	  when '-'
	    diffSec = -( zoneHour * 3600 + zoneMin * 60 )
	  when nil
	    raise ValueSpaceError.new( "TimeZone: #{ zoneHour }:#{ zoneMin } is not acceptable." )
	  else
	    raise ValueSpaceError.new( "TimeZone: #{ zoneHour }:#{ zoneMin } is not acceptable." )
	  end
	  @data += diffSec
	end
      end
    end
  end

  def _to_s
    s = if @data.usec.zero?
      format( '%02d:%02d:%02d', @data.hour, @data.min, @data.sec )
    else
      format( '%02d:%02d:%02d.%06d', @data.hour, @data.min, @data.sec, @data.usec )
    end
    s + 'Z'
  end
end

class XSDDate < XSDBase
  include XSDDateTimeImpl

public
  def initialize( initDate = nil )
    super( DateLiteral )
    set( initDate ) if initDate
  end

private
  def _set( t )
    if ( t.is_a?( Date ))
      @data = t
    elsif ( t.is_a?( Time ))
      gt = t.dup.gmtime
      @data = DateTime.civil( gt.year, gt.mon, gt.mday )
    else
      /^([+-]?\d\d\d\d)-(\d\d)-(\d\d)$/ =~ trim( t.to_s )
      unless Regexp.last_match
	raise ValueSpaceError.new( "Time: #{ t } is not acceptable." )
      end

      year = $1.to_i
      mon = $2.to_i
      mday = $3.to_i

      @data = DateTime.civil( year, mon, mday )
    end
  end

  def _to_s
    s = @data.to_s.sub( /T.*$/, '' )
    s + 'Z'
  end
end

class XSDHexBinary < XSDBase
public
  # String in Ruby could be a binary.
  def initialize( initString = '' )
    super( HexBinaryLiteral )
    set( initString ) if initString
  end

  def setEncoded( newHexString )
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

class XSDBase64Binary < XSDBase
public
  # String in Ruby could be a binary.
  def initialize( initString = '' )
    super( Base64BinaryLiteral )
    set( initString ) if initString
  end

  def setEncoded( newBase64String )
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


###
## Derived types
#
class XSDInteger < XSDDecimal
public
  def initialize( initInteger = nil )
    super()
    @typeName = IntegerLiteral
    set( initInteger ) if initInteger
  end

  # re-override to recover original definition.
  def data
    @data
  end

private
  def _set( newInteger )
    @data = Integer(newInteger)
  end

  def _to_s()
    @data.to_s
  end
end

class XSDLong < XSDInteger
public
  def initialize( initLong = nil )
    super()
    @typeName = LongLiteral
    set( initLong ) if initLong
  end

private
  def _set( newLong )
    @data = Integer(newLong)

    unless validate( @data )
      raise ValueSpaceError.new( "Long: #{ @data } is not acceptable." )
    end
  end

  MaxInclusive = +9223372036854775807
  MinInclusive = -9223372036854775808

  def validate( v )
    (( MinInclusive <= v ) && ( v <= MaxInclusive ))
  end
end

class XSDInt < XSDLong
public
  def initialize( initInt = nil )
    super()
    @typeName = IntLiteral
    set( initInt ) if initInt
  end

private
  def _set( newInt )
    @data = Integer(newInt)

    unless validate( @data )
      raise ValueSpaceError.new( "Int: #{ @data } is not acceptable." )
    end
  end

  MaxInclusive = +2147483647
  MinInclusive = -2147483648

  def validate( v )
    (( MinInclusive <= v ) && ( v <= MaxInclusive ))
  end
end
