=begin
WSDL4R - Creating class definition from WSDL
Copyright (C) 2002 NAKAMURA Hiroshi.

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


require 'wsdl/data'
require 'wsdl/soap/methodDefCreatorSupport'


module WSDL
  module SOAP


class ClassDefCreator
  include MethodDefCreatorSupport

  attr_reader :definitions
  attr_reader :schema

  def initialize( definitions )
    @definitions = definitions
    @complexTypes = definitions.complexTypes
    @faultTypes = getFaultTypes( @definitions )
  end

  def dump( className = nil )
    result = ""
    if className
      result = dumpClassDef( className )
    else
      @complexTypes.each do | complexType |
	case complexType.compoundType
	when :TYPE_STRUCT
	  result << dumpClassDef( complexType.name )
	when :TYPE_ARRAY
	  result << dumpArrayDef( complexType.name )
       	else
	  raise RuntimeError.new( "Unknown complexContent definition..." )
	end
	result << "\n"
      end
    end
    result
  end

private

  def dumpClassDef( className )
    complexType = @complexTypes[ className ]
    elements = complexType.content.elements
    attr_lines = ""
    var_lines = ""
    init_lines = ""
    elements.each do | elementName, element |
      name = createMethodName( elementName )
      type = element.type
      attr_lines << "  attr_accessor :#{ name }	# #{ type }\n"
      init_lines << "    @#{ name } = #{ name }\n"
      unless var_lines.empty?
	var_lines << ",\n      "
      end
      var_lines << "#{ name } = nil"
    end
    init_lines.chomp!

#  @@typeName = "#{ className.name }"
#  @@typeNamespace = "#{ className.namespace }"
    return <<__EOD__
# #{ className.namespace }
class #{ dumpClassName( className ) }
#{ attr_lines }
  def initialize( #{ var_lines } )
#{ init_lines }
  end
end
__EOD__
  end

  def dumpArrayDef( arrayName )
    return <<__EOD__
# #{ arrayName.namespace }
class #{ arrayName.name } < Array; end
__EOD__
  end

  def dumpClassName( className )
    if @faultTypes.index( className )
      "#{ className.name } < StandardError"
    else
      "#{ className.name }"
    end
  end

  def getFaultTypes( definitions )
    result = []
    getFaultMessages( definitions ).each do | message |
      parts = definitions.getMessage( message ).parts
      if parts.size != 1
	raise RuntimeError.new( "Expects fault message to have 1 part." )
      end
      if result.index( parts[0].type ).nil?
	result << parts[0].type
      end
    end
    result
  end

  def getFaultMessages( definitions )
    result = []
    definitions.portTypes.each do | portType |
      portType.operations.each do | operation |
	if operation.fault && result.index( operation.fault.message ).nil?
	  result << operation.fault.message
	end
      end
    end
    result
  end
end


  end
end
