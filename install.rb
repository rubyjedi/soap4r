#!/usr/bin/env ruby

require "rbconfig"
require "ftools"
include Config

RV = CONFIG["MAJOR"] + "." + CONFIG["MINOR"]
DSTPATH = CONFIG["sitedir"] + "/" +  RV 

def join( *arg )
  File.join( *arg )
end

def base( name )
  File.basename( name )
end

begin
  unless FileTest.directory?( join( 'lib', 'soap' ))
    raise RuntimeError.new( "'lib/soap' not found." )
  end
  unless FileTest.directory?( "redist" )
    raise RuntimeError.new( "'redist' not found." )
  end
  unless FileTest.directory?( join( 'redist', 'soap' ))
    raise RuntimeError.new( "'redist/soap' not found." )
  end

  File.mkpath( join( DSTPATH, 'soap' ), true )
  Dir[ 'lib/soap/*.rb' ].each do | name |
    File.install( name, join( DSTPATH, 'soap', base( name )), 0644, true )
  end
  Dir[ 'redist/soap/*.rb' ].each do | name |
    File.install( name, join( DSTPATH, 'soap', base( name )), 0644, true )
  end
  Dir[ 'redist/*.rb' ].each do | name |
    File.install( name, join( DSTPATH, base( name )), 0644, true )
  end

  puts "install succeed!"

rescue 
  puts "install failed!"
  puts $!

end
