=begin
WSDL4R - Creating servant skelton code from WSDL.
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
require 'wsdl/soap/methodDefCreatorSupport'


module WSDL
  module SOAP


class ServantSkeltonCreator
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
    operations = @definitions.getPortType( portType ).operations
    dumpOperations = ""
    operations.each do | operation |
      dumpOperations << dumpOperation( operation )
    end
    return <<__EOD__
class #{ createClassName( portType.name ) }
#{ dumpOperations.gsub( /^/, "  " ).chomp }
end
__EOD__
  end

  def dumpOperation( operation )
    name = operation.name.name
    input = operation.input
    output = operation.output
    fault = operation.fault
    signature = "#{ name }#{ dumpInputParam( input ) }"
    result = ""
    result << dumpSignature( operation )
    result << <<__EOD__
def #{ name }#{ dumpInputParam( input ) }
  raise NotImplementedError.new
end

__EOD__
  end
end


  end
end
