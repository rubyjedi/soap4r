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

def installDir( from, to )
  unless FileTest.directory?( from )
    raise RuntimeError.new( "'#{ from }' not found." )
  end
  File.mkpath( to, true )
  Dir[ join( from, '*.rb' ) ].each do | name |
    install( name, to )
  end
end

begin
  installDir( join( 'lib', 'soap' ), join( DSTPATH, 'soap' ))
  installDir( join( 'lib', 'wsdl' ), join( DSTPATH, 'wsdl' ))
  installDir( join( 'lib', 'wsdl', 'xmlSchema' ), join( DSTPATH, 'wsdl', 'xmlSchema' ))
  installDir( join( 'lib', 'wsdl', 'soap' ), join( DSTPATH, 'wsdl', 'soap' ))
  installDir( "redist", DSTPATH )
  installDir( join( 'redist', 'soap' ), join( DSTPATH, 'soap' ))

  $installed.dump

  puts "install succeed!"

rescue 
  puts "install failed!"
  puts $!

end
