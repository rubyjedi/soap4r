#!/usr/local/bin/ruby

require 'webrick'
require 'getopts'

getopts nil, 'r:'

dir = File::dirname(File::expand_path(__FILE__))

s=WEBrick::HTTPServer.new(
  :Port           => 2000,
  :BindAddress	  => nil,
  :Logger         => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
  :DocumentRoot   => $OPT_r || dir + "/htdocs"
)

# Create SOAPlet instance.
require 'soaplet'
srv = SOAP::WEBrickSOAPlet.new

# Load service class and create service object.
require 'exchange'
srv.addServant( 'urn:exchangeService', Exchange.new )

# Mount it at somewhere.
s.mount("/soap", srv)

trap("INT"){ s.shutdown }
s.start
