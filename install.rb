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

  File.mkpath DSTPATH + "/soap", true 
  Dir["lib/soap/*.rb"].each do |name|
    File.install name, "#{DSTPATH}/soap/#{File.basename name}", 0644, true
  end

  Dir["redist/*.rb"].each do |name|
    File.install name, "#{DSTPATH}/#{File.basename name}", 0644, true
  end

  File.mkpath DSTPATH + "/urb", true 
  Dir["redist/urb/*.rb"].each do |name|
    File.install name, "#{DSTPATH}/urb/#{File.basename name}", 0644, true
  end

rescue 
  puts "install failed!"
  puts $!
else
  puts "install succeed!"
end
