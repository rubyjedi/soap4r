#!/usr/bin/env ruby

require 'soap/standaloneServer'
require 'soap/XMLSchemaDatatypes1999'

class App < SOAP::StandaloneServer

  def initialize( *arg )
    super( *arg )
  end

  def methodDef
    addMethod( self, 'notify', 'list' )
  end

  def notify( list )
    puts <<__EOS__
======
#{ list }
======
__EOS__
    true
  end
end

App.new( 'App', "", '0.0.0.0', 8082 ).start
