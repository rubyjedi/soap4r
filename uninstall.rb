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

def uninstall( name, path )
  filePath = join( path, File.basename( name ))
  if FileTest.exist?( filePath )
    target = InstalledFile.new( filePath )
    if $installed.uninstall( target )
      STDERR.puts "File: #{ target.path } uninstalled."
    end
  end
end

def uninstallDir( targetDir, from )
  unless FileTest.directory?( targetDir )
    raise RuntimeError.new( "'#{ targetDir }' not found." )
  end
  Dir[ join( targetDir, '*.rb' ) ].each do | name |
    uninstall( name, from )
  end
end

def delPath( dirPath )
  entries = Dir.entries( dirPath )
  entries.delete( "." )
  entries.delete( ".." )

  if entries.empty?
    Dir.unlink( dirPath )
  else
    STDERR.puts "Directory: #{ dirPath } is not empty.  The directory is not removed."
  end
end

begin
  uninstallDir( join( SRCPATH, 'lib', 'soap' ), join( DSTPATH, 'soap' ))
  uninstallDir( join( SRCPATH, 'lib', 'wsdl', 'soap' ),
    join( DSTPATH, 'wsdl', 'soap' ))
  uninstallDir( join( SRCPATH, 'lib', 'wsdl', 'xmlSchema' ),
    join( DSTPATH, 'wsdl', 'xmlSchema' ))
  uninstallDir( join( SRCPATH, 'lib', 'wsdl' ), join( DSTPATH, 'wsdl' ))
  uninstallDir( join( SRCPATH, 'redist', 'soap' ), join( DSTPATH, 'soap' ))
  uninstallDir( join( SRCPATH, 'redist' ), join( DSTPATH ))

  delPath( join( DSTPATH, 'soap' ))
  delPath( join( DSTPATH, 'wsdl', 'xmlSchema' ))
  delPath( join( DSTPATH, 'wsdl', 'soap' ))
  delPath( join( DSTPATH, 'wsdl' ))

#  $installed.dump( SRCPATH )

  puts "uninstall succeed!"

rescue 
  puts "uninstall failed!"
  puts $!

end
