#!/usr/bin/env ruby

require 'rbconfig'
require 'ftools'

include Config

RV = CONFIG["MAJOR"] + "." + CONFIG["MINOR"]
DSTPATH = CONFIG["sitedir"] + "/" +  RV 
SRCPATH = File.dirname( $0 )

def join( *arg )
  File.join( *arg )
end

require join( SRCPATH, '_installedFiles' )
$installed = InstalledFiles.new( SRCPATH )

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
  installDir( join( SRCPATH, 'lib', 'soap' ), join( DSTPATH, 'soap' ))
  installDir( join( SRCPATH, 'lib', 'soap', 'rpc' ),
    join( DSTPATH, 'soap', 'rpc' ))
  installDir( join( SRCPATH, 'lib', 'soap', 'mapping' ),
    join( DSTPATH, 'soap', 'mapping' ))
  installDir( join( SRCPATH, 'lib', 'wsdl' ), join( DSTPATH, 'wsdl' ))
  installDir( join( SRCPATH, 'lib', 'wsdl', 'xmlSchema' ),
    join( DSTPATH, 'wsdl', 'xmlSchema' ))
  installDir( join( SRCPATH, 'lib', 'wsdl', 'soap' ),
    join( DSTPATH, 'wsdl', 'soap' ))
  installDir( join( SRCPATH, "redist" ), DSTPATH )
  installDir( join( SRCPATH, 'redist', 'soap' ), join( DSTPATH, 'soap' ))

  $installed.dump( SRCPATH )

  puts "install succeed!"

rescue 
  puts "install failed!"
  puts $!

end
