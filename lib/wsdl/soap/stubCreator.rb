=begin
WSDL4R - Creating stub code from WSDL.
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
require 'wsdl/soap/mappingRegistryCreator'
require 'wsdl/soap/methodDefCreator'
require 'wsdl/soap/methodDefCreatorSupport'


module WSDL
  module SOAP


class StubCreator
  include MethodDefCreatorSupport

  attr_reader :definitions

  def initialize( definitions )
    @definitions = definitions
  end

  def dump( portTypeName = nil )
    if portTypeName.nil?
      result = ""
      @definitions.portTypes.each do | portType |
	result << dumpPortType( portType.name )
	result << "\n"
      end
    else
      result = dumpPortType( portTypeName )
    end
    result
  end

private

  def dumpPortType( portType )
    operations = @definitions.portTypes[ portType ].operations
    dumpOperations = ""
    operations.each do | operation |
      dumpOperations << dumpOperation( operation )
    end
    methodDefCreator = MethodDefCreator.new( @definitions )
    methodDef, types = methodDefCreator.dump( portType )
    mrCreator = MappingRegistryCreator.new( @definitions )
    return <<__EOD__
class #{ createClassName( portType.name ) }
#{ dumpOperations.gsub( /^/, "  " ).chomp }

  require 'soap/rpcUtils'
#{ mrCreator.dump( types ).gsub( /^/, "  " ).chomp }
  Methods = [
#{ methodDef.gsub( /^/, "    " ).chomp }
  ]
end
__EOD__
  end

  def dumpOperation( operation )
    name = operation.name.name
    input = operation.input
    output = operation.output
    fault = operation.fault
    signature = "#{ name }#{ dumpInputParam( input ) }"
    return <<__EOD__
# SYNOPSIS
#   #{ signature}
#
# ARGS
#{ dumpInOutType( input ).chomp }
#
# RETURNS
#{ dumpInOutType( output ).chomp }
#
# RAISES
#{ dumpInOutType( fault ).chomp }
#
def #{ signature }
  raise NotImplementedError.new
end

__EOD__
  end

  def dumpInputParam( input )
    message = @definitions.messages[ input.message ]
    params = ""
    message.parts.each do | part |
      params << ", " unless params.empty?
      params << part.name
    end
    if params.empty?
      ""
    else
      "( #{ params } )"
    end
  end

  def dumpInOutType( param )
    if param
      message = @definitions.messages[ param.message ]
      params = ""
      message.parts.each do | part |
	params << "#   #{ part.name }\t\t#{ part.type }\n"
      end
      unless params.empty?
	return params
      end
    end
    "#    N/A\n"
  end
end


  end
end
