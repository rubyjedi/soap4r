#!/usr/bin/env ruby

require 'rbconfig'
require 'ftools'
require '_installedFiles'

include Config

RV = CONFIG["MAJOR"] + "." + CONFIG["MINOR"]
DSTPATH = CONFIG["sitedir"] + "/" +  RV 

$installed = InstalledFiles.new

def join( *arg )
  File.join( *arg )
end

def install( from, to )
  toPath = File.catname( from, to )
  unless FileTest.exist?( toPath ) and File.compare( from, toPath )
    File.install( from, toPath, 0644, true )
    $installed << InstalledFile.new( toPath )
  end
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
    install( name, join( DSTPATH, 'soap' ))
  end
  Dir[ 'redist/soap/*.rb' ].each do | name |
    install( name, join( DSTPATH, 'soap' ))
  end
  Dir[ 'redist/*.rb' ].each do | name |
    install( name, DSTPATH )
  end

  $installed.dump

  puts "install succeed!"

rescue 
  puts "install failed!"
  puts $!

end
