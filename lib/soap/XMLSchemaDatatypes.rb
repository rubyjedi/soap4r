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
  NilLiteral = 'nil'
  #Namespace = 'http://www.w3.org/1999/XMLSchema'
  #InstanceNamespace = 'http://www.w3.org/1999/XMLSchema-instance'
  #NilLiteral = 'null'
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
  def initialize()
    super( XSD::NilLiteral )
  end
end

class XSDBoolean < XSDBase
  public

  def initialize( initBoolean = false )
    super( 'boolean' )
    set( initBoolean )
  end

  def set( newBoolean )
    if newBoolean.is_a?( String )
      if newBoolean.downcase == 'true'
	@data = true
      else
	@data = false
      end
    else
      @data = newBoolean ? true : false
    end
  end
end

class XSDString < XSDBase
  public

  def initialize( initString = nil )
    super( 'string' )
    set( initString ) if initString
  end

  def set( newString )
    @data = String.new( newString )
  end
end

class XSDDecimal < XSDBase
  public

  def initialize( initDecimal = nil )
    super( 'decimal' )
    set( initDecimal ) if initDecimal
  end

  def set( newDecimal )
    @data = newDecimal.to_f
  end
end

class XSDFloat < XSDBase
  public

  def initialize( initFloat = nil )
    super( 'float' )
    set( initFloat ) if initFloat
  end

  def set( newFloat )
    @data = newFloat.to_f
  end
end

class XSDDateTime < XSDBase
  require 'date3'
  require 'parsedate3'

  public

  def initialize( initDateTime = nil )
    super( 'dateTime' )
    set( initDateTime ) if initDateTime
  end

  def set( t )
    if ( t.is_a?( Date ))
      @data = t.dup
    elsif ( t.is_a?( Time ))
      gt = t.dup.gmtime
      @data = Date.new3( gt.year, gt.mon, gt.mday, gt.hour, gt.min, gt.sec )
    else
      ( year, mon, mday, hour, min, sec, zone, wday ) = ParseDate.parsedate( t.to_s )
      if $DEBUG && zone
	$stderr.puts "Timezone in String is not supported.  Set a Date or a Time directly!"
      end
      @data = Date.new3( year, mon, mday, hour, min )
    end
  end

  def to_s
    @data.to_s.sub( /,.*$/, '' )
  end
end

class XSDBase64Binary < XSDBase
  public

  # String in Ruby could be a binary.
  def initialize( initString = nil )
    super( 'base64Binary' )
    set( initString ) if initString
  end

  def set( newString )
    @data = [ newString ].pack( "m" )
  end

  def setEncoded( newBase64String )
    @data = String.new( newBase64String )
  end

  def to_s
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
    @typeName = 'integer'
    set( initInteger ) if initInteger
  end

  def set( newInteger )
    @data = newInteger.to_i
  end
end

class XSDInt < XSDInteger
  public

  def initialize( initInt = nil )
    super()
    @typeName = 'int'
    set( initInt ) if initInt
  end

  def set( newInt )
    @data = newInt.to_i
  end
end
