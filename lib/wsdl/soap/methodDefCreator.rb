=begin
WSDL4R - Creating driver code from WSDL.
Copyright (C) 2002, 2003 NAKAMURA Hiroshi.

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


class MethodDefCreator
  include MethodDefCreatorSupport

  attr_reader :definitions

  def initialize( definitions )
    @definitions = definitions
    @complexTypes = @definitions.collectComplexTypes
    @types = nil
  end

  def dump( portType )
    @types = []
    result = ""
    operations = @definitions.getPortType( portType ).operations
    binding = @definitions.getPortTypeBinding( portType )
    operations.each do | operation |
      opBinding = binding.operations[ operation.name ]
      result << ",\n" unless result.empty?
      result << dumpMethod( operation, opBinding ).chomp
    end
    return result, @types
  end

private

  # methodNameAs, methodName, params, soapAction, namespace
  def dumpMethod( operation, binding )
    methodName = createMethodName( operation.name.name )
    methodNameAs = methodName
    params = collectParams( operation )
    soapAction = binding.soapOperation.soapAction
    namespace = binding.input.soapBody.namespace
    paramsStr = param2str( params )
    if paramsStr.empty?
      paramsStr = '[]'
    else
      paramsStr = "[\n" << paramsStr << " ]"
    end
    return <<__EOD__
[ #{ dq( methodNameAs ) }, #{ dq( methodName ) }, #{ paramsStr },
  #{ dq( soapAction ) }, #{ dq( namespace ) } ]
__EOD__
  end

  def collectParams( operation )
    result = operation.getInputParts.collect { | part |
      collectTypes( part.type )
      paramSet( 'in', typeDef( part.type ), part.name )
    }
    outParts = operation.getOutputParts
    if outParts.size > 0
      retval = outParts[ 0 ]
      collectTypes( retval.type )
      result << paramSet( 'retval', typeDef( retval.type ), retval.name )
      cdr( outParts ).each { | part |
	collectTypes( part.type )
	result << paramSet( 'out', typeDef( part.type ), part.name )
      }
    end
    result
  end

  def typeDef( type )
    if mappedType = getBaseTypeMappedClass( type )
      [ mappedType ]
    else
      typeDef = @complexTypes[ type ]
      if typeDef.nil?
	raise RuntimeError.new("Type: #{type} not found.")
      end
      case typeDef.compoundType
      when :TYPE_STRUCT
	[ '::SOAP::SOAPStruct', type.namespace, type.name ]
      when :TYPE_ARRAY
	arrayType = typeDef.getArrayType
	contentTypeNamespace = arrayType.namespace
	contentTypeName = arrayType.name.sub( /\[(?:,)*\]$/, '' )
	[ '::SOAP::SOAPArray', contentTypeNamespace, contentTypeName ]
      else
	raise NotImplementedError.new( "Must not reach here." )
      end
    end
  end

  def paramSet( ioType, type, name )
    [ ioType, type, name ]
  end

  def collectTypes( type )
    # ignore inline type definition.
    return if type.nil?
    @types << type
    return unless @complexTypes[ type ]
    @complexTypes[ type ].eachElement do | elementName, element |
      collectTypes( element.type )
    end
  end

  def param2str( params )
    params.collect { | param |
      "  [ #{ dq( param[0] ) }, #{ dq( param[2] ) },\n" <<
      "    #{ type2str( param[1] ) } ]"
    }.join( ",\n" )
  end

  def type2str( type )
    if type.size == 1
      "[ #{ type[0] } ]" 
    else
      "[ #{ type[0] }, #{ dq( type[1] ) }, #{ dq( type[2] ) } ]" 
    end
  end

  def dq( ele )
    "\"" << ele << "\""
  end

  def cdr( ary )
    result = ary.dup
    result.shift
    result
  end
end


  end
end
