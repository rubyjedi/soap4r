=begin
SOAP4R
Copyright (C) 2000 NAKAMURA Hiroshi.

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
  Namespace = 'http://www.w3.org/1999/XMLSchema/'
  InstanceNamespace = 'http://www.w3.org/1999/XMLSchema/instance/'
end


###
## The base class of all datatypes with Namespace.
#
class NSDBase
  public

  attr_reader :typeName
  attr_accessor :namespace

  def initialize( typeName, namespace )
    @typeName = typeName
    @namespace = namespace
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
class XSDNull < XSDBase
  def initialize()
    super( 'null' )
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

class XSDTimeInstant < XSDBase
  require 'parsedate2'

  public

  def initialize( initTimeInstant = nil )
    super( 'timeInstant' )
    set( initTimeInstant ) if initTimeInstant
  end

  def set( newTimeInstant )
    if ( newTimeInstant.is_a?( Time ))
      @data = newTimeInstant.dup
    else
      ( year, mon, mday, hour, min, sec, zone, wday ) = ParseDate.parsedate( newTimeInstant.to_s )
      @data = Time.mktime( year, mon, mday, hour, min, sec )
    end
  end
end


###
## Derived types
#
class XSDInteger < XSDDecimal
  public

  def initialize( initInteger = nil )
    super()
    @typeName = 'int'
    set( initInteger ) if initInteger
  end

  def set( newInteger )
    @data = newInteger.to_i
  end
end
