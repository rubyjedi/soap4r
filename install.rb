#!/usr/bin/env ruby
#
# Installer for SOAP4R
# Copyright (C) 2001 Michael Neumann.
#
# From: Michael Neumann <neumann@s-direktnet.de>
# Message-ID: <20010703221736.A20714@michael.neumann.all>
# Date: Tue, 3 Jul 2001 22:17:36 +0200

require "rbconfig"
require "ftools"
include Config

RV = CONFIG["MAJOR"] + "." + CONFIG["MINOR"]
DSTPATH = CONFIG["sitedir"] + "/" +  RV 

begin
  unless FileTest.directory?( "lib/soap" )
    raise RuntimeError.new( "'lib/soap' not found." )
  end

  unless FileTest.directory?( "redist" )
    raise RuntimeError.new( "'redist' not found." )
  end

  unless FileTest.directory?( "redist/soap" )
    raise RuntimeError.new( "'redist/soap' not found." )
  end

  File.mkpath DSTPATH + "/soap", true 
  Dir["lib/soap/*.rb"].each do |name|
    File.install name, "#{DSTPATH}/soap/#{File.basename name}", 0644, true
  end

  Dir["redist/soap/*.rb"].each do |name|
    File.install name, "#{DSTPATH}/soap/#{File.basename name}", 0644, true
  end

  Dir["redist/*.rb"].each do |name|
    File.install name, "#{DSTPATH}/#{File.basename name}", 0644, true
  end

  # Installing http-access2
  File.mkpath DSTPATH + "/http-access2", true 
  Dir["redist/http-access2/*.rb"].each do |name|
    File.install name, "#{DSTPATH}/http-access2/#{File.basename name}", 0644, true
  end

rescue 
  puts "install failed!"
  puts $!
else
  puts "install succeed!"
end
