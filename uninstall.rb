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

def uninstall( name, path )
  filePath = join( path, File.basename( name ))
  if FileTest.exist?( filePath )
    target = InstalledFile.new( filePath )
    if $installed.uninstall( target )
      STDERR.puts "File: #{ target.path } uninstalled."
    end
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
  Dir[ 'lib/soap/*.rb' ].each do | name |
    uninstall( name, join( DSTPATH, 'soap' ))
  end
  Dir[ 'redist/soap/*.rb' ].each do | name |
    uninstall( name, join( DSTPATH, 'soap' ))
  end
  Dir[ 'redist/*.rb' ].each do | name |
    uninstall( name, DSTPATH )
  end

  delPath( join( DSTPATH, 'soap' ))

  $installed.dump

  puts "uninstall succeed!"

rescue 
  puts "uninstall failed!"
  puts $!

end
