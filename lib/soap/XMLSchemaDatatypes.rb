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

  attr_accessor :data

  def initialize( typeName )
    super( typeName, Namespace )
    @data = nil
  end

  def to_s()
    @data.to_s
  end
end


###
## Basic datatypes.
#
class XSDNil < XSDBase
  def initialize( initNil = nil )
    super( XSD::NilLiteral )
    set( initNil )
  end

  def set( newNil )
    @data = newNil
  end
end

class XSDBoolean < XSDBase
public

  def initialize( initBoolean = false )
    super( BooleanLiteral )
    set( initBoolean )
  end

  def set( newBoolean )
    if newBoolean.is_a?( String )
      if newBoolean == 'true' || newBoolean == '1'
	@data = true
      elsif newBoolean == 'false' || newBoolean == '0'
	@data = false
      else
	raise ValueSpaceError.new( "Boolean: #{ newBoolean } is not acceptable." )
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
    set( initString ) if initString
  end

  def set( newString )
    @data = String.new( newString )
  end
end

class XSDDecimal < XSDBase
public

  def initialize( initDecimal = nil )
    super( DecimalLiteral )
    set( initDecimal ) if initDecimal
  end

  def set( newDecimal )
    @data = newDecimal.to_f
  end
end

class XSDFloat < XSDBase
public

  def initialize( initFloat = nil )
    super( FloatLiteral )
    set( initFloat ) if initFloat
  end

  def set( newFloat )
    # "NaN".to_f => 0 in some environment.  libc?
    @data = if newFloat.is_a?( Float )
	narrowTo32bit( newFloat )
      elsif newFloat == 'NaN'
        0.0/0.0
      elsif newFloat == 'INF'
        1.0/0.0
      elsif newFloat == '-INF'
        -1.0/0.0
      else
        narrowTo32bit( newFloat.to_f )
      end
  end

  # Do I have to convert 0.0 -> 0 and -0.0 -> -0 ?
  def to_s
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

private
  # Convert to single-precision 32-bit floating point value.
  def narrowTo32bit( f )
    if f.nan? || f.infinite?
      f
    else
      sprintf( "%f", f ).to_f
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

  def set( newDouble )
    # "NaN".to_f => 0 in some environment.  libc?
    @data = if newDouble.is_a?( Float )
	newDouble
      elsif newDouble == 'NaN'
        0.0/0.0
      elsif newDouble == 'INF'
        1.0/0.0
      elsif newDouble == '-INF'
        -1.0/0.0
      else
        newDouble.to_f
      end
  end

  # Do I have to convert 0.0 -> 0 and -0.0 -> -0 ?
  def to_s
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
class XSDDateTime < XSDBase
  require 'date3'
  require 'parsedate3'

public

  def initialize( initDateTime = nil )
    super( DateTimeLiteral )
    set( initDateTime ) if initDateTime
  end

  def set( t )
    if ( t.is_a?( Date ))
      @data = t.dup
    elsif ( t.is_a?( Time ))
      gt = t.dup.gmtime
      @data = Date.new3( gt.year, gt.mon, gt.mday, gt.hour, gt.min, gt.sec )
    else
      tStr = t.to_s.sub( 'Z([-+]\d\d:?\d\d)?$' ) { $1 }
      ( year, mon, mday, hour, min, sec, zone, wday ) = ParseDate.parsedate( tStr )
      @data = Date.new3( year, mon, mday, hour, min, sec )

      if zone
	/^([-+])(\d\d):(\d\d)$/ =~ zone
	zoneSign = $1
	zoneHour = $2.to_i
	zoneMin = $3.to_i
	if !zoneHour.zero? || !zoneMin.zero?
	  diffDay = 0
	  case zoneSign
	  when '+'
	    diffDay = +( zoneHour * 3600 + zoneMin * 60 ).to_r / 86400
	  when '-'
	    diffDay = -( zoneHour * 3600 + zoneMin * 60 ).to_r / 86400
	  when nil
	    raise ValueSpaceError.new( "TimeZone: #{ zone } is not acceptable." )
	  else
	    raise ValueSpaceError.new( "TimeZone: #{ zone } is not acceptable." )
	  end
	  jd = @data.jd
	  fr1 = @data.fr1 - diffDay
	  @data = Date.new0( Date.jd_to_rjd( jd, fr1 ))
	end
      end
    end
  end

  def to_s
    @data.to_s.sub( /,.*$/, 'Z' )
  end
end

class XSDBase64Binary < XSDBase
public

  # String in Ruby could be a binary.
  def initialize( initString = nil )
    super( Base64BinaryLiteral )
    set( initString ) if initString
  end

  def set( newString )
    @data = [ newString ].pack( "m" )
  end

  def setEncoded( newBase64String )
    @data = String.new( newBase64String )
    @data.sub!( /^\s*/, '' )
    @data.sub!( /\s*$/, '' )
  end

  def toString
    @data.unpack( "m" )[ 0 ]
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

  def set( newInteger )
    @data = newInteger.to_i
  end
end

class XSDLong < XSDInteger
public

  def initialize( initLong = nil )
    super()
    @typeName = LongLiteral
    set( initLong ) if initLong
  end

  def set( newLong )
    @data = newLong.to_i

    unless validate( @data )
      raise ValueSpaceError.new( "Long: #{ @data } is not acceptable." )
    end
  end

private
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

  def set( newInt )
    @data = newInt.to_i

    unless validate( @data )
      raise ValueSpaceError.new( "Int: #{ @data } is not acceptable." )
    end
  end

private
  MaxInclusive = +2147483647
  MinInclusive = -2147483648

  def validate( v )
    (( MinInclusive <= v ) && ( v <= MaxInclusive ))
  end
end
