=begin
WSDL4R - Creating class definition from XMLSchema
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


require 'wsdl/info'


module WSDL
  module XMLSchema


class ClassDefCreator
  attr_reader :schema

  def initialize( schema )
    @schema = schema
  end

  def dump( className = nil )
    result = ""
    if className
      result = dumpClassDef( className )
    else
      @schema.complexTypes.each do | complexType |
	if complexType.content
	  result << dumpClassDef( complexType.name )
	elsif complexType.complexContent
	  result << dumpArrayDef( complexType.name )
	end
	result << "\n"
      end
    end
    result
  end

private

  def dumpClassDef( className )
    complexType = @schema.complexTypes[ className ]
    elements = complexType.content.elements
    attr_lines = ""
    var_lines = ""
    init_lines = ""
    elements.each do | element |
      name = element.name
      type = element.type
      attr_lines << "  attr_accessor :#{ name }	# #{ type }\n"
      init_lines << "    @#{ name } = nil\n"
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
    "#{ className.name }"
  end
end


  end
end
