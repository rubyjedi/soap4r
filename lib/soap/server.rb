=begin
SOAP4R - Server implementation
Copyright (c) 2001 NAKAMURA, Hiroshi

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

require 'soap/rpcRouter'

# Ruby bundled library

# Redist library
require 'devel/logger'

module SOAP


###
# SYNOPSIS
#   Server.new( appName, namespace )
#
# DESCRIPTION
#   To be written...
#
class Server < Devel::Application
  include SOAP

  def initialize( appName, namespace )
    super( appName )
    @namespace = namespace
    @router = RPCRouter.new( appName )
    methodDef
  end
 
  def mappingRegistry
    @router.mappingRegistry
  end

  def mappingRegistry= ( value )
    @router.mappingRegistry = value
  end


protected
  
  def methodDef
    # Override this method in derived class to call 'addMethod' to add methods.
  end

  def addMethod( receiver, methodName, *paramArg )
    addMethodWithNS( @namespace, receiver, methodName, *paramArg )
  end

  def addMethodWithNS( namespace, receiver, methodName, *paramArg )
    paramDef = if paramArg.size == 1 and paramArg[ 0 ].is_a?( Array )
        paramArg[ 0 ]
      else
        RPCUtils::SOAPMethod.createParamDef( paramArg )
      end
    @router.addMethod( @namespace, receiver, methodName, paramDef )
  end

  def addServant( obj )
   ( obj.methods - Kernel.instance_methods ).each do | methodName |
      method = obj.method( methodName )
      paramDef = RPCUtils::SOAPMethod.createParamDef(
	( 1..method.arity.abs ).collect { |i| "p#{ i }" } )
      @router.addMethod( @namespace, obj, methodName, paramDef )
    end
  end


  def route( requestString )
    @router.route( requestString )
  end

  def createFaultResponseString( e )
    @router.createFaultResponseString( e )
  end
end


end
